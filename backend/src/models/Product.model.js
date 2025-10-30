import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2';

const ProductSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 100,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      minlength: 10,
      maxlength: 1000,
    },
    images: [
      {
        type: String,
        validate: {
          validator: (v) => /^https?:\/\/.+/.test(v),
          message: (props) => `${props.value} is not a valid URL!`,
        },
      },
    ],
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
    },
    qrCode: {
      type: String,
      trim: true,
      unique: true,
      sparse: true, 
    },
    inStock: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    sideEffects: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    dosage: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    manufacturer: {
      type: String,
      trim: true,
      maxlength: 100,
    },
    expiryDate: {
      type: Date,
    },
    ingredients: [
      {
        type: String,
        trim: true,
      },
    ],
  },
  { timestamps: true }
);

ProductSchema.plugin(mongoosePaginate);

const Product = mongoose.model('Product', ProductSchema);

export default Product;
