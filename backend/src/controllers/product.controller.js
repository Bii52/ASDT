import httpStatus from 'http-status';
import pick from '~/utils/pick';
import ApiError from '~/utils/ApiError';
import catchAsync from '~/utils/catchAsync';
import { productService } from '~/services/product.service';

const createProduct = catchAsync(async (req, res) => {
  const product = await productService.createProduct(req.body);
  res.status(httpStatus.CREATED).send(product);
});

const getProducts = catchAsync(async (req, res) => {
  const filter = pick(req.query, ['name', 'category']);
  const options = pick(req.query, ['sortBy', 'limit', 'page']);
  const result = await productService.queryProducts(filter, options);
  res.send(result);
});

const getProduct = catchAsync(async (req, res) => {
  const product = await productService.getProductById(req.params.productId);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  res.send(product);
});

const getProductByQr = catchAsync(async (req, res) => {
  const { qrCode } = req.params;
  const product = await productService.getProductByQrCode(qrCode);
  if (!product) {
    throw new ApiError(httpStatus.NOT_FOUND, 'Product not found');
  }
  res.send(product);
});

const updateProduct = catchAsync(async (req, res) => {
  const product = await productService.updateProductById(req.params.productId, req.body);
  res.send(product);
});

const deleteProduct = catchAsync(async (req, res) => {
  await productService.deleteProductById(req.params.productId);
  res.status(httpStatus.NO_CONTENT).send();
});

const generateProductQr = catchAsync(async (req, res) => {
  const code = await productService.generateQrForProduct(req.params.productId);
  res.status(httpStatus.OK).json({ success: true, qrCode: code });
});

const getProductsByCategoryId = catchAsync(async (req, res) => {
    const categoryId = req.params.categoryId; 
    const options = pick(req.query, ['sortBy', 'limit', 'page']);
    const result = await productService.getProductsByCategory(categoryId, options);
    res.send(result);
});
export const productController = {
  createProduct,
  getProducts,
  getProduct,
  getProductByQr,
  updateProduct,
  deleteProduct,
  generateProductQr,
  getProductsByCategoryId,
};
