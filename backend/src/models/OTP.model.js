import mongoose from 'mongoose';

const otpSchema = new mongoose.Schema({
  email: {
    type: String,
    trim: true,
    lowercase: true
  },
  phoneNumber: {
    type: String,
    trim: true,
  },
  otp: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    required: true,
    enum: ['registration', 'password-reset', 'general']
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 300 // 5 minutes
  },
  expiresAt: {
    type: Date,
    default: () => Date.now() + 5 * 60 * 1000, // 5 minutes from creation
  },
  registrationData: {
    fullName: { type: String },
    email: { type: String },
    password: { type: String },
    avatar: { type: String },
    phoneNumber: { type: String }
  }
});

otpSchema.pre('save', function(next) {
  if (!this.email && !this.phoneNumber) {
    next(new Error('Either email or phone number must be provided.'));
  } else {
    next();
  }
});

otpSchema.methods.verifyOTP = async function () {
  try {
    this.isVerified = true
    await this.save()
  } catch (error) {
    throw new Error('Failed to verify OTP')
  }
};

const OTPModel = mongoose.model('otps', otpSchema);

export default OTPModel;
