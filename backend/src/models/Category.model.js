import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2';

const CategorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  description: {
    type: String,
    trim: true,
  },
  url: {
    type: String,
    trim: true,
  }
}, { timestamps: true });

CategorySchema.statics.isNameTaken = async function (name, excludeCategoryId) {
  const category = await this.findOne({ name, _id: { $ne: excludeCategoryId } });
  return !!category;
};

CategorySchema.plugin(mongoosePaginate);

const Category = mongoose.model('Category', CategorySchema);
export default Category;
