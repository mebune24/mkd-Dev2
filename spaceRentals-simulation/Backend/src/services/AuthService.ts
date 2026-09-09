import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { userRepository } from '../repositories/UserRepository';
import { prisma } from '../lib/prisma';

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('[FATAL] JWT_SECRET env variable is not set. Server cannot start safely.');
const ALLOWED_ROLES = ['landlord', 'tenant', 'agent'];
export const CURRENT_TERMS_VERSION = '2026-09-09';

export class AuthService {
  async register(name: string, email: string, password: string, role: string, termsAccepted: boolean, termsVersion?: string) {
    if (!name || !email || !password || !role) {
      throw { status: 400, message: 'name, email, password and role are required.' };
    }
    if (!ALLOWED_ROLES.includes(role)) {
      throw { status: 400, message: `Invalid role. Must be one of: ${ALLOWED_ROLES.join(', ')}` };
    }
    if (!termsAccepted || termsVersion !== CURRENT_TERMS_VERSION) {
      throw { status: 400, message: 'You must accept the current SpaceRentals Terms and Conditions.' };
    }
    const existing = await userRepository.findByEmail(email);
    if (existing) {
      throw { status: 409, message: 'email already in use' };
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({
      name,
      email,
      passwordHash,
      role,
      ...(role === 'landlord' ? { status: 'pending_verification' } : {}),
      termsAcceptedAt: new Date(),
      termsVersion: CURRENT_TERMS_VERSION,
    });
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET!, { expiresIn: '30d' });
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status, isKycVerified: false, kycStatus: role === 'landlord' ? 'not_submitted' : undefined, termsAccepted: true, termsVersion: CURRENT_TERMS_VERSION } };
  }

  async login(email: string, password: string) {
    if (!email || !password) {
      throw { status: 400, message: 'email and password are required.' };
    }
    const user = await userRepository.findByEmail(email);
    if (!user) throw { status: 401, message: 'Invalid credentials.' };
    if (user.status === 'suspended') {
      throw { status: 403, message: 'Your account has been suspended. Please contact support.' };
    }
    if (user.termsVersion !== CURRENT_TERMS_VERSION) {
      throw { status: 403, message: 'You must accept the current SpaceRentals Terms and Conditions before signing in.' };
    }
    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) throw { status: 401, message: 'Invalid credentials.' };

    const landlordVerification = user.role === 'landlord'
      ? await prisma.landlordVerification.findUnique({ where: { landlordId: user.id }, select: { status: true } })
      : null;
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET!, { expiresIn: '30d' });
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status, isKycVerified: landlordVerification?.status === 'approved', kycStatus: landlordVerification?.status ?? (user.role === 'landlord' ? 'not_submitted' : undefined), termsAccepted: true, termsVersion: user.termsVersion } };
  }

  async acceptTerms(userId: string, version: string) {
    if (version !== CURRENT_TERMS_VERSION) {
      throw { status: 400, message: 'The Terms and Conditions version is no longer current.' };
    }
    const user = await userRepository.update(userId, {
      termsAcceptedAt: new Date(),
      termsVersion: version,
    });
    return { accepted: true, termsVersion: user.termsVersion, termsAcceptedAt: user.termsAcceptedAt };
  }

  async getMe(userId: string) {
    const user = await userRepository.findById(userId);
    if (!user) throw { status: 404, message: 'User not found.' };
    const agentVerification = user.role === 'agent'
      ? await prisma.agentVerification.findUnique({
          where: { agentId: user.id },
          select: { status: true },
        })
      : null;
    const landlordVerification = user.role === 'landlord'
      ? await prisma.landlordVerification.findUnique({
          where: { landlordId: user.id },
          select: { status: true },
        })
      : null;

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      status: user.status,
      createdAt: user.createdAt,
      termsAccepted: user.termsVersion === CURRENT_TERMS_VERSION,
      termsVersion: user.termsVersion,
      isKycVerified:
        agentVerification?.status === 'approved' ||
        landlordVerification?.status === 'approved',
      kycStatus:
        agentVerification?.status ??
        landlordVerification?.status ??
        'not_submitted',
    };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string) {
    if (!currentPassword || !newPassword) {
      throw { status: 400, message: 'Current password and new password are required.' };
    }
    const user = await userRepository.findById(userId);
    if (!user) throw { status: 404, message: 'User not found.' };
    
    const match = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!match) throw { status: 401, message: 'Incorrect current password.' };
    
    const newPasswordHash = await bcrypt.hash(newPassword, 10);
    await userRepository.update(userId, { passwordHash: newPasswordHash });
    return { message: 'Password updated successfully.' };
  }
}

export const authService = new AuthService();
