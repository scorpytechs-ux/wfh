require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const nodemailer = require('nodemailer');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;

// Setup Email Transporter
let transporter;
async function setupEmailTransporter() {
    try {
        if (process.env.SMTP_HOST && process.env.SMTP_USER) {
            transporter = nodemailer.createTransport({
                host: process.env.SMTP_HOST,
                port: process.env.SMTP_PORT || 587,
                secure: process.env.SMTP_PORT == 465,
                auth: {
                    user: process.env.SMTP_USER,
                    pass: process.env.SMTP_PASS
                }
            });
            console.log("Using custom SMTP server for emails.");
        } else {
            console.log("No SMTP configuration found. Generating Ethereal test account...");
            const testAccount = await nodemailer.createTestAccount();
            transporter = nodemailer.createTransport({
                host: "smtp.ethereal.email",
                port: 587,
                secure: false,
                auth: {
                    user: testAccount.user,
                    pass: testAccount.pass
                }
            });
            console.log("Ethereal test account ready. Emails will be previewable via URLs in the console.");
        }
    } catch (err) {
        console.error("Error setting up email transporter:", err);
    }
}
setupEmailTransporter();

// Admin Login Route
app.post('/api/admin/login', (req, res) => {
    const { username, password } = req.body;
    if (username === 'admin' && password === 'admin') {
        res.json({ success: true, token: 'admin-mock-token' });
    } else {
        res.status(401).json({ success: false, error: 'Invalid admin credentials' });
    }
});

