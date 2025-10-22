import httpStatus from 'http-status';
import  Product  from '~/models/Product.model';
import ApiError from '~/utils/ApiError';

const createProduct = async (productBody) => {
  return Product.create(productBody);
};

const queryProducts = async (filter, options) => {
  const products = await Product.paginate(filter, options);
  return products;
};

const getProductById = async (id) => {
  return Product.findById(id).populate('category');
};

const updateProductById = async (productId, updateBody) => {
  const product = await getProductById(productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  Object.assign(product, updateBody);
  await product.save();
  return product;
};

const deleteProductById = async (productId) => {
  const product = await getProductById(productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  await product.remove();
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
  getProductsByCategory,
  updateProductById,
  deleteProductById,
};
