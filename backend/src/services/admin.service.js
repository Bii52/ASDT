import { StatusCodes } from 'http-status-codes'
import UserModel from '~/models/user.model.js'
import ProductModel from '~/models/Product.model.js'
import CategoryModel from '~/models/Category.model.js'
import ApiError from '~/utils/ApiError'
import pick from '~/utils/pick'

// User Management
const queryUsers = async (filter, options) => {
  const result = await UserModel.paginate(filter, options)
  return result
}

const getUserById = async (userId) => {
  const user = await UserModel.findById(userId)
  return user
}

const updateUserById = async (userId, updateBody) => {
  const user = await UserModel.findByIdAndUpdate(userId, updateBody, { new: true, runValidators: true })
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
  }
  return user
}

const deleteUserById = async (userId) => {
  const user = await UserModel.findByIdAndDelete(userId)
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
  }
  return user
}

const lockUser = async (userId, reason) => {
  const user = await UserModel.findByIdAndUpdate(
    userId,
    { 
      isLocked: true, 
      lockReason: reason,
      lockedAt: new Date()
    },
    { new: true, runValidators: true }
  )
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
  }
  return user
}

const unlockUser = async (userId) => {
  const user = await UserModel.findByIdAndUpdate(
    userId,
    { 
      isLocked: false, 
      lockReason: null,
      lockedAt: null
    },
    { new: true, runValidators: true }
  )
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
  }
  return user
}

// Doctor Approval
const getPendingDoctors = async () => {
  const doctors = await UserModel.find({
    role: 'doctor',
    $or: [
      { doctorStatus: 'pending' },
      { doctorStatus: { $exists: false } }
    ]
  }).select('-password')
  
  return doctors
}

const approveDoctor = async (doctorId, approvalData) => {
  const doctor = await UserModel.findByIdAndUpdate(
    doctorId,
    {
      doctorStatus: 'approved',
      approvedAt: new Date(),
      approvedBy: approvalData.approvedBy,
      approvalNotes: approvalData.notes
    },
    { new: true, runValidators: true }
  ).select('-password')
  
  if (!doctor) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Doctor not found')
  }
  
  return doctor
}

const rejectDoctor = async (doctorId, reason) => {
  const doctor = await UserModel.findByIdAndUpdate(
    doctorId,
    {
      doctorStatus: 'rejected',
      rejectedAt: new Date(),
      rejectionReason: reason
    },
    { new: true, runValidators: true }
  ).select('-password')
  
  if (!doctor) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Doctor not found')
  }
  
  return doctor
}

// Product Monitoring
const getProductsForReview = async (query) => {
  const filter = {
    $or: [
      { adminApproved: false },
      { adminApproved: { $exists: false } }
    ]
  }
  
  const options = {
    page: parseInt(query.page) || 1,
    limit: parseInt(query.limit) || 10,
    sort: query.sort || '-createdAt',
    populate: 'category'
  }
  
  const result = await ProductModel.paginate(filter, options)
  return result
}

const approveProduct = async (productId) => {
  const product = await ProductModel.findByIdAndUpdate(
    productId,
    {
      adminApproved: true,
      approvedAt: new Date()
    },
    { new: true, runValidators: true }
  ).populate('category')
  
  if (!product) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Product not found')
  }
  
  return product
}

const rejectProduct = async (productId, reason) => {
  const product = await ProductModel.findByIdAndUpdate(
    productId,
    {
      adminApproved: false,
      rejectionReason: reason,
      rejectedAt: new Date()
    },
    { new: true, runValidators: true }
  ).populate('category')
  
  if (!product) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Product not found')
  }
  
  return product
}

// Article Management (Mock implementation - you can create Article model later)
const createArticle = async (articleData) => {
  // Mock implementation
  const article = {
    _id: new Date().getTime().toString(),
    ...articleData,
    createdAt: new Date(),
    updatedAt: new Date(),
    isPublished: true
  }
  return article
}

const getArticles = async (query) => {
  // Mock implementation
  const articles = {
    docs: [],
    totalDocs: 0,
    limit: parseInt(query.limit) || 10,
    page: parseInt(query.page) || 1,
    totalPages: 0
  }
  return articles
}

const updateArticle = async (articleId, updateData) => {
  // Mock implementation
  const article = {
    _id: articleId,
    ...updateData,
    updatedAt: new Date()
  }
  return article
}

const deleteArticle = async (articleId) => {
  // Mock implementation
  return { _id: articleId }
}

const toggleArticleVisibility = async (articleId) => {
  // Mock implementation
  const article = {
    _id: articleId,
    isPublished: true,
    updatedAt: new Date()
  }
  return article
}

// Report Management (Mock implementation)
const getReports = async (query) => {
  // Mock implementation
  const reports = {
    docs: [],
    totalDocs: 0,
    limit: parseInt(query.limit) || 10,
    page: parseInt(query.page) || 1,
    totalPages: 0
  }
  return reports
}

const handleReport = async (reportId, handleData) => {
  // Mock implementation
  const report = {
    _id: reportId,
    status: 'handled',
    handledAt: new Date(),
    ...handleData
  }
  return report
}

