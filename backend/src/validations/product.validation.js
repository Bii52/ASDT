import Joi from 'joi';

const createProduct = {
  body: Joi.object().keys({
    name: Joi.string().required(),
    image: Joi.string().required(),
    uses: Joi.string().required(),
    referencePrice: Joi.number().required(),
    category: Joi.string().required(),
  }),
};

const getProducts = {
  query: Joi.object().keys({
    name: Joi.string(),
    category: Joi.string(),
    sortBy: Joi.string(),
    limit: Joi.number().integer(),
    page: Joi.number().integer(),
  }),
};

const getProduct = {
  params: Joi.object().keys({
    productId: Joi.string().required(),
  }),
};

const updateProduct = {
  params: Joi.object().keys({
    productId: Joi.string().required(),
  }),
  body: Joi.object()
    .keys({
      name: Joi.string(),
      image: Joi.string(),
      uses: Joi.string(),
      referencePrice: Joi.number(),
      category: Joi.string(),
    })
    .min(1),
};

const deleteProduct = {
  params: Joi.object().keys({
    productId: Joi.string().required(),
  }),
};

export const productValidation = {
  createProduct,
  getProducts,
  getProduct,
  updateProduct,
  deleteProduct,
};
