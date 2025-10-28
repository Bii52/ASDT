import { StatusCodes } from 'http-status-codes'
import { pharmacistService } from '~/services/pharmacist.service.js'
import catchAsync from '~/utils/catchAsync'
import ApiError from '~/utils/ApiError'

// Quản lý danh mục thuốc
const createCategory = catchAsync(async (req, res) => {
  const category = await pharmacistService.createCategory(req.body)
  res.status(StatusCodes.CREATED).json({
    success: true,
    data: category
  })
})

const getCategories = catchAsync(async (req, res) => {
  const categories = await pharmacistService.getCategories(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: categories
  })
})

const updateCategory = catchAsync(async (req, res) => {
  const category = await pharmacistService.updateCategory(req.params.id, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: category
  })
})

const deleteCategory = catchAsync(async (req, res) => {
  await pharmacistService.deleteCategory(req.params.id)
  res.status(StatusCodes.NO_CONTENT).send()
})

// Quản lý sản phẩm thuốc
const createProduct = catchAsync(async (req, res) => {
  const product = await pharmacistService.createProduct(req.body)
  res.status(StatusCodes.CREATED).json({
    success: true,
    data: product
  })
})

const getProducts = catchAsync(async (req, res) => {
  const products = await pharmacistService.getProducts(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: products
  })
})

const updateProduct = catchAsync(async (req, res) => {
  const product = await pharmacistService.updateProduct(req.params.id, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: product
  })
})

const deleteProduct = catchAsync(async (req, res) => {
  await pharmacistService.deleteProduct(req.params.id)
  res.status(StatusCodes.NO_CONTENT).send()
})

// Kiểm tra mã QR
const validateQRCode = catchAsync(async (req, res) => {
  const result = await pharmacistService.validateQRCode(req.body.qrCode)
  res.status(StatusCodes.OK).json({
    success: true,
    data: result
  })
})

// Đồng bộ dữ liệu thuốc (Crawler)
const syncDrugData = catchAsync(async (req, res) => {
  const result = await pharmacistService.syncDrugData(req.body.source)
  res.status(StatusCodes.OK).json({
    success: true,
    message: 'Đồng bộ dữ liệu thành công',
    data: result
  })
})

// Kiểm tra tồn kho và cập nhật giá
const updateInventory = catchAsync(async (req, res) => {
  const result = await pharmacistService.updateInventory(req.params.id, req.body)
  res.status(StatusCodes.OK).json({
    success: true,
    data: result
  })
})

// Thống kê thuốc bán chạy
const getBestsellingStats = catchAsync(async (req, res) => {
  const stats = await pharmacistService.getBestsellingStats(req.query)
  res.status(StatusCodes.OK).json({
    success: true,
    data: stats
  })
})

// Dashboard cho pharmacist
const getDashboard = catchAsync(async (req, res) => {
  const dashboard = await pharmacistService.getDashboard(req.user.id)
  res.status(StatusCodes.OK).json({
    success: true,
    data: dashboard
  })
})

export const pharmacistController = {
  // Category management
  createCategory,
  getCategories,
  updateCategory,
  deleteCategory,
  
  // Product management
  createProduct,
  getProducts,
  updateProduct,
  deleteProduct,
  
  // QR Code validation
  validateQRCode,
  
  // Data synchronization
  syncDrugData,
  
  // Inventory management
  updateInventory,
  
  // Statistics
  getBestsellingStats,
  
  // Dashboard
  getDashboard
}
