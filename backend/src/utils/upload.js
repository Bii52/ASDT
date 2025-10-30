import multer from 'multer';
import { cloudinary } from '~/config/cloudinary.js';
import ApiError from '~/utils/ApiError.js';
import { StatusCodes } from 'http-status-codes';

// Configure Multer for memory storage
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Middleware to upload a single image to Cloudinary
const uploadImage = (fieldName) => async (req, res, next) => {
  upload.single(fieldName)(req, res, async (err) => {
    if (err) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, err.message));
    }
    if (!req.file) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'No file uploaded.'));
    }

    try {
      const b64 = Buffer.from(req.file.buffer).toString('base64');
      let dataURI = 'data:' + req.file.mimetype + ';base64,' + b64;
      const result = await cloudinary.uploader.upload(dataURI, {
        folder: 'avatars', // Optional: specify a folder in Cloudinary
      });
      req.cloudinaryUrl = result.secure_url;
      next();
    } catch (error) {
      console.error('Cloudinary upload error:', error);
      return next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Failed to upload image to Cloudinary.'));
    }
  });
};

export { uploadImage };