import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2';

const ProductSchema = new mongoose.Schema({\n  name: {\n    type: String,\n    required: true,\n    trim: true,\n    minlength: 2,\n    maxlength: 100\n  },\n  description: {\n    type: String,\n    required: true,\n    trim: true,\n    minlength: 10,\n    maxlength: 1000\n  },\n  images: [{\n    type: String,\n    validate: {\n      validator: (v) => /^https?:\/\/.+/.test(v),\n      message: props => `${props.value} is not a valid URL!`\n    }\n  }],\n  price: {\n    type: Number,\n    required: true,\n    min: 0\n  },\n  category: {\n    type: mongoose.Schema.Types.ObjectId,\n    ref: \'Category\',\n    required: true\n  },\n  qrCode: {\n    type: String,\n    trim: true,\n    unique: true,\n    sparse: true // Allows multiple documents to have a null value for this field\n  },\n  inStock: {\n    type: Number,\n    required: true,\n    min: 0,\n    default: 0\n  },\n  sideEffects: {\n    type: String,\n    trim: true,\n    maxlength: 500\n  },\n  dosage: {\n    type: String,\n    trim: true,\n    maxlength: 200\n  },\n  manufacturer: {\n    type: String,\n    trim: true,\n    maxlength: 100\n  },\n  expiryDate: {\n    type: Date\n  },\n  ingredients: [{\n    type: String,\n    trim: true\n  }]\n}, { timestamps: true });

ProductSchema.plugin(mongoosePaginate);

const Product = mongoose.model('Product', ProductSchema);
export default Product;