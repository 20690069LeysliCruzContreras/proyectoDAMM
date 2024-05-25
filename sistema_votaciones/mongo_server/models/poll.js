const mongoose = require('mongoose');

const pollSchema = new mongoose.Schema({
    title: { type: String, required: true },
    options: [{ option: String, votes: { type: Number, default: 0 } }],
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    isActive: { type: Boolean, default: true }
});

const Poll = mongoose.model('Poll', pollSchema);

module.exports = Poll;