// GET all candidates
app.get('/api/candidates', async (req, res) => {
    try {
        const snapshot = await db.collection('users')
                                 .where('role', '==', 'candidate')
                                 .get();
        const users = [];
        snapshot.forEach(doc => {
            users.push({ id: doc.id, ...doc.data() });
        });
        
        // Sort in memory to avoid requiring a custom composite index in Firestore
        users.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST new candidate
app.post('/api/candidates', async (req, res) => {
    const { name, email, username, password } = req.body;
    const id = uuidv4();
    const createdAt = new Date().toISOString();
    
    const newUser = {
        name,
        email,
        username,
        password,
        createdAt,
        role: 'candidate',
        isBlocked: 0,
        earnings: 0.0,
        dailyTarget: 0,
        monthlyTarget: 0,
        lastOtp: ''
    };

    try {
        await db.collection('users').doc(id).set(newUser);
        
        // Send email
        if (transporter) {
            try {
                const mailOptions = {
                    from: process.env.SMTP_FROM || '"Admin Portal" <admin@example.com>',
                    to: email,
                    subject: "Your Candidate Account Credentials",
                    html: `
                        <h2>Welcome to the Installment Management System!</h2>
                        <p>Hi ${name},</p>
                        <p>An administrator has created an account for you. Here are your login credentials:</p>
                        <ul>
                            <li><strong>Username:</strong> ${username}</li>
                            <li><strong>Password:</strong> ${password}</li>
                        </ul>
                        <p>Please log into the application to get started.</p>
                        <p>Best,<br>Admin Team</p>
                    `
                };
                const info = await transporter.sendMail(mailOptions);
                console.log("Message sent: %s", info.messageId);
            } catch (mailErr) {
                console.error("Error sending email:", mailErr.message);
            }
        }
        
        res.json({ success: true, id, ...newUser });
    } catch (err) {
        console.error("DB Insert Error:", err.message);
        res.status(400).json({ error: err.message });
    }
});

// POST send OTP
app.post('/api/auth/otp', async (req, res) => {
    const { email, otp } = req.body;
    
    if (transporter) {
        try {
            const mailOptions = {
                from: process.env.SMTP_FROM || '"Admin Portal" <admin@example.com>',
                to: email,
                subject: "Your Login OTP",
                html: `
                    <h2>Login Verification</h2>
                    <p>Your One-Time Password (OTP) for login is:</p>
                    <h1 style="letter-spacing: 4px; color: #3B82F6;">${otp}</h1>
                    <p>If you did not request this, please ignore this email.</p>
                `
            };
            const info = await transporter.sendMail(mailOptions);
            console.log("OTP email sent: %s", info.messageId);
            
            // Save the OTP to the database for backup view
            const snapshot = await db.collection('users').where('email', '==', email).get();
            if (!snapshot.empty) {
                const userDoc = snapshot.docs[0];
                await db.collection('users').doc(userDoc.id).update({ lastOtp: otp });
            }

            return res.json({ success: true });
        } catch (mailErr) {
            console.error("Error sending OTP email:", mailErr.message);
            return res.status(500).json({ error: "Failed to send email" });
        }
    } else {
        return res.status(500).json({ error: "Email service not configured" });
    }
});

// PUT toggle block status
app.put('/api/candidates/:id/block', async (req, res) => {
    const { id } = req.params;
    const { isBlocked } = req.body;
    
    try {
        await db.collection('users').doc(id).update({ isBlocked: isBlocked ? 1 : 0 });
        
        if (!isBlocked) {
            // Archive forms
            const snapshot = await db.collection('forms').where('userId', '==', id).get();
            const batch = db.batch();
            snapshot.docs.forEach(doc => {
                batch.update(doc.ref, { status: 'archived' });
            });
            await batch.commit();
        }
        res.json({ success: true, isBlocked });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update earnings
app.put('/api/candidates/:id/earnings', async (req, res) => {
    const { id } = req.params;
    const { earnings } = req.body;
    
    try {
        await db.collection('users').doc(id).update({ earnings });
        res.json({ success: true, earnings });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update targets
app.put('/api/candidates/:id/targets', async (req, res) => {
    const { id } = req.params;
    const { dailyTarget, monthlyTarget } = req.body;
    
    try {
        await db.collection('users').doc(id).update({ dailyTarget, monthlyTarget });
        res.json({ success: true, dailyTarget, monthlyTarget });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET candidate forms
app.get('/api/candidates/:id/forms', async (req, res) => {
    const { id } = req.params;
    try {
        const snapshot = await db.collection('forms').where('userId', '==', id).get();
        const forms = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            forms.push({
                id: doc.id,
                ...data,
                mistakes: typeof data.mistakes === 'string' ? JSON.parse(data.mistakes) : (data.mistakes || [])
            });
        });
        res.json(forms);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Evaluate form
app.post('/api/forms/:id/evaluate', async (req, res) => {
    const { id } = req.params;
    try {
        const doc = await db.collection('forms').doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: 'Form not found' });
        
        const form = doc.data();
        
        const groundTruth = {
            "serialNo": "1",
            "title": "Miss.",
            "firstName": "Ashlynn",
            "lastName": "Lipscomb",
            "initial": "Parish",
            "email": "ashlynnlipscomb@gmail.com",
            "fatherName": "Zole",
            "dob": "2006-08-27",
            "gender": "Female",
            "profession": "Shop Manager",
            "mailingStreet": "777 Elmwood Dr",
            "mailingCity": "Atlanta",
            "mailingPostal": "30302",
            "mailingCountry": "USA",
            "serviceProvider": "Shaw Communications",
            "fileNo": "76180379",
            "referenceNo": "@j_>B...[S|<?6]",
            "simNo": "49019504522720900000",
            "imsi1": "828120726858670",
            "imsi2": "2410317799J...",
            "typeOfPlan": "Healthcare Plans",
            "creditCardType": "Dunkin1",
            "contractValue": "USD150",
            "dateOfIssue": "2004-12-08",
            "dateOfRenewal": "2007-12-08",
            "installment": "4.596",
            "amountInWords": "Four Point Five Ninety Six",
            "remarks": "Not Applicable"
        };
        
        let totalFields = Object.keys(groundTruth).length;
        let correctFields = totalFields;
        let mistakes = [];
        
        for (const key in groundTruth) {
            if (form[key] !== groundTruth[key]) {
                correctFields--;
                mistakes.push(key);
            }
        }
        
        const score = (correctFields / totalFields) * 100;
        const status = 'evaluated';
        
        await db.collection('forms').doc(id).update({
            score,
            mistakes,
            status
        });
        
        res.json({ success: true, score, mistakes, status });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Admin Decide Score - Inject Mistakes
app.post('/api/forms/:id/admin-score', async (req, res) => {
    const { id } = req.params;
    const { targetScore } = req.body;
    
    try {
        const doc = await db.collection('forms').doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: 'Form not found' });
        
        let form = doc.data();
        
        const groundTruth = {
            "serialNo": "1",
            "title": "Miss.",
            "firstName": "Ashlynn",
            "lastName": "Lipscomb",
            "initial": "Parish",
            "email": "ashlynnlipscomb@gmail.com",
            "fatherName": "Zole",
            "dob": "2006-08-27",
            "gender": "Female",
            "profession": "Shop Manager",
            "mailingStreet": "777 Elmwood Dr",
            "mailingCity": "Atlanta",
            "mailingPostal": "30302",
            "mailingCountry": "USA",
            "serviceProvider": "Shaw Communications",
            "fileNo": "76180379",
            "referenceNo": "@j_>B...[S|<?6]",
            "simNo": "49019504522720900000",
            "imsi1": "828120726858670",
            "imsi2": "2410317799J...",
            "typeOfPlan": "Healthcare Plans",
            "creditCardType": "Dunkin1",
            "contractValue": "USD150",
            "dateOfIssue": "2004-12-08",
            "dateOfRenewal": "2007-12-08",
            "installment": "4.596",
            "amountInWords": "Four Point Five Ninety Six",
            "remarks": "Not Applicable"
        };
        
        const totalFields = Object.keys(groundTruth).length;
        const targetCorrectFields = Math.max(0, Math.min(totalFields, Math.round((targetScore / 100) * totalFields)));
        const targetMistakesCount = totalFields - targetCorrectFields;
        
        // Find current correct and incorrect fields
        let currentMistakes = [];
        let currentCorrect = [];
        
        for (const key in groundTruth) {
            if (form[key] !== groundTruth[key]) {
                currentMistakes.push(key);
            } else {
                currentCorrect.push(key);
            }
        }
        
        // Helper to introduce a mistake
        const introduceMistake = (val) => {
            if (val == null || val === '') return 'N/A';
            let strVal = String(val);
            if (!isNaN(strVal)) {
                return String(parseFloat(strVal) + (Math.random() > 0.5 ? 1 : -1));
            }
            if (strVal.length > 2) {
                const idx = Math.floor(Math.random() * (strVal.length - 1));
                const arr = strVal.split('');
                const temp = arr[idx];
                arr[idx] = arr[idx+1];
                arr[idx+1] = temp;
                return arr.join('');
            }
            return strVal + 'x';
        };
        
        let updates = {};
        
        if (currentMistakes.length < targetMistakesCount) {
            // Need to add more mistakes
            const mistakesToAdd = targetMistakesCount - currentMistakes.length;
            // Shuffle correct fields
            const shuffled = currentCorrect.sort(() => 0.5 - Math.random());
            const fieldsToMutate = shuffled.slice(0, mistakesToAdd);
            
            for (const field of fieldsToMutate) {
                updates[field] = introduceMistake(form[field] || groundTruth[field]);
                currentMistakes.push(field);
            }
        } else if (currentMistakes.length > targetMistakesCount) {
            // Need to fix some mistakes
            const mistakesToFix = currentMistakes.length - targetMistakesCount;
            const shuffled = currentMistakes.sort(() => 0.5 - Math.random());
            const fieldsToFix = shuffled.slice(0, mistakesToFix);
            
            for (const field of fieldsToFix) {
                updates[field] = groundTruth[field];
                currentMistakes = currentMistakes.filter(m => m !== field);
            }
        }
        
        // Apply updates to form
        Object.assign(form, updates);
        
        const score = ((totalFields - currentMistakes.length) / totalFields) * 100;
        const status = 'evaluated';
        
        await db.collection('forms').doc(id).update({
            ...updates,
            score,
            mistakes: currentMistakes,
            status
        });
        
        res.json({ success: true, score, mistakes: currentMistakes, status, updatedFields: updates });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Send form to candidate
app.put('/api/forms/:id/send', async (req, res) => {
    const { id } = req.params;
    try {
        await db.collection('forms').doc(id).update({ status: 'sent' });
        res.json({ success: true, status: 'sent' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`Admin Portal Backend Server is running on port ${PORT} connected to Firebase`);
});
