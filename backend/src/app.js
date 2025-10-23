/* eslint-disable no-console */
import express from 'express'
import cors from 'cors'
import passport from 'passport'
import http from 'http'
import '~/config/passport.js'
import { connectDB } from '~/config/db.js'
import { env } from '~/config/environment.js'
import APIs from '~/routes/index.js'
import { errorHandler } from '~/middlewares/error.middleware.js'
import { initSocketServer, onlineUsers } from '~/services/socket.service.js'

const APP_HOST = env.APP_HOST || 'localhost'
const APP_PORT = env.APP_PORT || 5000

const START_SERVER = async () => {
  const app = express()
  const httpServer = http.createServer(app)
  const io = initSocketServer(httpServer)
  app.set('io', io)

  app.use(cors())
  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(passport.initialize())

  app.use((req, res, next) => {
    req.onlineUsers = onlineUsers
    next()
  })

  app.use('/api', APIs)
  app.use(errorHandler)

  httpServer.listen(APP_PORT, APP_HOST, () => {
    console.log(`🚀 Server running at http://${APP_HOST}:${APP_PORT}`)
  })
}

(async () => {
  console.log('Connecting to database...')
  await connectDB()
  console.log('Database connected successfully')
  console.log('Starting server...')
  await START_SERVER()
})()