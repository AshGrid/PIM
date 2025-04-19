import Category from "../models/Category.js";
import Quiz from "../models/Quiz.js";

async function getCategoryByCatAndLevel(category, level) {
    try {
        const categ = await Category.findOne({ cat: category, level });
        return categ ?? null;
    } catch (error) {
        console.error("Error fetching category:", error);
        return null;
    }
}

export const createCategory = async (req, res) => {
    const { category, level } = req.body;
    console.log('Received payload:', { category, level });

    if (!category || !level) {
        return res.status(400).json({ message: 'Category and level are required parameters.' });
    }

    try {
        const categ = await getCategoryByCatAndLevel(category, level); // ✅ await here

        if (!categ) {
            console.log("Category not found. Creating new category...");
            const newCategory = new Category({ cat: category, level });
            await newCategory.save();
            console.log("New category saved:", newCategory);
            return res.status(201).json(newCategory); // 201 for created
        } else {
            console.log("Category already exists:", categ);
            return res.status(409).json({ message: 'Category already exists.', category: categ }); // 409 for conflict
        }
    } catch (err) {
        console.error("Error in createCategory:", err);
        return res.status(500).json({ message: 'Server error' });
    }
};

export const getAllCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        return res.status(200).json(categories);
    } catch (error) {
        console.error("Error getting all categories:", error);
        return res.status(500).json({ message: 'Server error' });
    }
};
