import { Server as SocketIOServer } from 'socket.io'
import jwt from 'jsonwebtoken'
import { env } from '~/config/environment.js'

// Map to store online users (key: userId, value: { socketId, userType })
export const onlineUsers = new Map()

export const initSocketServer = (httpServer) => {
  const isDev = env.BUILD_MODE === 'dev'
  const allowedOrigin = env.FRONTEND_ORIGIN || (isDev ? '*' : undefined)
  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: allowedOrigin,
      methods: ['GET', 'POST']
    },
    path: '/socket.io'
  })

  // Socket.IO Authentication Middleware
  io.use((socket, next) => {
    if (isDev) console.log(`[Socket.IO] New connection attempt from ${socket.handshake.address}`)
    const token = socket.handshake.auth.token
    if (isDev) console.log(`[Socket.IO] Token provided: ${token ? 'Yes' : 'No'}`)
    
    if (!token) {
      if (isDev) console.log(`[Socket.IO] Authentication failed: No token provided`)
      return next(new Error('Authentication error: Token not provided.'))
    }

    jwt.verify(token, env.JWT_SECRET, (err, user) => {
      if (err) {
        if (isDev) console.log(`[Socket.IO] Authentication failed: Invalid token - ${err.message}`)
        return next(new Error('Authentication error: Invalid token.'))
      }
      if (isDev) console.log(`[Socket.IO] Authentication successful for user:`, user)
      socket.user = user // Attach user info to the socket object
      next()
    })
  })

  io.on('connection', (socket) => {
    if (isDev) console.log(`[Socket.IO] Authenticated user connected: ${socket.user.email} (${socket.id})`)
    if (isDev) console.log(`[Socket.IO] User role: ${socket.user.role}`)

    // 1. Handle user online status
    const { id: userId, role: userType } = socket.user
    onlineUsers.set(userId, { socketId: socket.id, userType: userType })
    socket.join(userId) // Join a room for direct messaging

    if (isDev) console.log(`[Socket.IO] Online users:`, Array.from(onlineUsers.entries()))
    if (isDev) console.log(`[Socket.IO] Online doctors:`, Array.from(onlineUsers.entries())
      .filter(([_, info]) => info.userType === 'doctor')
      .map(([id]) => id))

    // Emit updated list of online doctors
    io.emit('online_doctors_update', Array.from(onlineUsers.entries())
      .filter(([_, info]) => info.userType === 'doctor')
      .map(([id]) => id))

    // 2. Handle disconnection
    socket.on('disconnect', (reason) => {
      onlineUsers.delete(userId)
      if (isDev) console.log(`[Socket.IO] User disconnected: ${socket.user.email}, reason: ${reason}`)
      if (isDev) console.log(`[Socket.IO] Remaining online users:`, Array.from(onlineUsers.entries()))
      
      // Emit updated list of online doctors
      io.emit('online_doctors_update', Array.from(onlineUsers.entries())
        .filter(([_, info]) => info.userType === 'doctor')
        .map(([id]) => id))
    })
  })

  return io // Return io instance to be used in services
}