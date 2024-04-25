import express from 'express';
import quizRoutes from './routes/Quiz.js';
import json from 'express';
import bodyParser from 'body-parser';
import dbConnect from './dbConnect.js';
import cors from 'cors';


const app = express();
app.use(cors());
app.use(json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
const port = 5001;



// Mount the quizRoutes router
app.use('/api', quizRoutes);

// Default route

app.get('/', (req, res) => res.send('Hello'));
app.listen(port, () => console.log(`app listening on port ${port}`));
