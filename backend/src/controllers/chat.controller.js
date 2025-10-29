import { chatService } from '~/services/chat.service.js';
import catchAsync from '~/utils/catchAsync.js';

const getConversations = catchAsync(async (req, res) => {
  const conversations = await chatService.getConversations(req.user.id);
  res.status(200).json(conversations);
});

const getMessages = catchAsync(async (req, res) => {
  const messages = await chatService.getMessages(req.params.conversationId);
  res.status(200).json(messages);
});

const createOrGetConversation = catchAsync(async (req, res) => {
  const conversation = await chatService.getOrCreateConversation(
    req.user.id,
    req.body.recipientId
  )
  res.status(201).json(conversation)
})

const sendMessage = catchAsync(async (req, res) => {
  const io = req.app.get('io')
  const message = await chatService.sendMessage(
    req.user.id,
    req.body.recipientId,
    req.body.content,
    io,
    req.onlineUsers
  )
  res.status(201).json(message)
})

export const chatController = {
  getConversations,
  createOrGetConversation,
  getMessages,
  sendMessage,
};
