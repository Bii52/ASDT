import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2';

const conversationSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  }],
  lastMessage: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message',
  },
}, { timestamps: true });

conversationSchema.plugin(mongoosePaginate);

const Conversation = mongoose.model('Conversation', conversationSchema);

export default Conversation;