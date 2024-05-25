const express = require('express');
const Vote = require('../models/vote'); // Asegúrate de importar el modelo Vote solo una vez
const Poll = require('../models/poll');
const authenticateToken = require('../middleware/authenticateToken');

const router = express.Router();

// Resto del código...

router.post('/:pollId', authenticateToken, async (req, res) => {
  const { option } = req.body;
  try {
    const poll = await Poll.findById(req.params.pollId);
    if (!poll) {
      return res.status(404).json({ message: 'Poll not found' });
    }
    if (!poll.isActive) {
      return res.status(400).json({ message: 'Poll is closed' });
    }
    const existingVote = await Vote.findOne({ userId: req.user.id, pollId: req.params.pollId });
    if (existingVote) {
      existingVote.option = option;
      await existingVote.save();
    } else {
      const newVote = new Vote({ userId: req.user.id, pollId: req.params.pollId, option });
      await newVote.save();
    }
    poll.options = poll.options.map(opt => {
      if (opt.option === option) {
        opt.votes += 1;
      }
      return opt;
    });
    await poll.save();
    res.status(200).json({ message: 'Vote submitted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.get('/:pollId/results', async (req, res) => {
  try {
    const poll = await Poll.findById(req.params.pollId);
    if (!poll) {
      return res.status(404).json({ message: 'Poll not found' });
    }
    res.status(200).json(poll.options);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
