const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const LoginHistorySchema = new mongoose.Schema({
  ipAddress: { type: String },
  device: { type: String },
  loggedInAt: { type: Date, default: Date.now }
});

const UserSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: true,
  },
  lastName: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    unique: true,
    required: true,
    trim: true,
    lowercase: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false // Do not return password by default
  },
  avatar: {
    type: String,
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'doctor'],
    default: 'user',
  },
  emailVerified: {
    type: Boolean,
    default: false,
  },
  banned: {
    type: Boolean,
    default: false,
  },
  loginCount: {
    type: Number,
    default: 0
  },
  loginHistory: [LoginHistorySchema]
}, { timestamps: true });

UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

UserSchema.methods.comparePassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

UserSchema.methods.saveLog = async function (ipAddress, device) {
  this.loginHistory.push({ ipAddress, device });
  if (this.loginHistory.length > 10) { // Keep last 10 logins
    this.loginHistory.shift();
  }
  return this.save();
};

module.exports = mongoose.models.User || mongoose.model('User', UserSchema);