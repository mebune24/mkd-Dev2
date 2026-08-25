import { userRepository } from '../repositories/UserRepository';

export class UserService {
  async getAll(adminId: string, role: string) {
    if (role !== 'admin') throw { status: 403, message: 'Admin access required.' };
    return userRepository.findMany({
      select: { id: true, name: true, email: true, role: true, status: true, createdAt: true } as any,
      orderBy: { createdAt: 'desc' },
    });
  }

  async getById(targetId: string, requestingId: string, role: string) {
    if (targetId !== requestingId && role !== 'admin') throw { status: 403, message: 'Forbidden.' };
    const user = await userRepository.findById(targetId);
    if (!user) throw { status: 404, message: 'User not found.' };
    return { id: user.id, name: user.name, email: user.email, role: user.role, status: user.status };
  }

  async suspend(targetId: string, adminRole: string) {
    if (adminRole !== 'admin') throw { status: 403, message: 'Admin access required.' };
    const user = await userRepository.findById(targetId);
    if (!user) throw { status: 404, message: 'User not found.' };
    return userRepository.update(targetId, { status: 'suspended' });
  }

  async activate(targetId: string, adminRole: string) {
    if (adminRole !== 'admin') throw { status: 403, message: 'Admin access required.' };
    const user = await userRepository.findById(targetId);
    if (!user) throw { status: 404, message: 'User not found.' };
    return userRepository.update(targetId, { status: 'active' });
  }

  async getProfile(userId: string) {
    const user = await userRepository.findById(userId);
    if (!user) throw { status: 404, message: 'User not found.' };
    const [firstName, ...rest] = (user.firstName ? user.firstName : (user.name ?? '').split(' ')[0] ?? '').split(' ');
    const lastName = user.lastName ?? (user.name ?? '').split(' ').slice(1).join(' ');
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      firstName: user.firstName ?? user.name.split(' ')[0],
      lastName: user.lastName ?? user.name.split(' ').slice(1).join(' '),
      name: user.name,
      avatarUrl: user.avatarUrl,
      twoFactorEnabled: user.twoFactorEnabled,
      pushNotificationsEnabled: user.pushNotificationsEnabled,
      role: user.role,
      isActive: user.status === 'active',
      createdAt: user.createdAt,
    };
  }

  async updateProfile(userId: string, data: { firstName?: string; lastName?: string; phone?: string; name?: string; avatarUrl?: string; twoFactorEnabled?: boolean; pushNotificationsEnabled?: boolean }) {
    const user = await userRepository.findById(userId);
    if (!user) throw { status: 404, message: 'User not found.' };
    const updateData: any = {};
    if (data.firstName !== undefined) updateData.firstName = data.firstName;
    if (data.lastName !== undefined) updateData.lastName = data.lastName;
    if (data.phone !== undefined) updateData.phone = data.phone;
    if (data.name !== undefined) updateData.name = data.name;
    if (data.avatarUrl !== undefined) updateData.avatarUrl = data.avatarUrl;
    if (data.twoFactorEnabled !== undefined) updateData.twoFactorEnabled = data.twoFactorEnabled;
    if (data.pushNotificationsEnabled !== undefined) updateData.pushNotificationsEnabled = data.pushNotificationsEnabled;
    
    // Derive name from firstName+lastName if both provided
    if (data.firstName && data.lastName) updateData.name = `${data.firstName} ${data.lastName}`;
    return userRepository.update(userId, updateData);
  }
}

export const userService = new UserService();
