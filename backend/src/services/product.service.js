import httpStatus from 'http-status';
import  Product  from '~/models/Product.model';
import { v4 as uuidv4 } from 'uuid';
import ApiError from '~/utils/ApiError';

const mapIncomingToModel = (body) => {
  const mapped = {};
  if (body.name !== undefined) mapped.name = body.name;
  // Prefer explicit description but fall back to `uses`
  if (body.description !== undefined) mapped.description = body.description;
  if (mapped.description === undefined && body.uses !== undefined) mapped.description = body.uses;
  // Images: accept single `image` or array `images`
  if (Array.isArray(body.images)) mapped.images = body.images;
  if (body.image !== undefined) mapped.images = [body.image];
  // Price: map referencePrice -> price
  if (body.price !== undefined) mapped.price = body.price;
  if (mapped.price === undefined && body.referencePrice !== undefined) mapped.price = body.referencePrice;
  // Category: pass through
  if (body.category !== undefined) mapped.category = body.category;
  // Optional fields from UI may be absent; keep others as-is if provided
  if (body.inStock !== undefined) mapped.inStock = body.inStock;
  if (body.sideEffects !== undefined) mapped.sideEffects = body.sideEffects;
  if (body.dosage !== undefined) mapped.dosage = body.dosage;
  if (body.manufacturer !== undefined) mapped.manufacturer = body.manufacturer;
  if (body.expiryDate !== undefined) mapped.expiryDate = body.expiryDate;
  if (body.ingredients !== undefined) mapped.ingredients = body.ingredients;
  if (body.qrCode !== undefined) mapped.qrCode = body.qrCode;
  return mapped;
};

const createProduct = async (productBody) => {
  const mapped = mapIncomingToModel(productBody);
  return Product.create(mapped);
};

const queryProducts = async (filter, options) => {
  const builtFilter = {};
  if (filter?.name) {
    builtFilter.name = { $regex: filter.name, $options: 'i' };
  }
  if (filter?.category) {
    builtFilter.category = filter.category;
  }
  const products = await Product.paginate(builtFilter, {
    ...options,
    lean: true,
  });
  return products;
};

const getProductById = async (id) => {
  return Product.findById(id).populate('category');
};

const getProductByQrCode = async (qrCode) => {
  if (!qrCode) return null;
  return Product.findOne({ qrCode }).populate('category');
};

const updateProductById = async (productId, updateBody) => {
  const product = await getProductById(productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  const mapped = mapIncomingToModel(updateBody);
  Object.assign(product, mapped);
  await product.save();
  return product;
};

const generateQrForProduct = async (productId) => {
  const product = await getProductById(productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  if (!product.qrCode) {
    product.qrCode = uuidv4();
    await product.save();
  }
  return product.qrCode;
};

const deleteProductById = async (productId) => {
  const product = await getProductById(productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  await product.deleteOne();
  return product;
};

/**
 * Lấy danh sách sản phẩm thuộc một danh mục cụ thể và phân trang
 * @param {string} categoryId - ID của danh mục cần tìm sản phẩm
 * @param {object} options - Tùy chọn phân trang (limit, page, sortBy)
 * @returns {Promise<QueryResult>}
 */
const getProductsByCategory = async (categoryId, options) => {
    // Tạo filter để tìm các sản phẩm có trường 'category' trùng với categoryId
    const filter = { category: categoryId }; 
    
    // Thực hiện phân trang trên Product Model
    // (Giả sử Product Model cũng đã áp dụng mongoose-paginate-v2)
    const products = await Product.paginate(filter, options);
    
    return products;
};

export const productService = {
  createProduct,
  queryProducts,
  getProductById,
  getProductByQrCode,
  getProductsByCategory,
  updateProductById,
  generateQrForProduct,
  deleteProductById,
};
