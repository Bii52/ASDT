

import Appointment from '../models/Appointment.model';
import User from '../models/user.model';
import ApiError from '../utils/ApiError';
import httpStatus from 'http-status';


export const isAppointmentAvailable = async (doctorId, appointmentTime, durationMinutes = 30) => {

    const doctor = await User.findById(doctorId);
    if (!doctor || doctor.role !== 'Doctor') {
        throw new ApiError(httpStatus.NOT_FOUND, 'Doctor not found or invalid role');
    }


    const startTime = new Date(appointmentTime);
    const endTime = new Date(startTime.getTime() + durationMinutes * 60000);


    const existingAppointments = await Appointment.find({
        doctorId: doctorId,
        status: { $in: ['pending', 'confirmed'] },
    
        $or: [
            // Lịch hẹn hiện có bắt đầu trước khi lịch hẹn mới kết thúc
            { appointmentTime: { $lt: endTime } },

            { 
                $expr: {
                    $gt: [
                        { $add: ['$appointmentTime', durationMinutes * 60000] }, 
                        startTime
                    ]
                }
            }
        ]
    });
    
  
    const MIN_INTERVAL_MS = durationMinutes * 60000;
    const hasConflict = await Appointment.exists({
        doctorId: doctorId,
        status: { $in: ['pending', 'confirmed'] },
        appointmentTime: {
            $gte: new Date(startTime.getTime() - MIN_INTERVAL_MS),
            $lte: new Date(startTime.getTime() + MIN_INTERVAL_MS),
        }
    });


  
    if (hasConflict) {
        throw new ApiError(httpStatus.BAD_REQUEST, 'Appointment time is conflicting with an existing appointment.');
    }

    return true;
};


export const createAppointment = async (userId, doctorId, date, startTime, reason) => {
  const doctor = await User.findById(doctorId);
  if (!doctor || doctor.role !== 'doctor') {
    throw new ApiError(404, 'Doctor không tồn tại hoặc không đủ thẩm quyền.');
  }
  const existingAppointment = await Appointment.findOne({
      doctor: doctorId,
      date: new Date(date),
      startTime,
      status: { $in: ['pending', 'confirmed'] }
  });

  if (existingAppointment) {
      throw new ApiError(400, 'Khe thời gian này đã có lịch hẹn.');
  }
 
  const appointment = await Appointment.create({
    user: userId,
    doctor: doctorId,
    date: new Date(date),
    startTime,
    reason,
    status: 'pending',
  });

  return appointment.populate('user', 'fullName email phoneNumber');
};

export const getAppointments = async (userId, userRole, filter = {}) => {
  let query = {};

  if (userRole === 'user') {
    query.user = userId;
  } else if (userRole === 'doctor') {
    query.doctor = userId;
  }
  

  query = { ...query, ...filter };

  const appointments = await Appointment.find(query)
    .populate('user', 'fullName avatar')
    .populate('doctor', 'fullName specialty avatar')
    .sort({ date: 1, startTime: 1 });
    
  return appointments;
};


export const updateAppointmentStatus = async (appointmentId, status, updaterRole) => {
    if (updaterRole === 'user') {
        throw new ApiError(403, 'Người dùng không có quyền cập nhật trạng thái lịch hẹn.');
    }

    const appointment = await Appointment.findById(appointmentId);

    if (!appointment) {
        throw new ApiError(404, 'Không tìm thấy lịch hẹn.');
    }
    if (status === 'cancelled') {

    }
    
    appointment.status = status;
    await appointment.save();

    return appointment;
};