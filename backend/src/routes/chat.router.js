import express from 'express';
import { verifyToken } from '~/middlewares/authMiddleware.js';
import validate from '~/middlewares/validationMiddleware.js';
import { chatController } from '~/controllers/chat.controller.js';
import { chatValidation } from '~/validations/chat.validation.js';

const router = express.Router();

router.get('/conversations', verifyToken, chatController.getConversations);
router.get('/conversations/:conversationId/messages', verifyToken, chatController.getMessages);
router.post('/conversations', verifyToken, validate(chatValidation.createConversation), chatController.createOrGetConversation);
router.post('/messages', verifyToken, validate(chatValidation.sendMessage), chatController.sendMessage);

export const chatRouter = router;
