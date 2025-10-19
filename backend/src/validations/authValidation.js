import Joi from 'joi';

export const registerSchema = Joi.object({
  fullName: Joi.string().min(3).required(),
  email: Joi.string().email(),
  phoneNumber: Joi.string(),
  password: Joi.string().min(6).required(),
  confirmPassword: Joi.string().valid(Joi.ref('password')).required().strict(),
  role: Joi.string().valid('user', 'admin', 'doctor').optional(),
}).or('email', 'phoneNumber');

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});
