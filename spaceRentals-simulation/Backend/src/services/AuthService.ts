import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { userRepository } from '../repositories/UserRepository';

const JWT_SECRET = process.env.JWT_SECRET || 'fallback_secret';
const ALLOWED_ROLES = ['landlord', 'tenant', 'agent'];

export class AuthService {
  async register(name: string, email: string, password: string, role: string) {
    if (!name || !email || !password || !role) {
      throw { status: 400, message: 'name, email, password and role are required.' };
    }
    if (!ALLOWED_ROLES.includes(role)) {
      throw { status: 400, message: `Invalid role. Must be one of: ${ALLOWED_ROLES.join(', ')}` };
    }
    const existing = await userRepository.findByEmail(email);
    if (existing) {
      throw { status: 409, message: 'An account with this email already exists.' };
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({ name, email, passwordHash, role });
    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status } };
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
    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) throw { status: 401, message: 'Invalid credentials.' };

    const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status } };
  }

  async getMe(userId: string) {
    const user = await userRepository.findById(userId);
    if (!user) throw { status: 404, message: 'User not found.' };
    return { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status, createdAt: user.createdAt };
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
