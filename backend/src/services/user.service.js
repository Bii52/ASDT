import ApiError from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import { jwtGenerate, requestNewToken } from '~/utils/jwt'
import UserModel from '~/models/user.model.js'
import OTPModel from '~/models/OTP.model.js'
import RefreshTokenModel from '~/models/RefreshToken.model'
import sendMail from '~/utils/sendMail.js'
import sendSMS from '~/utils/sendSMS.js'

const register = async (userData) => {
  try {
    const { email, phoneNumber, fullName, password, avatar } = userData;

    // Email is now required by validation, so we can rely on it being present.
    let user = await UserModel.findOne({ email });

    if (user && user.emailVerified) {
      throw new ApiError(StatusCodes.CONFLICT, 'Email already exists and is verified.');
    }

    await OTPModel.deleteMany({ email, type: 'registration' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpData = {
      email,
      otp,
      type: 'registration',
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      registrationData: {
        fullName,
        password,
        avatar,
        email,
        phoneNumber // Keep phoneNumber if provided as optional
      }
    };
    await OTPModel.create(otpData);

    await sendMail(email, 'Your OTP Code for Registration', `Your OTP code is ${otp}`);
    return { message: 'Registration successful. Please check your email for the OTP to verify your account.' };

  } catch (error) {
    if (error instanceof ApiError) throw error;
    console.error(error);
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Failed to register user');
  }
}

const verifyRegistration = async (verificationData) => {
  try {
    const { email, otp } = verificationData;

    const otpRecord = await OTPModel.findOne({ email, otp, type: 'registration', expiresAt: { $gt: new Date() } });

    if (!otpRecord) {
      throw new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid or expired OTP');
    }

    const { fullName, password, avatar, email: regEmail, phoneNumber: regPhone } = otpRecord.registrationData;

    // Since email is now required, we can simplify the user query
    let user = await UserModel.findOne({ email: regEmail });

    const userData = {
      fullName,
      password,
      avatar,
      email: regEmail,
      phoneNumber: regPhone,
      emailVerified: true, // Email is verified upon successful OTP
      phoneVerified: !!regPhone
    };

    if (user) {
      Object.assign(user, userData);
    } else {
      user = new UserModel(userData);
    }

    await user.save();

    await OTPModel.deleteOne({ _id: otpRecord._id });
    return { message: 'Account verified successfully. You can now log in.' };
  } catch (error) {
    if (error instanceof ApiError) throw error;
    if (error.code === 11000) {
      // Since we only use email now, the identifier is always 'Email'
      throw new ApiError(StatusCodes.CONFLICT, 'Email already exists.');
    }
    console.error(error);
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Failed to verify account');
  }
}

const sendPasswordResetOTP = async (email) => {
  try {
    const user = await UserModel.findOne({ email });
    if (!user || !user.emailVerified) {
      throw new ApiError(StatusCodes.NOT_FOUND, 'User not found or email not verified');
    }

    await OTPModel.deleteMany({ email: email, type: 'password-reset' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpData = { email, otp, type: 'password-reset', expiresAt: new Date(Date.now() + 5 * 60 * 1000) };
    await OTPModel.create(otpData);

    await sendMail(email, 'Your Password Reset OTP', `Your OTP code for password reset is ${otp}`);

    return { message: 'Password reset OTP sent successfully.' };
  } catch (error) {
    if (error instanceof ApiError) throw error;
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Failed to send password reset OTP');
  }
}

const login = async (loginData) => {
  try {
    const user = await UserModel.findOne({ email: loginData.email })
      .select('_id role email fullName +password banned emailVerified loginHistory')
    if (!user) {
      throw new ApiError(StatusCodes.NOT_FOUND, 'User with this email not found.')
    }
    if (!user.emailVerified) {
      throw new ApiError(StatusCodes.FORBIDDEN, 'Please verify your email before logging in.')
    }
    const isPasswordValid = await user.comparePassword(String(loginData.password).trim())
    if (!isPasswordValid) {
      throw new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid password.')
    }
    if (user.banned) {
      throw new ApiError(StatusCodes.FORBIDDEN, 'Your account has been banned')
    }

    const { AccessToken, RefreshToken } = jwtGenerate({ id: user._id, email: user.email, role: user.role })

    await RefreshTokenModel.create({ userId: user._id, token: RefreshToken })

    await user.saveLog(loginData.ipAddress, loginData.device)
    const userData = {
      userId: user._id,
      role: user.role,
      email: user.email,
      fullName: user.fullName
    }
    return { userData, accessToken: AccessToken, refreshToken: RefreshToken }
  } catch (error) {
    throw error
  }
}

// ... (the rest of the file is unchanged)

const queryUsers = async (filter, options) => {
  const users = await UserModel.paginate(filter, options);
  return users;
};

const getUserById = async (userId) => {
  return UserModel.findById(userId);
};

const updateUserById = async (userId, updateBody) => {
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found');
  }
  if (updateBody.email && (await UserModel.isEmailTaken(updateBody.email, userId))) {
    throw new ApiError(StatusCodes.BAD_REQUEST, 'Email already taken');
  }
  Object.assign(user, updateBody);
  await user.save();
  return user;
};

const deleteUserById = async (userId) => {
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found');
  }
  await user.remove();
  return user;
};

export const userService = {
  register,
  verifyRegistration, // renamed from verifyEmail
  login,
  queryUsers,
  getUserById,
  updateUserById,
  deleteUserById
}
