import Appointment from '../models/Appointment.model.js';
import User from '../models/user.model.js';
import ApiError from '../utils/ApiError.js';
// Import các hàm utils để xử lý ngày giờ nếu cần
// import { parseTime, isTimeSlotAvailable } from '../utils/timeUtils.js';

/**
 * Tạo một cuộc hẹn mới
 */
export const createAppointment = async (userId, doctorId, date, startTime, reason) => {
  // 1. Kiểm tra Doctor ID có tồn tại và đúng role không
  const doctor = await User.findById(doctorId);
  if (!doctor || doctor.role !== 'doctor') {
    throw new ApiError(404, 'Doctor không tồn tại hoặc không đủ thẩm quyền.');
  }
  
  // 2. Kiểm tra tính khả dụng của khe thời gian
  // Đây là logic phức tạp, cần triển khai dựa trên workingHours của Doctor
  // Giả định: checkDoctorAvailability(doctorId, date, startTime)
  
  // *** THAY THẾ BẰNG LOGIC KIỂM TRA THỜI GIAN THỰC TẾ ***
  const existingAppointment = await Appointment.findOne({
      doctor: doctorId,
      date: new Date(date), // Chuyển sang Date object để tìm kiếm
      startTime,
      status: { $in: ['pending', 'confirmed'] }
  });

  if (existingAppointment) {
      throw new ApiError(400, 'Khe thời gian này đã có lịch hẹn.');
  }
  // *******************************************************

  // 3. Tạo lịch hẹn
  const appointment = await Appointment.create({
    user: userId,
    doctor: doctorId,
    date: new Date(date), // Lưu dưới dạng Date
    startTime,
    reason,
    status: 'pending',
  });

  return appointment.populate('user', 'fullName email phoneNumber');
};

/**
 * Lấy danh sách lịch hẹn
 */
export const getAppointments = async (userId, userRole, filter = {}) => {
  let query = {};

  if (userRole === 'user') {
    query.user = userId;
  } else if (userRole === 'doctor') {
    query.doctor = userId;
  }
  
  // Thêm các bộ lọc khác nếu cần (ví dụ: filter.status, filter.date)
  query = { ...query, ...filter };

  const appointments = await Appointment.find(query)
    .populate('user', 'fullName avatar')
    .populate('doctor', 'fullName specialty avatar')
    .sort({ date: 1, startTime: 1 });
    
  return appointments;
};

/**
 * Cập nhật trạng thái lịch hẹn
 */
export const updateAppointmentStatus = async (appointmentId, status, updaterRole) => {
    // Chỉ Doctor hoặc Admin mới được phép cập nhật trạng thái
    if (updaterRole === 'user') {
        throw new ApiError(403, 'Người dùng không có quyền cập nhật trạng thái lịch hẹn.');
    }

    const appointment = await Appointment.findById(appointmentId);

    if (!appointment) {
        throw new ApiError(404, 'Không tìm thấy lịch hẹn.');
    }

    // Nếu muốn hủy/từ chối
    if (status === 'cancelled') {

    }
    
    appointment.status = status;
    await appointment.save();

    return appointment;
};