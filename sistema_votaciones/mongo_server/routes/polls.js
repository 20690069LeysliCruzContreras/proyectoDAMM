const express = require('express');
const Poll = require('../models/poll');
const authenticateToken = require('../middleware/authenticateToken');

const router = express.Router();

// Ruta para crear una nueva votación
router.post('/create', authenticateToken, async (req, res) => {
    const { title, options, startDate, endDate } = req.body;

    if (!title || !options || options.length < 2 || !startDate || !endDate) {
        return res.status(400).json({ error: 'All fields are required and there must be at least 2 options' });
    }

    try {
        const poll = new Poll({
            title,
            options: options.map(option => ({ option })),
            createdBy: req.user._id,
            startDate: new Date(startDate),
            endDate: new Date(endDate),
            isActive: new Date(startDate) <= new Date() && new Date(endDate) >= new Date()
        });

        await poll.save();
        res.status(201).json(poll);
    } catch (error) {
        console.error('Error creating poll:', error); // Agregar logging de errores
        res.status(500).json({ error: 'An error occurred while creating the poll' });
    }
});

module.exports = router;
