const mongoose = require('mongoose');

const commentSchema = mongoose.Schema(
    {
        complaintId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'Complaint',
        },
        senderId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        text: {
            type: String,
            required: true,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Comment', commentSchema);
