import { StatusCodes } from 'http-status-codes';
import { ApiError } from '../utils/ApiError.js'; // Nên dùng ApiError nếu có

/**
 * Middleware validation chung sử dụng Joi
 * @param {object} schema - Object chứa các Joi schema cho body, query, và/hoặc params
 */
const validationMiddleware = (schema) => (req, res, next) => {
  const validationOptions = {
    abortEarly: false, // Trả về tất cả lỗi, không dừng lại ở lỗi đầu tiên
    allowUnknown: true, // Cho phép các trường không được định nghĩa trong schema
    stripUnknown: true // Loại bỏ các trường không được định nghĩa
  };

  const validationResults = [];

  // Lặp qua body, query, params để tìm schema và data tương ứng
  ['params', 'query', 'body'].forEach((key) => {
    if (schema[key]) {
      // 1. Lấy dữ liệu từ request
      const dataToValidate = req[key]; 
      
      // 2. Thực hiện validate
      const { error, value } = schema[key].validate(dataToValidate, validationOptions);

      if (error) {
        validationResults.push(error);
      } else {
        // Ghi đè dữ liệu đã được làm sạch (stripped) trở lại req object
        // Điều này rất quan trọng để loại bỏ các trường không cần thiết và sử dụng dữ liệu hợp lệ
        req[key] = value;
      }
    }
  });

  if (validationResults.length > 0) {
    // Tổng hợp và trả về lỗi
    const errorDetails = validationResults.flatMap(err => 
        err.details.map(detail => ({ 
            field: detail.path.join('.'), 
            message: detail.message.replace(/['"]/g, ''), // Loại bỏ dấu nháy đơn
            type: detail.type 
        }))
    );

    // Trả về lỗi 400 Bad Request
    return res.status(StatusCodes.BAD_REQUEST).json({ 
        success: false,
        message: 'Dữ liệu request không hợp lệ.', 
        errors: errorDetails 
    });
  }


  next();
};

export default validationMiddleware;