// System Configuration
const getSystemConfig = async () => {
  // Mock implementation - you can create SystemConfig model later
  const config = {
    siteName: 'HealthCare App',
    siteDescription: 'Ứng dụng chăm sóc sức khỏe',
    contactEmail: 'admin@healthcare.com',
    contactPhone: '0123456789',
    maintenanceMode: false,
    allowRegistration: true,
    requireEmailVerification: true,
    maxFileSize: 10485760, // 10MB
    allowedFileTypes: ['jpg', 'jpeg', 'png', 'pdf'],
    systemRoles: ['user', 'doctor', 'pharmacist', 'admin']
  }
  return config
}

const updateSystemConfig = async (configData) => {
  // Mock implementation
  const config = {
    ...configData,
    updatedAt: new Date()
  }
  return config
}

const getRoles = async () => {
  const roles = [
    {
      name: 'user',
      displayName: 'Người dùng',
      permissions: ['view_products', 'book_appointments', 'chat_with_doctor']
    },
    {
      name: 'doctor',
      displayName: 'Bác sĩ',
      permissions: ['manage_appointments', 'view_patients', 'prescribe_medicines', 'chat_with_patients']
    },
    {
      name: 'pharmacist',
      displayName: 'Dược sĩ',
      permissions: ['manage_products', 'manage_categories', 'validate_qr', 'sync_data']
    },
    {
      name: 'admin',
      displayName: 'Quản trị viên',
      permissions: ['manage_users', 'approve_doctors', 'monitor_products', 'manage_articles', 'system_config']
    }
  ]
  return roles
}

const updateRolePermissions = async (roleId, permissions) => {
  // Mock implementation
  const role = {
    _id: roleId,
    permissions: permissions,
    updatedAt: new Date()
  }
  return role
}

// Dashboard & Statistics
const getDashboard = async () => {
  const totalUsers = await UserModel.countDocuments({ role: 'user' })
  const totalDoctors = await UserModel.countDocuments({ role: 'doctor' })
  const totalPharmacists = await UserModel.countDocuments({ role: 'pharmacist' })
  const totalProducts = await ProductModel.countDocuments()
  const totalCategories = await CategoryModel.countDocuments()
  
  const pendingDoctors = await UserModel.countDocuments({
    role: 'doctor',
    $or: [
      { doctorStatus: 'pending' },
      { doctorStatus: { $exists: false } }
    ]
  })
  
  const pendingProducts = await ProductModel.countDocuments({
    $or: [
      { adminApproved: false },
      { adminApproved: { $exists: false } }
    ]
  })
  
  const recentUsers = await UserModel.find({ role: 'user' })
    .sort({ createdAt: -1 })
    .limit(5)
    .select('fullName email createdAt')
  
  const recentDoctors = await UserModel.find({ role: 'doctor' })
    .sort({ createdAt: -1 })
    .limit(5)
    .select('fullName email specialty createdAt')
  
  return {
    summary: {
      totalUsers,
      totalDoctors,
      totalPharmacists,
      totalProducts,
      totalCategories,
      pendingDoctors,
      pendingProducts
    },
    recentUsers,
    recentDoctors
  }
}

const getStatistics = async (query) => {
  const { period = 'month' } = query
  
  const now = new Date()
  let startDate
  
  switch (period) {
    case 'week':
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      break
    case 'month':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1)
      break
    case 'year':
      startDate = new Date(now.getFullYear(), 0, 1)
      break
    default:
      startDate = new Date(now.getFullYear(), now.getMonth(), 1)
  }
  
  const userStats = await UserModel.aggregate([
    {
      $match: {
        createdAt: { $gte: startDate },
        role: 'user'
      }
    },
    {
      $group: {
        _id: {
          $dateToString: {
            format: period === 'week' ? '%Y-%m-%d' : period === 'month' ? '%Y-%m' : '%Y',
            date: '$createdAt'
          }
        },
        count: { $sum: 1 }
      }
    },
    { $sort: { _id: 1 } }
  ])
  
  const doctorStats = await UserModel.aggregate([
    {
      $match: {
        createdAt: { $gte: startDate },
        role: 'doctor'
      }
    },
    {
      $group: {
        _id: {
          $dateToString: {
            format: period === 'week' ? '%Y-%m-%d' : period === 'month' ? '%Y-%m' : '%Y',
            date: '$createdAt'
          }
        },
        count: { $sum: 1 }
      }
    },
    { $sort: { _id: 1 } }
  ])
  
  return {
    period,
    userStats,
    doctorStats
  }
}

export const adminService = {
  // User Management
  queryUsers,
  getUserById,
  updateUserById,
  deleteUserById,
  lockUser,
  unlockUser,
  
  // Doctor Approval
  getPendingDoctors,
  approveDoctor,
  rejectDoctor,
  
  // Product Monitoring
  getProductsForReview,
  approveProduct,
  rejectProduct,
  
  // Article Management
  createArticle,
  getArticles,
  updateArticle,
  deleteArticle,
  toggleArticleVisibility,
  
  // Report Management
  getReports,
  handleReport,
  
  // System Configuration
  getSystemConfig,
  updateSystemConfig,
  getRoles,
  updateRolePermissions,
  
  // Dashboard & Statistics
  getDashboard,
  getStatistics
}
