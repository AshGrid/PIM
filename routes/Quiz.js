import express from 'express';
import {
    createQuizQuestion,
    fetchRandomQuizQuestion,
    createProblem,
    solveProblem,
    createQuizQuestionn
} from '../controllers/Quiz.js';

const router = express.Router();

// Route to create a new quiz question
router.post('/quiz', createQuizQuestion);
router.post('/quizz', createQuizQuestionn);
router.get('/quiz', fetchRandomQuizQuestion);
router.post('/prob',createProblem);
router.post('/solve',solveProblem);

export default router;
