/* eslint-disable no-console */
import express from 'express'
import cors from 'cors'
import passport from 'passport'
import '~/config/passport.js'
import { connectDB } from '~/config/db.js'
import { env } from '~/config/environment.js'
import APIs from '~/routes/index.js'
import { errorHandler } from '~/middlewares/error.middleware.js'

// Swagger configuration
import swaggerUi from 'swagger-ui-express'
import { specs } from '~/config/swagger.js'

const APP_HOST = env.APP_HOST || 'localhost'
const APP_PORT = env.APP_PORT || 5000

const START_SERVER = async () => {
  const app = express()
  app.use(cors())
  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(passport.initialize())

  // Setup Swagger only in non-production environments
  if (env.BUILD_MODE !== 'production') {
    app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(specs))
    app.get('/api/docs.json', (req, res) => {
      res.setHeader('Content-Type', 'application/json')
      res.send(specs)
    })
    console.log(`📄 Swagger UI available at http://${APP_HOST}:${APP_PORT}/api/docs`)
  }

  app.use('/api', APIs)
  app.use(errorHandler)
  app.listen(APP_PORT, APP_HOST, () => {
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