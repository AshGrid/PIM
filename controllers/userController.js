
import User from '../models/User.js';

import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import fs from "fs";
import path from "path";
import {fileURLToPath} from "url";


export async function createUser(req, res) {
    try {
        const { name, email, password, password_confirmation,role } = req.body;

        // Validate required fields
        if (!name || !email || !password || !password_confirmation || !role) {
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
            role,
        });

        await user.save();

        // Generate JWT token
        //  const token = jwt.sign({ id: user._id,email:user.email,username:user.name }, "your_jwt_secret", { expiresIn: "1h" });

        res.status(201).json({ message: "User created successfully", user });
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

export async function getAllUsers(req, res) {
    try {
        const users = await User.find({}, "-password -password_confirmation"); // Exclude sensitive fields
        res.status(200).json(users);
    } catch (err) {
        console.error("Error fetching users:", err);
        res.status(500).json({ error: "Server error" });
    }
}

export async function getUser(req, res) {

    try {
        const user = await User.find({email: res.email}, "-password -password_confirmation"); // Exclude sensitive fields
        res.status(200).json(user);
    } catch (err) {
        console.error("Error fetching user:", err);
        res.status(500).json({ error: "Server error" });
    }

}