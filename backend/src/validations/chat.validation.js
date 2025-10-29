import Joi from 'joi';

const sendMessage = {
  body: Joi.object().keys({
    recipientId: Joi.string().hex().length(24).required().messages({
      'string.base': 'Recipient ID must be a string.',
      'string.hex': 'Recipient ID must be a valid hexadecimal string.',
      'string.length': 'Recipient ID must be 24 characters long.',
      'any.required': 'Recipient ID is required.',
    }),
    content: Joi.string().required().messages({
      'string.base': 'Content must be a string.',
      'any.required': 'Content is required.',
    }),
  }),
};

export const chatValidation = {
  createConversation: {
    body: Joi.object().keys({
      recipientId: Joi.string().hex().length(24).required()
    })
  },
  sendMessage,
};
