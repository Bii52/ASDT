import * as appointmentService from '../services/appointment.service.js';
import { ApiError } from '../utils/ApiError.js';

export const createAppointment = async (req, res, next) => {
  try {
    const userId = req.user.id; // Lấy ID người dùng từ Auth Middleware
    const { doctorId, date, startTime, reason } = req.body;

    const appointment = await appointmentService.createAppointment(
      userId,
      doctorId,
      date,
      startTime,
      reason
    );

    res.status(201).json({
      success: true,
      message: 'Đặt lịch hẹn thành công. Đang chờ bác sĩ xác nhận.',
      data: appointment,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/appointments - Lấy danh sách lịch hẹn
 */
export const getAppointments = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const userRole = req.user.role;
    const { status, date } = req.query; // Lọc theo query params

    const filters = {};
    if (status) filters.status = status;
    if (date) filters.date = new Date(date); // Lọc theo ngày

    const appointments = await appointmentService.getAppointments(userId, userRole, filters);

    res.status(200).json({
      success: true,
      data: appointments,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/appointments/:appointmentId/status - Cập nhật trạng thái
 */
export const updateAppointmentStatus = async (req, res, next) => {
  try {
    const { appointmentId } = req.params;
    const { status } = req.body;
    const updaterRole = req.user.role;

    const updatedAppointment = await appointmentService.updateAppointmentStatus(
      appointmentId,
      status,
      updaterRole
    );

    res.status(200).json({
      success: true,
      message: `Cập nhật trạng thái lịch hẹn thành công: ${status}`,
      data: updatedAppointment,
    });
  } catch (error) {
    next(error);
  }
};