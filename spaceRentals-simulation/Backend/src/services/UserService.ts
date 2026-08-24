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
}

export const userService = new UserService();
