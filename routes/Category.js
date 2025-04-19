import express from 'express';
import {createCategory, getAllCategories} from "../controllers/Category.js";


const router = express.Router();

// Route to create a new quiz question
router.post('/category', createCategory);
router.get('/category', getAllCategories);


export default router;
