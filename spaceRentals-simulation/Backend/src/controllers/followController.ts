import { prisma } from '../lib/prisma';
import { io } from '../socket';

// ── Follow a user ─────────────────────────────────────────────────────────────
export const followUser = async (req: any, res: any) => {
  try {
    const followerId = req.user!.userId;
    const followingId = String(req.params.id);

    if (followerId === followingId) {
      return res.status(400).json({ message: 'You cannot follow yourself.' });
    }

    // Upsert so duplicate follows are ignored
    await prisma.follow.upsert({
      where: { followerId_followingId: { followerId, followingId } },
      create: { followerId, followingId },
      update: {},
    });

    // Get updated follower count for real-time push
    const count = await prisma.follow.count({ where: { followingId } });

    // Notify the followed user in real-time
    io.to(`user:${followingId}`).emit('follow_update', {
      followerId,
      followerCount: count,
      event: 'followed',
    });

    return res.json({ success: true, followerCount: count });
  } catch (err: any) {
    console.error('[FollowController] followUser:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ── Unfollow a user ───────────────────────────────────────────────────────────
export const unfollowUser = async (req: any, res: any) => {
  try {
    const followerId = req.user!.userId;
    const followingId = String(req.params.id);

    await prisma.follow.deleteMany({ where: { followerId, followingId } });

    const count = await prisma.follow.count({ where: { followingId } });

    io.to(`user:${followingId}`).emit('follow_update', {
      followerId,
      followerCount: count,
      event: 'unfollowed',
    });

    return res.json({ success: true, followerCount: count });
  } catch (err: any) {
    console.error('[FollowController] unfollowUser:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ── Get follow status (does current user follow :id?) ─────────────────────────
export const getFollowStatus = async (req: any, res: any) => {
  try {
    const followerId = req.user!.userId;
    const followingId = String(req.params.id);

    const follow = await prisma.follow.findUnique({
      where: { followerId_followingId: { followerId, followingId } },
    });

    const followerCount = await prisma.follow.count({ where: { followingId } });
    const followingCount = await prisma.follow.count({ where: { followerId: followingId } });

    return res.json({ isFollowing: !!follow, followerCount, followingCount });
  } catch (err: any) {
    console.error('[FollowController] getFollowStatus:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ── Public profile: name + avatar + stats + listings ─────────────────────────
export const getPublicProfile = async (req: any, res: any) => {
  try {
    const viewerId = req.user?.userId;
    const targetId = String(req.params.id);

    const user = await prisma.user.findUnique({
      where: { id: targetId },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        name: true,
        bio: true,
        avatarUrl: true,
        role: true,
        createdAt: true,
        _count: {
          select: {
            followers: true,
            following: true,
            properties: true,
          },
        },
      },
    });

    if (!user) return res.status(404).json({ message: 'User not found.' });

    // Check if viewer follows this user
    let isFollowing = false;
    if (viewerId && viewerId !== targetId) {
      const follow = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId: viewerId, followingId: targetId } },
      });
      isFollowing = !!follow;
    }

    // Get their active listings
    const properties = await prisma.property.findMany({
      where: { landlordId: targetId, status: 'available' },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });

    return res.json({
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.name || `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      role: user.role,
      followerCount: user._count.followers,
      followingCount: user._count.following,
      propertyCount: user._count.properties,
      isFollowing,
      memberSince: user.createdAt,
      properties,
    });
  } catch (err: any) {
    console.error('[FollowController] getPublicProfile:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
