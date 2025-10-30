# HealthCare App - Hệ thống chăm sóc sức khỏe

## Tổng quan
Ứng dụng chăm sóc sức khỏe với đầy đủ 4 vai trò: User, Doctor, Pharmacist, Admin.

## Cấu trúc dự án

### Backend (Node.js + Express + MongoDB)
```
backend/
├── src/
│   ├── controllers/     # Controllers cho từng role
│   ├── services/        # Business logic
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── middlewares/     # Authentication, validation
│   └── validations/     # Input validation
```

### Frontend (Flutter)
```
frontend/
├── lib/
│   ├── features/        # Features theo role
│   │   ├── auth/        # Authentication
│   │   ├── dashboard/   # User dashboard
│   │   ├── doctor_dashboard/  # Doctor features
│   │   ├── pharmacist/  # Pharmacist features
│   │   ├── admin/       # Admin features
│   │   └── test/        # Test pages
│   ├── services/        # API services
│   └── router.dart      # Navigation routing
```

## Các vai trò và tính năng

### 1. User (Người dùng)
- ✅ Đăng ký/Đăng nhập (Email, Google, Facebook, OTP)
- ✅ Trang chủ với gợi ý bác sĩ, bài viết, thuốc nổi bật
- ✅ Tra cứu thuốc với thông tin chi tiết
- ✅ Quét mã QR thuốc
- ✅ Nhắc uống thuốc
- ✅ Đặt lịch hẹn bác sĩ
- ✅ Chat/Video với bác sĩ
- ✅ Hồ sơ cá nhân
- ✅ Xem bài viết/tin tức y tế
- ✅ Cài đặt & đăng xuất

### 2. Doctor (Bác sĩ)
- ✅ Đăng nhập/Quản lý tài khoản
- ✅ Quản lý lịch hẹn (xem, xác nhận, từ chối)
- ✅ Chat/Video tư vấn
- ✅ Xem hồ sơ bệnh nhân
- ✅ Kê thuốc (gợi ý từ MongoDB)
- ✅ Thống kê khám bệnh
- ✅ Cài đặt & hồ sơ bác sĩ

### 3. Pharmacist (Dược sĩ)
- ✅ Quản lý danh mục thuốc (CRUD)
- ✅ Quản lý sản phẩm thuốc (CRUD)
- ✅ Kiểm tra mã QR thuốc
- ✅ Đồng bộ dữ liệu thuốc (Crawler)
- ✅ Kiểm tra tồn kho/Cập nhật giá
- ✅ Thống kê thuốc bán chạy
- ✅ Dashboard tổng quan

### 4. Admin (Quản trị viên)
- ✅ Quản lý người dùng (khóa, mở khóa, xóa)
- ✅ Duyệt hồ sơ bác sĩ
- ✅ Giám sát dữ liệu thuốc
- ✅ Quản lý bài viết/tin tức
- ✅ Giám sát chat/báo cáo
- ✅ Cấu hình hệ thống
- ✅ Dashboard tổng quan với thống kê

## API Endpoints

### Authentication
- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập
- `POST /auth/logout` - Đăng xuất
- `POST /auth/verify-registration` - Xác minh đăng ký

### User Routes
- `GET /auth/profile` - Lấy thông tin profile
- `PUT /auth/profile` - Cập nhật profile

### Doctor Routes
- `GET /auth/doctors` - Lấy danh sách bác sĩ
- `GET /auth/doctors/online` - Lấy bác sĩ online

### Pharmacist Routes
- `GET /pharmacist/dashboard` - Dashboard dược sĩ
- `GET /pharmacist/categories` - Danh sách danh mục
- `POST /pharmacist/categories` - Tạo danh mục
- `GET /pharmacist/products` - Danh sách sản phẩm
- `POST /pharmacist/products` - Tạo sản phẩm
- `POST /pharmacist/validate-qr` - Kiểm tra QR code
- `POST /pharmacist/sync-data` - Đồng bộ dữ liệu
- `GET /pharmacist/stats/bestselling` - Thống kê bán chạy

### Admin Routes
- `GET /admin/dashboard` - Dashboard admin
- `GET /admin/users` - Quản lý người dùng
- `GET /admin/doctors/pending` - Bác sĩ chờ duyệt
- `PUT /admin/doctors/:id/approve` - Duyệt bác sĩ
- `GET /admin/products/review` - Sản phẩm chờ duyệt
- `GET /admin/config` - Cấu hình hệ thống

## Cài đặt và chạy

### Backend
```bash
cd backend
npm install
npm start
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```



## Cấu trúc Database

### User Model
```javascript
{
  fullName: String,
  email: String,
  phoneNumber: String,
  avatar: String,
  role: ['user', 'doctor', 'pharmacist', 'admin'],
  emailVerified: Boolean,
  phoneVerified: Boolean,
  
  // Doctor fields
  specialty: String,
  bio: String,
  licenseNumber: String,
  averageRating: Number,
  totalRatings: Number,
  workingHours: Array,
  
  // Pharmacist fields
  pharmacyName: String,
  pharmacyLicense: String,
  pharmacyAddress: String,
  
  // System fields
  loginCount: Number,
  loginHistory: Array,
  createdAt: Date,
  updatedAt: Date
}
```

### Product Model
```javascript
{
  name: String,
  description: String,
  price: Number,
  category: ObjectId,
  qrCode: String,
  inStock: Number,
  sideEffects: String,
  dosage: String,
  manufacturer: String,
  expiryDate: Date,
  ingredients: Array,
  images: Array,
  adminApproved: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Category Model
```javascript
{
  name: String,
  description: String,
  image: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Tính năng nổi bật

1. **Phân quyền đầy đủ**: Mỗi role có quyền truy cập riêng biệt
2. **Real-time chat**: Socket.io cho chat giữa user và doctor
3. **QR Code scanning**: Quét mã QR để tra cứu thông tin thuốc
4. **Data synchronization**: Crawler tự động đồng bộ dữ liệu thuốc
5. **Comprehensive dashboard**: Dashboard chi tiết cho từng role
6. **Mobile-first design**: Giao diện tối ưu cho mobile
7. **Role-based routing**: Điều hướng tự động theo vai trò

## Công nghệ sử dụng

### Backend
- Node.js + Express.js
- MongoDB + Mongoose
- JWT Authentication
- Socket.io (Real-time chat)
- Passport.js (OAuth)
- Nodemailer (Email)
- Twilio (SMS)

### Frontend
- Flutter
- Riverpod (State management)
- Go Router (Navigation)
- HTTP (API calls)
- Shared Preferences (Local storage)
- QR Code Scanner
- Charts (Statistics)

## Liên hệ
Để được hỗ trợ hoặc báo cáo lỗi, vui lòng liên hệ qua email: admin@healthcare.com
