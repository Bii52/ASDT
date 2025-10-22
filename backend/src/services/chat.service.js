import Conversation from '~/models/Conversation.model.js';
import Message from '~/models/Message.model.js';
import ApiError from '~/utils/ApiError.js';

const getConversations = async (userId) => {
  const conversations = await Conversation.find({ participants: userId })
    .populate('participants', 'fullName avatar')
    .populate('lastMessage');
  return conversations;
};

const getMessages = async (conversationId) => {
  const messages = await Message.find({ conversationId })
    .populate('sender', 'fullName avatar');
  return messages;
};

const sendMessage = async (senderId, recipientId, content, io, onlineUsers) => {
  let conversation = await Conversation.findOne({
    participants: { $all: [senderId, recipientId] }
  })

  if (!conversation) {
    conversation = await Conversation.create({ participants: [senderId, recipientId] })
  }

  const message = await Message.create({
    conversationId: conversation._id,
    sender: senderId,
    content
  })

  conversation.lastMessage = message._id
  await conversation.save()

  // Populate sender info for the real-time message
  const populatedMessage = await Message.findById(message._id).populate('sender', 'fullName avatar')

  // Send real-time message to recipient if they are online
  const recipientSocket = onlineUsers.get(recipientId)
  if (recipientSocket) {
    io.to(recipientSocket.socketId).emit('new_message', populatedMessage)
  }

  return populatedMessage
}

export const chatService = {
  getConversations,
  getMessages,
  sendMessage,
};
