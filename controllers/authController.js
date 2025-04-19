
import User from '../models/User.js';

import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import fs from "fs";
import path from "path";
import {fileURLToPath} from "url";
import { validationResult } from 'express-validator';


export async function signUp(req, res) {
    try {
        const { name, email, password, password_confirmation } = req.body;
        console.log(req.body);
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ error: errors.mapped() });
        }
        // Validate required fields
        if (!name || !email || !password || !password_confirmation) {
            if (req.file) {
                deleteUploadedFile(req.file.filename);
            }
            return res.status(400).json({ error: "All fields are required" });
        }

        // Validate password confirmation
        if (password !== password_confirmation) {
            if (req.file) {
                deleteUploadedFile(req.file.filename);
            }
            return res.status(400).json({ error: "Passwords do not match" });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            if (req.file) {
                deleteUploadedFile(req.file.filename);
            }
            return res.status(400).json({ error: "User already exists" });
        }

        // Save image if provided
        let image = "";
        if (req.file) {
            image = req.file.filename;
        } else if (req.body.image) {
            image = req.body.image;
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create and save the user
        const user = new User({
            name,
            email,
            password: hashedPassword,
            image,
        });

        await user.save();

        // Generate JWT token
        //const token = jwt.sign({ id: user._id,email:user.email,username:user.name }, "your_jwt_secret", { expiresIn: "1h" });

        const accessToken = jwt.sign({
            id: user._id,email:user.email,username:user.name,role:user.role
        }, process.env.ACCESS_TOKEN_SECRET, {
            expiresIn: '10m'
        });



        const refreshToken = jwt.sign({
            id: user._id,email:user.email,username:user.name,role:user.role
        }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '1d' });


        res.status(201).json({ accessToken: accessToken , refreshToken: refreshToken,user: user });
    } catch (err) {
        console.error("Error during signup:", err);

        // Delete the uploaded file if any error occurs
        if (req.file) {
            deleteUploadedFile(req.file.filename);
        }

        res.status(500).json({ error: "Server error" });
    }
}

function deleteUploadedFile(filename) {
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);
    const filePath = path.join(__dirname, "../uploads", filename);
    try {
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    } catch (err) {
        console.error("Error deleting file:", err);
    }
}

export async function logIn(req, res){
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        console.log(user);
        if (!user) {
            return res.status(401).json({ error: 'Authentication failed1' });
        }
        const passwordMatch = await bcrypt.compare(password, user.password);
        if (!passwordMatch) {
            return res.status(401).json({ error: 'Authentication failed' });
        }


        const accessToken = jwt.sign({
            id: user._id,email:user.email,username:user.name,role:user.role
        }, process.env.ACCESS_TOKEN_SECRET, {
            expiresIn: '10m'
        });



        const refreshToken = jwt.sign({
            id: user._id,email:user.email,username:user.name,role:user.role
        }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '1d' });


        res.cookie('jwt', refreshToken, {
            httpOnly: true,
            sameSite: 'None', secure: true,
            maxAge: 24 * 60 * 60 * 1000
        });

        return res.json({ accessToken:accessToken,refreshToken:refreshToken,user:user });

        // const token = jwt.sign({ id: user._id,email:user.email,username:user.name,role:user.role }, "your_jwt_secret", { expiresIn: "1h" });

        // res.status(200).json({ token });
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: 'Login failed' });
    }
}


export async function refreshToken(req,res){
    try {

        if (req.cookies?.jwt) {

            // Destructuring refreshToken from cookie
            const refreshToken = req.cookies.jwt;

            // Verifying refresh token
            jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET,
                (err, decoded) => {
                    if (err) {

                        // Wrong Refesh Token
                        return res.status(406).json({ message: 'Unauthorized' });
                    }
                    else {
                        // Correct token we send a new access token
                        const accessToken = jwt.sign(
                            { id: decoded.id, email: decoded.email, username: decoded.username, role: decoded.role },
                            process.env.ACCESS_TOKEN_SECRET,
                            { expiresIn: '10m' }
                        );
                        return res.json({ accessToken });
                    }
                })
        } else {
            return res.status(406).json({ message: 'Unauthorized' });
        }
    }
    catch (e) {
        console.log(e);
        res.status(500).json({ error: 'refresh failed' });
    }
}


