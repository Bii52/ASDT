import { StatusCodes } from 'http-status-codes'
import CategoryModel from '~/models/Category.model.js'
import ProductModel from '~/models/Product.model.js'
import UserModel from '~/models/user.model.js'
import ApiError from '~/utils/ApiError'
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

// Category Management
const createCategory = async (categoryData) => {
  const category = await CategoryModel.create(categoryData)
  return category
}

const getCategories = async (query) => {
  const filter = {}
  const options = {
    page: parseInt(query.page) || 1,
    limit: parseInt(query.limit) || 10,
    sort: query.sort || '-createdAt'
  }
  
  const result = await CategoryModel.paginate(filter, options)
  return result
}

const updateCategory = async (categoryId, updateData) => {
  const category = await CategoryModel.findByIdAndUpdate(
    categoryId,
    updateData,
    { new: true, runValidators: true }
  )
  
  if (!category) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Category not found')
  }
  
  return category
}

const deleteCategory = async (categoryId) => {
  const category = await CategoryModel.findByIdAndDelete(categoryId)
  
  if (!category) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Category not found')
  }
  
  // Also delete all products in this category
  await ProductModel.deleteMany({ category: categoryId })
  
  return category
}

// Product Management
const createProduct = async (productData) => {
  const product = await ProductModel.create(productData)
  return product
}

const getProducts = async (query) => {
  const filter = {}
  
  if (query.category) {
    filter.category = query.category
  }
  
  if (query.search) {
    filter.$or = [
      { name: { $regex: query.search, $options: 'i' } },
      { description: { $regex: query.search, $options: 'i' } }
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

const updateProduct = async (productId, updateData) => {
  const product = await ProductModel.findByIdAndUpdate(
    productId,
    updateData,
    { new: true, runValidators: true }
  ).populate('category')
  
  if (!product) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Product not found')
  }
  
  return product
}

const deleteProduct = async (productId) => {
  const product = await ProductModel.findByIdAndDelete(productId)
  
  if (!product) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Product not found')
  }
  
  return product
}

// QR Code Validation
const validateQRCode = async (qrCode) => {
  try {
    // Tìm sản phẩm theo QR code
    const product = await ProductModel.findOne({ qrCode }).populate('category')
    
    if (!product) {
      return {
        valid: false,
        message: 'Mã QR không hợp lệ hoặc sản phẩm không tồn tại'
      }
    }
    
    return {
      valid: true,
      product: {
        id: product._id,
        name: product.name,
        description: product.description,
        price: product.price,
        category: product.category?.name,
        qrCode: product.qrCode,
        inStock: product.inStock,
        sideEffects: product.sideEffects,
        dosage: product.dosage
      }
    }
  } catch (error) {
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Lỗi khi kiểm tra mã QR')
  }
}

// Data Synchronization (Crawler)
const syncDrugData = async (source) => {
  try {
    let scriptPath = ''
    
    switch (source) {
      case 'longchau':
        scriptPath = './src/script/scrapeProducts.js'
        break
      case 'pharmacity':
        // Có thể tạo script riêng cho Pharmacity
        scriptPath = './src/script/scrapeProducts.js'
        break
      default:
        throw new ApiError(StatusCodes.BAD_REQUEST, 'Nguồn dữ liệu không hợp lệ')
    }
    
    // Chạy script crawler
    const { stdout, stderr } = await execAsync(`node ${scriptPath}`)
    
    if (stderr) {
      console.error('Crawler error:', stderr)
    }
    
    return {
      message: 'Đồng bộ dữ liệu thành công',
      output: stdout,
      source: source
    }
  } catch (error) {
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Lỗi khi đồng bộ dữ liệu')
  }
}

// Inventory Management
const updateInventory = async (productId, inventoryData) => {
  const product = await ProductModel.findByIdAndUpdate(
    productId,
    {
      $set: {
        inStock: inventoryData.inStock,
        price: inventoryData.price,
        updatedAt: new Date()
      }
    },
    { new: true, runValidators: true }
  ).populate('category')
  
  if (!product) {
    throw new ApiError(StatusCodes.NOT_FOUND, 'Product not found')
  }
  
  return product
}

// Statistics
const getBestsellingStats = async (query) => {
  try {
    const { period = 'month', category } = query
    
    let matchStage = {}
    
    // Filter by category if provided
    if (category) {
      const categoryDoc = await CategoryModel.findOne({ name: category })
      if (categoryDoc) {
        matchStage.category = categoryDoc._id
      }
    }
    
    // Add time filter based on period
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
    
    matchStage.createdAt = { $gte: startDate }
    
    const stats = await ProductModel.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$category',
          totalProducts: { $sum: 1 },
          averagePrice: { $avg: '$price' },
          totalValue: { $sum: { $multiply: ['$price', '$inStock'] } }
        }
      },
      {
        $lookup: {
          from: 'categories',
          localField: '_id',
          foreignField: '_id',
          as: 'categoryInfo'
        }
      },
      {
        $unwind: {
          path: '$categoryInfo',
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $project: {
          categoryName: '$categoryInfo.name',
          totalProducts: 1,
          averagePrice: { $round: ['$averagePrice', 2] },
          totalValue: { $round: ['$totalValue', 2] }
        }
      },
      { $sort: { totalProducts: -1 } }
    ])
    
    return {
      period,
      category: category || 'all',
      stats
    }
  } catch (error) {
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Lỗi khi lấy thống kê')
  }
}

// Dashboard
const getDashboard = async (pharmacistId) => {
  try {
    const pharmacist = await UserModel.findById(pharmacistId)
    
    if (!pharmacist || pharmacist.role !== 'pharmacist') {
      throw new ApiError(StatusCodes.FORBIDDEN, 'Không có quyền truy cập')
    }
    
    // Get basic counts
    const totalCategories = await CategoryModel.countDocuments()
    const totalProducts = await ProductModel.countDocuments()
    const inStockProducts = await ProductModel.countDocuments({ inStock: { $gt: 0 } })
    const outOfStockProducts = await ProductModel.countDocuments({ inStock: 0 })
    
    // Get recent products
    const recentProducts = await ProductModel.find()
      .populate('category')
      .sort({ createdAt: -1 })
      .limit(5)
    
    // Get low stock products
    const lowStockProducts = await ProductModel.find({
      inStock: { $gt: 0, $lte: 10 }
    })
      .populate('category')
      .sort({ inStock: 1 })
      .limit(5)
    
    return {
      pharmacist: {
        id: pharmacist._id,
        fullName: pharmacist.fullName,
        pharmacyName: pharmacist.pharmacyName,
        pharmacyAddress: pharmacist.pharmacyAddress
      },
      summary: {
        totalCategories,
        totalProducts,
        inStockProducts,
        outOfStockProducts
      },
      recentProducts,
      lowStockProducts
    }
  } catch (error) {
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, 'Lỗi khi lấy dashboard')
  }
}

export const pharmacistService = {
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
