import { Server, Socket } from 'socket.io';
import { Server as HttpServer } from 'http';
import jwt from 'jsonwebtoken';
import { UserRole } from './middleware/authMiddleware';

export let io: Server;

interface SocketUser {
  userId: string;
  role: UserRole;
}

export function initSocketServer(server: HttpServer) {
  io = new Server(server, {
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
      methods: ['GET', 'POST'],
      credentials: true,
    }
  });

  // Authentication middleware for sockets
  io.use((socket: Socket, next: (err?: Error) => void) => {
    const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return next(new Error('Authentication error: Token missing'));
    }

    try {
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) throw new Error('JWT_SECRET not configured');
      
      const decoded = jwt.verify(token, jwtSecret) as SocketUser;
      (socket as any).user = decoded;
      next();
    } catch (err) {
      next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const user = (socket as any).user as SocketUser;
    console.log(`[Socket] User connected: ${user.userId} (${user.role})`);

    // Join a personal room to receive private notifications
    socket.join(`user:${user.userId}`);

    // Join a chat room
    socket.on('join_room', (roomId: string) => {
      socket.join(`room:${roomId}`);
      console.log(`[Socket] User ${user.userId} joined room ${roomId}`);
    });

    // Send a message
    socket.on('send_message', (data: { roomId: string; message: string; receiverId: string }) => {
      const payload = {
        roomId: data.roomId,
        senderId: user.userId,
        message: data.message,
        timestamp: new Date().toISOString(),
      };
      
      // Broadcast to room
      io.to(`room:${data.roomId}`).emit('new_message', payload);
      
      // If we want to notify the receiver if they are not in the room
      io.to(`user:${data.receiverId}`).emit('notification', {
        type: 'chat',
        title: 'New Message',
        body: data.message,
      });
    });

    socket.on('disconnect', () => {
      console.log(`[Socket] User disconnected: ${user.userId}`);
    });
  });
}
