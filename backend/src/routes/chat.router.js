import express from 'express';
import { verifyToken } from '~/middlewares/authMiddleware.js';
import { chatController } from '~/controllers/chat.controller.js';

const router = express.Router();

router.get('/conversations', verifyToken, chatController.getConversations);
router.get('/conversations/:conversationId/messages', verifyToken, chatController.getMessages);
router.post('/messages', verifyToken, chatController.sendMessage);

export const chatRouter = router;
