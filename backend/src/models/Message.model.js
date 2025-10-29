import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2';

const messageSchema = new mongoose.Schema({
  conversationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Conversation',
    required: true,
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  content: {
    type: String,
    required: true,
    trim: true,
  },
  readBy: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
}, { timestamps: true });

messageSchema.plugin(mongoosePaginate);

const Message = mongoose.model('Message', messageSchema);
export default Message;
