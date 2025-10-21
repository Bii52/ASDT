import { StatusCodes } from 'http-status-codes'
import { userService } from '~/services/user.service.js'
import UserModel from '~/models/user.model.js'
import catchAsync from '~/utils/catchAsync'
import pick from '~/utils/pick'
import ApiError from '~/utils/ApiError'
import httpStatus from 'http-status-codes'

const register = async (req, res, next) => {
  try {
    const result = await userService.register(req.body)

    res.status(StatusCodes.CREATED).json({
      success: true,
      message: result.message
    })
  } catch (error) {
    next(error)
  }
}

const verifyRegistration = async (req, res, next) => {
  try {
    const result = await userService.verifyRegistration(req.body);
    res.status(StatusCodes.OK).json({
      success: true,
      message: result.message
    });
  } catch (error) {
    next(error);
  }
};

const sendPasswordResetOTP = async (req, res, next) => {
  try {
    const result = await userService.sendPasswordResetOTP(req.body.email);
    res.status(StatusCodes.OK).json({
      success: true,
      message: result.message
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { userData, accessToken, refreshToken } = await userService.login({
      ...req.body,
      ipAddress: req.ip,
      device: req.headers['user-agent']
    })

    let updatedUser = null
    if (userData && userData.userId) {
      updatedUser = await UserModel.findByIdAndUpdate(
        userData.userId,
        { $inc: { loginCount: 1 } },
        { new: true }
      ).select('firstName lastName email avatar role loginCount')
    }

    res.status(StatusCodes.OK).json({
      success: true,
      message: 'Đăng nhập thành công',
      user: updatedUser || userData,
      accessToken,
      refreshToken
    })
  } catch (error) {
    next(error)
  }
}


const logout = async (req, res, next) => {
  try {
    const userId = req.user.id // Assuming user ID is stored in req.user by verifyToken middleware
    await userService.revokeRefreshToken(userId)

    res.status(StatusCodes.OK).json({
      success: true,
      message: 'Đăng xuất thành công'
    })
  } catch (error) {
    next(error)
  }
}

const requestToken = async (req, res, next) => {
  try {
    const newToken = await userService.requestToken(req.body)
    res.status(StatusCodes.OK).json({
      success: true,
      accessToken: newToken
    })
  } catch (error) {
    next(error)
  }
}


const changePassword = async (req, res, next) => {
  try {
    const userId = req.user.id // Assuming user ID is stored in req.user by verifyToken middleware
    await userService.changePassword(userId, req.body)

    res.status(StatusCodes.OK).json({
      success: true,
      message: 'Đổi mật khẩu thành công'
    })
  } catch (error) {
    next(error)
  }
}

const getProfile = async (req, res, next) => {
  try {
    const userId = req?.query?.userId || req.user.id || req.user._id || req.user.userId
    const profile = await userService.getUserProfile(userId)
    res.status(StatusCodes.OK).json({
      success: true,
      user: profile
    });
  } catch (error) {
    next(error)
  }
}

const getUserDetails = async (req, res, next) => {
  try {
    const userId = req.params.id
    const userDetails = await userService.getUserDetails(userId)
    res.status(StatusCodes.OK).json({
      success: true,
      user: userDetails
    })
  } catch (error) {
    next(error)
  }
}





const resetPassword = async (req, res, next) => {
  try {
    await userService.resetPassword(req.body)
    res.status(StatusCodes.OK).json({
      success: true,
      message: 'Password reset successfully'
    })
  } catch (error) {
    next(error)
  }
}


const getOutstandingBloggers = async (req, res, next) => {
  try {
    const outstandingBloggers = await userService.getOutstandingBloggers()
    res.status(StatusCodes.OK).json({
      success: true,
      data: outstandingBloggers
    })
  } catch (error) {
    next(error)
  }
}


const oAuthLoginCallback = async (req, res, next) => {
  try {
    const { accessToken, refreshToken } = await userService.handleOAuthLogin(
      req.user,
      req.ip,
      req.headers['user-agent']
    )

    // Chuyển hướng đến CLIENT_URL với tokens dưới dạng query params
    const redirectUrl = `${process.env.CLIENT_URL || 'http://localhost:3000'}?accessToken=${accessToken}&refreshToken=${refreshToken}`
    res.redirect(redirectUrl)
  } catch (error) {
    // Nếu có lỗi, chuyển hướng đến trang lỗi đăng nhập trên client
    const failureRedirectUrl = `${process.env.CLIENT_URL || 'http://localhost:3000'}/login-failure`
    res.redirect(failureRedirectUrl)
  }
}



const adminTest = (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'Admin content' });
};

const doctorTest = (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'Doctor content' });
};

const getUsers = catchAsync(async (req, res) => {
  const filter = pick(req.query, ['name', 'role']);
  const options = pick(req.query, ['sortBy', 'limit', 'page']);
  const result = await userService.queryUsers(filter, options);
  res.send(result);
});

const getUser = catchAsync(async (req, res) => {
  const user = await userService.getUserById(req.params.userId);
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, 'User not found');
  }
  res.send(user);
});

const updateUser = catchAsync(async (req, res) => {
  const user = await userService.updateUserById(req.params.userId, req.body);
  res.send(user);
});

const deleteUser = catchAsync(async (req, res) => {
  await userService.deleteUserById(req.params.userId);
  res.status(httpStatus.NO_CONTENT).send();
});

export const userController = {
  register,
  login,
  logout,
  resetPassword,
  requestToken,
  getUserDetails,
  changePassword,
  sendPasswordResetOTP,
  getProfile,
  verifyRegistration,
  oAuthLoginCallback,
  adminTest,
  doctorTest,
  getUsers,
  getUser,
  updateUser,
  deleteUser
}