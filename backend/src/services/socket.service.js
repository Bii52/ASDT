import { Server as SocketIOServer } from 'socket.io'
import jwt from 'jsonwebtoken'
import { env } from '~/config/environment.js'

// Map to store online users (key: userId, value: { socketId, userType })
export const onlineUsers = new Map()

export const initSocketServer = (httpServer) => {
  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: '*', // TODO: Restrict this to the frontend domain in production
      methods: ['GET', 'POST']
    },
    path: '/socket.io'
  })

  // Socket.IO Authentication Middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth.token
    if (!token) {
      return next(new Error('Authentication error: Token not provided.'))
    }

    jwt.verify(token, env.JWT_SECRET, (err, user) => {
      if (err) {
        return next(new Error('Authentication error: Invalid token.'))
      }
      socket.user = user // Attach user info to the socket object
      next()
    })
  })

  io.on('connection', (socket) => {
    console.log(`[Socket.IO] Authenticated user connected: ${socket.user.fullName} (${socket.id})`)

    // 1. Handle user online status
    const { _id: userId, role: userType } = socket.user
    onlineUsers.set(userId, { socketId: socket.id, userType: userType })
    socket.join(userId) // Join a room for direct messaging

    // Emit updated list of online doctors
    io.emit('online_doctors_update', Array.from(onlineUsers.entries())
      .filter(([_, info]) => info.userType === 'Doctor')
      .map(([id]) => id))

    // 2. Handle disconnection
    socket.on('disconnect', () => {
      onlineUsers.delete(userId)
      console.log(`[Socket.IO] User disconnected: ${socket.user.fullName}`)
      
      // Emit updated list of online doctors
      io.emit('online_doctors_update', Array.from(onlineUsers.entries())
        .filter(([_, info]) => info.userType === 'Doctor')
        .map(([id]) => id))
    })
  })

  return io // Return io instance to be used in services
}