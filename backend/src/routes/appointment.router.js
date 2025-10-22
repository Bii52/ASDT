import { Router } from 'express';
import * as appointmentController from '../controllers/appointment.controller.js';
import { verifyToken } from '../middlewares/authMiddleware.js';
import validationMiddleware from '../middlewares/validationMiddleware.js';
import appointmentValidation from '../validations/appointment.validation.js';

const router = Router();


router.post(
  '/',
  verifyToken,
  validationMiddleware(appointmentValidation.createAppointment),
  appointmentController.createAppointment
);


router.get(
  '/',
  verifyToken,
  appointmentController.getAppointments
);

router.put(
  '/:appointmentId/status',
  verifyToken,
  validationMiddleware(appointmentValidation.updateAppointmentStatus),
  appointmentController.updateAppointmentStatus
);

export default router;