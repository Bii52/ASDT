import Joi from 'joi';

// Schema cho việc đặt lịch hẹn mới
const createAppointment = {
  body: Joi.object().keys({
    doctorId: Joi.string().required().hex().length(24).messages({
        'string.base': 'Doctor ID phải là chuỗi.',
        'string.empty': 'Doctor ID không được để trống.',
        'string.hex': 'Doctor ID không hợp lệ.',
        'string.length': 'Doctor ID không hợp lệ.',
        'any.required': 'Doctor ID là bắt buộc.',
    }),
    date: Joi.date().iso().required().messages({
        'date.base': 'Ngày hẹn không hợp lệ.',
        'date.format': 'Ngày hẹn phải theo định dạng ISO 8601 (YYYY-MM-DD).',
        'any.required': 'Ngày hẹn là bắt buộc.',
    }),
    startTime: Joi.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required().messages({
        'string.pattern.base': 'Thời gian bắt đầu phải theo định dạng HH:MM (24h).',
        'any.required': 'Thời gian bắt đầu là bắt buộc.',
    }),
    reason: Joi.string().min(10).max(500).required().messages({
        'string.empty': 'Lý do khám không được để trống.',
        'string.min': 'Lý do khám phải có ít nhất 10 ký tự.',
        'string.max': 'Lý do khám không được vượt quá 500 ký tự.',
        'any.required': 'Lý do khám là bắt buộc.',
    }),
  }),
};

// Schema cho việc cập nhật trạng thái lịch hẹn
const updateAppointmentStatus = {
  params: Joi.object().keys({
    appointmentId: Joi.string().required().hex().length(24).messages({
        'string.hex': 'Appointment ID không hợp lệ.',
        'any.required': 'Appointment ID là bắt buộc.',
    }),
  }),
  body: Joi.object().keys({
    status: Joi.string().valid('confirmed', 'cancelled', 'completed').required().messages({
        'any.only': 'Trạng thái không hợp lệ. Phải là confirmed, cancelled, hoặc completed.',
        'any.required': 'Trạng thái là bắt buộc.',
    }),
  }),
};

export default {
  createAppointment,
  updateAppointmentStatus,
};