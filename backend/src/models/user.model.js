import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import mongoosePaginate from 'mongoose-paginate-v2';


const LoginHistorySchema = new mongoose.Schema({
  ipAddress: { type: String },
  device: { type: String },
  loggedInAt: { type: Date, default: Date.now }
});

const WorkingHourSchema = new mongoose.Schema({
    dayOfWeek: {
        type: String,
        enum: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        required: true,
    },
    startTime: {
        type: String, 
        required: true,
    },
    endTime: {
        type: String, // Ví dụ: "17:00"
        required: true,
    },
    slotDuration: {
        type: Number, // Thời lượng mỗi khe (phút), ví dụ: 30
        default: 30
    }
}, { _id: false }); // Không tạo _id cho các sub-document này

const UserSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false 
  },
  avatar: {
    type: String,
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'doctor', 'pharmacist'],
    default: 'user',
  },
  emailVerified: {
    type: Boolean,
    default: false,
  },
  phoneVerified: {
    type: Boolean,
    default: false,
  },


  specialty: {
    type: String,
    trim: true,
    required: function() {
      return this.role === 'doctor';
    },
  },
  bio: {
    type: String,
    trim: true,
    maxlength: 500,
  },
  licenseNumber: {
    type: String,
    unique: true,
    sparse: true,
    required: function() {
      return this.role === 'doctor';
    },
  },
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  totalRatings: { 
    type: Number,
    default: 0,
  },
  workingHours: [WorkingHourSchema],

  // Pharmacist specific fields
  pharmacyName: {
    type: String,
    trim: true,
    required: function() {
      return this.role === 'pharmacist';
    },
  },
  pharmacyLicense: {
    type: String,
    unique: true,
    sparse: true,
    required: function() {
      return this.role === 'pharmacist';
    },
  },
  pharmacyAddress: {
    type: String,
    trim: true,
  },

  loginCount: {
    type: Number,
    default: 0
  },
  loginHistory: [LoginHistorySchema]
}, { timestamps: true });

// Plugin cho phân trang
UserSchema.plugin(mongoosePaginate);

// Middleware: Mã hóa mật khẩu trước khi lưu
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
  if (this.loginHistory.length > 10) { 
    this.loginHistory.shift();
  }
  return this.save();
};

UserSchema.statics.isEmailTaken = async function (email, excludeUserId) {
  const user = await this.findOne({ email, _id: { $ne: excludeUserId } });
  return !!user;
};

export default mongoose.models.User || mongoose.model('User', UserSchema);