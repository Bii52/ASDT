import { StatusCodes } from 'http-status-codes'
import { adminService } from '~/services/admin.service.js'
import catchAsync from '~/utils/catchAsync'
import ApiError from '~/utils/ApiError'
import pick from '~/utils/pick'

// Quản lý người dùng
const getUsers = catchAsync(async (req, res) => {
  const filter = pick(req.query, ['role', 'emailVerified', 'phoneVerified'])
  const options = pick(req.query, ['sortBy', 'limit', 'page'])
  const result = await adminService.queryUsers(filter, options)
  res.status(StatusCodes.OK).json({
    success: true,
    data: result
  })
})

const getUserById = catchAsync(async (req, res) => {
  const user = await adminService.getUserById(req.params.userId)
  if (!user) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
  }
  res.status(StatusCodes.OK).json({
    success: true,
    data: user
  })
})

const updateUser = catchAsync(async (req, res) => {
  const user = await adminService.updateUserById(req.params.userId, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: user
  })
})

const deleteUser = catchAsync(async (req, res) => {
  await adminService.deleteUserById(req.params.userId)
  res.status(StatusCodes.NO_CONTENT).send()
})

const lockUser = catchAsync(async (req, res) => {
  const user = await adminService.lockUser(req.params.userId, req.body.reason)
  res.status(StatusCodes.OK).json({
    success: true,
    data: user
  })
})

const unlockUser = catchAsync(async (req, res) => {
  const user = await adminService.unlockUser(req.params.userId)
  res.status(StatusCodes.OK).json({
    success: true,
    data: user
  })
})

// Duyệt hồ sơ bác sĩ
const getPendingDoctors = catchAsync(async (req, res) => {
  const doctors = await adminService.getPendingDoctors()
  res.status(StatusCodes.OK).json({
    success: true,
    data: doctors
  })
})

const approveDoctor = catchAsync(async (req, res) => {
  const doctor = await adminService.approveDoctor(req.params.doctorId, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: doctor
  })
})

const rejectDoctor = async (req, res) => {
  const doctor = await adminService.rejectDoctor(req.params.doctorId, req.body.reason)
  res.status(StatusCodes.OK).json({
    success: true,
    data: doctor
  })
}

const createDoctor = catchAsync(async (req, res) => {
  const doctor = await adminService.createDoctor(req.body)
  res.status(StatusCodes.CREATED).json({
    success: true,
    data: doctor
  })
})

// Giám sát dữ liệu thuốc
const getProductsForReview = catchAsync(async (req, res) => {
  const products = await adminService.getProductsForReview(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: products
  })
})

const approveProduct = catchAsync(async (req, res) => {
  const product = await adminService.approveProduct(req.params.productId)
  res.status(StatusCodes.OK).json({
    success: true,
    data: product
  })
})

const rejectProduct = catchAsync(async (req, res) => {
  const product = await adminService.rejectProduct(req.params.productId, req.body.reason)
  res.status(StatusCodes.OK).json({
    success: true,
    data: product
  })
})

const getProducts = catchAsync(async (req, res) => {
  const filter = pick(req.query, ['name', 'category', 'adminApproved'])
  const options = pick(req.query, ['sortBy', 'limit', 'page'])
  const result = await adminService.getProducts(filter, options)
  res.status(StatusCodes.OK).json({
    success: true,
    data: result
  })
})

// Quản lý bài viết/tin tức
const createArticle = catchAsync(async (req, res) => {
  const article = await adminService.createArticle(req.body)
  res.status(StatusCodes.CREATED).json({
    success: true,
    data: article
  })
})

const getArticles = catchAsync(async (req, res) => {
  const articles = await adminService.getArticles(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: articles
  })
})

const updateArticle = catchAsync(async (req, res) => {
  const article = await adminService.updateArticle(req.params.articleId, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: article
  })
})

const deleteArticle = catchAsync(async (req, res) => {
  await adminService.deleteArticle(req.params.articleId)
  res.status(StatusCodes.NO_CONTENT).send()
})

const toggleArticleVisibility = catchAsync(async (req, res) => {
  const article = await adminService.toggleArticleVisibility(req.params.articleId)
  res.status(StatusCodes.OK).json({
    success: true,
    data: article
  })
})

// Giám sát chat/báo cáo
const getReports = catchAsync(async (req, res) => {
  const reports = await adminService.getReports(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: reports
  })
})

const handleReport = catchAsync(async (req, res) => {
  const report = await adminService.handleReport(req.params.reportId, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: report
  })
})

// Cấu hình hệ thống
const getSystemConfig = catchAsync(async (req, res) => {
  const config = await adminService.getSystemConfig()
  res.status(StatusCodes.OK).json({
    success: true,
    data: config
  })
})

const updateSystemConfig = catchAsync(async (req, res) => {
  const config = await adminService.updateSystemConfig(req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: config
  })
})

const getRoles = catchAsync(async (req, res) => {
  const roles = await adminService.getRoles()
  res.status(StatusCodes.OK).json({
    success: true,
    data: roles
  })
})

const updateRolePermissions = catchAsync(async (req, res) => {
  const role = await adminService.updateRolePermissions(req.params.roleId, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: role
  })
})

// Dashboard tổng quan
const getDashboard = catchAsync(async (req, res) => {
  const dashboard = await adminService.getDashboard()
  res.status(StatusCodes.OK).json({
    success: true,
    data: dashboard
  })
})

const getStatistics = catchAsync(async (req, res) => {
  const stats = await adminService.getStatistics(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: stats
  })
})

export const adminController = {
  // User Management
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  lockUser,
  unlockUser,
  
  // Doctor Approval
  getPendingDoctors,
  approveDoctor,
  rejectDoctor,
  createDoctor,
  
  // Product Monitoring
  getProducts,
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
