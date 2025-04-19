import express from 'express';
import quizRoutes from './routes/Quiz.js';
import userRoute from './routes/user.js';
import authRoute from './routes/auth.js';
import catRoutes from './routes/Category.js';
import json from 'express';
import bodyParser from 'body-parser';
import dbConnect from './dbConnect.js';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import { join } from 'path';



const app = express();
app.use(cors());
app.use(json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use('/uploads', express.static(join(__dirname, 'uploads')));
const port = 5001;



// Mount the quizRoutes router
app.use('/api/users',userRoute)
app.use('/auth',authRoute)
app.use('/api', quizRoutes);
app.use('/api', catRoutes);

// Default route

app.get('/', (req, res) => res.send('Hello'));
app.listen(port, () => console.log(`app listening on port ${port}`));
