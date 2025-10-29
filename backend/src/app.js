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

const APP_HOST = env.APP_HOST || '0.0.0.0'
const APP_PORT = env.APP_PORT || 5000

const START_SERVER = async () => {
  const app = express()
  const httpServer = http.createServer(app)
  const io = initSocketServer(httpServer)
  app.set('io', io)

  app.use(cors({ origin: true, credentials: true }))
  app.use((req, res, next) => {
    const origin = req.headers.origin || '*'
    res.header('Access-Control-Allow-Origin', origin)
    res.header('Vary', 'Origin')
    res.header('Access-Control-Allow-Credentials', 'true')
    res.header('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS')
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization')
    // Allow Private Network Access (Chrome PNA) for requests from localhost to 192.168.x.x
    if (req.headers['access-control-request-private-network'] === 'true') {
      res.header('Access-Control-Allow-Private-Network', 'true')
    }
    if (req.method === 'OPTIONS') {
      return res.sendStatus(204)
    }
    next()
  })
  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(passport.initialize())

  app.use((req, res, next) => {
    req.onlineUsers = onlineUsers
    next()
  })

  // health check for connectivity debugging
  app.get('/api/health', (req, res) => res.status(200).json({ ok: true }))
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