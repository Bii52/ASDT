
import swaggerJSDoc from 'swagger-jsdoc';
import { env } from '~/config/environment.js';

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'ASDT API Documentation',
    version: '1.0.0',
    description: 'API documentation for the ASDT project, providing endpoints for user management and other features.',
  },
  servers: [
    {
      url: '/api',
      description: 'API server with /api prefix',
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter JWT token in the format: Bearer {token}',
      },
    },
  },
  security: [
    {
      bearerAuth: [],
    },
  ],
};

const options = {
  swaggerDefinition,
  apis: ['src/routes/**/*.js'],
};

export const specs = swaggerJSDoc(options);
