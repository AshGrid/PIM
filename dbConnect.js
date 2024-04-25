import mongoose from 'mongoose';

//mongoose.connect('mongodb+srv://ayoub1:ayoub1@pdm.vwwjbxe.mongodb.net/', { useNewUrlParser: true, useUnifiedTopology: true });

mongoose.connect('mongodb://localhost:27017/gemini');

const connection = mongoose.connection;

connection.on('error', (err) => console.log(err));
connection.on('connected', () => console.log('Connection successful'));

export default connection;
