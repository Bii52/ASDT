import Joi from 'joi'

const createCategory = {
  body: Joi.object().keys({
    name: Joi.string().required().trim().min(2).max(50),
    description: Joi.string().optional().trim().max(200),
    image: Joi.string().optional().uri()
  })
}

const updateCategory = {
  params: Joi.object().keys({
    id: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    name: Joi.string().optional().trim().min(2).max(50),
    description: Joi.string().optional().trim().max(200),
    image: Joi.string().optional().uri()
  }).min(1)
}

const createProduct = {
  body: Joi.object().keys({
    name: Joi.string().required().trim().min(2).max(100),
    description: Joi.string().required().trim().min(10).max(1000),
    price: Joi.number().required().min(0),
    category: Joi.string().required().hex().length(24),
    qrCode: Joi.string().optional().trim(),
    inStock: Joi.number().required().min(0),
    sideEffects: Joi.string().optional().trim().max(500),
    dosage: Joi.string().optional().trim().max(200),
    manufacturer: Joi.string().optional().trim().max(100),
    expiryDate: Joi.date().optional(),
    ingredients: Joi.array().items(Joi.string().trim()).optional(),
    images: Joi.array().items(Joi.string().uri()).optional()
  })
}

const updateProduct = {
  params: Joi.object().keys({
    id: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    name: Joi.string().optional().trim().min(2).max(100),
    description: Joi.string().optional().trim().min(10).max(1000),
    price: Joi.number().optional().min(0),
    category: Joi.string().optional().hex().length(24),
    qrCode: Joi.string().optional().trim(),
    inStock: Joi.number().optional().min(0),
    sideEffects: Joi.string().optional().trim().max(500),
    dosage: Joi.string().optional().trim().max(200),
    manufacturer: Joi.string().optional().trim().max(100),
    expiryDate: Joi.date().optional(),
    ingredients: Joi.array().items(Joi.string().trim()).optional(),
    images: Joi.array().items(Joi.string().uri()).optional()
  }).min(1)
}

const validateQR = {
  body: Joi.object().keys({
    qrCode: Joi.string().required().trim().min(1)
  })
}

const syncData = {
  body: Joi.object().keys({
    source: Joi.string().required().valid('longchau', 'pharmacity')
  })
}

const updateInventory = {
  params: Joi.object().keys({
    id: Joi.string().required().hex().length(24)
  }),
  body: Joi.object().keys({
    inStock: Joi.number().required().min(0),
    price: Joi.number().optional().min(0)
  })
}

export const pharmacistValidation = {
  createCategory,
  updateCategory,
  createProduct,
  updateProduct,
  validateQR,
  syncData,
  updateInventory
}
