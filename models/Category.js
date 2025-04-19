import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema({
    cat: { type: String, required: true },
    level: { type: String, required: true,enum: ['beginner', 'intermediate', 'advanced'], }

});

// Custom validator to ensure exactly 4 choices


const Category = mongoose.model('Category', categorySchema);

export default Category;
