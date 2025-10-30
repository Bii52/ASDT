import { StatusCodes } from 'http-status-codes';

const uploadAvatar = (req, res) => {
  res.status(StatusCodes.OK).json({
    success: true,
    message: 'Avatar uploaded successfully',
    avatarUrl: req.cloudinaryUrl,
  });
};

export const uploadController = {
  uploadAvatar,
};