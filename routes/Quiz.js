import express from 'express';
import { createQuizQuestion, fetchRandomQuizQuestion,createProblem,solveProblem } from '../controllers/Quiz.js';

const router = express.Router();

// Route to create a new quiz question
router.post('/quiz', createQuizQuestion);
router.get('/quiz', fetchRandomQuizQuestion);
router.post('/prob',createProblem);
router.post('/solve',solveProblem);

export default router;
