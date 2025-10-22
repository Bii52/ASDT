import { chatService } from '~/services/chat.service.js';
import catchAsync from '~/utils/catchAsync.js';

const getConversations = catchAsync(async (req, res) => {
  const conversations = await chatService.getConversations(req.user._id);
  res.status(200).json(conversations);
});

const getMessages = catchAsync(async (req, res) => {
  const messages = await chatService.getMessages(req.params.conversationId);
  res.status(200).json(messages);
});

const sendMessage = catchAsync(async (req, res) => {
  const io = req.app.get('io')
  const message = await chatService.sendMessage(
    req.user._id,
    req.body.recipientId,
    req.body.content,
    io,
    req.onlineUsers
  )
  res.status(201).json(message)
})

export const chatController = {
  getConversations,
  getMessages,
  sendMessage,
};
