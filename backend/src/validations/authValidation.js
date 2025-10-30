import Joi from 'joi';

export const registerSchema = Joi.object({
  fullName: Joi.string().min(3).required(),
  email: Joi.string().email().required(),
  phoneNumber: Joi.string(),
  password: Joi.string().min(6).required(),
  confirmPassword: Joi.string().valid(Joi.ref('password')).required().strict(),
  role: Joi.string().valid('user', 'admin', 'doctor').optional(),
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

export const verifyRegistrationSchema = Joi.object({
  email: Joi.string().email().required(),
  otp: Joi.string().length(6).required(),
});

export const updateProfileSchema = Joi.object({
  fullName: Joi.string().min(3),
  avatar: Joi.string().uri(),
  height: Joi.number().positive(),
  weight: Joi.number().positive(),
  bloodPressure: Joi.string(),
  heartRate: Joi.number().positive(),
  bloodType: Joi.string(),
});

export const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: Joi.string().min(6).required(),
});
