const mongoose = require('mongoose');

// Asegúrate de que el modelo Vote se declare solo una vez
if (!mongoose.models['Vote']) {
    const voteSchema = new mongoose.Schema({
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        pollId: { type: mongoose.Schema.Types.ObjectId, ref: 'Poll' },
        option: String
    });

    mongoose.model('Vote', voteSchema);
}

const Vote = mongoose.model('Vote');

module.exports = Vote;
