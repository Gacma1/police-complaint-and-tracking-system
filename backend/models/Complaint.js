const mongoose = require('mongoose');

const complaintSchema = mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
        },
        description: {
            type: String,
            required: true,
        },
        type: {
            type: String,
            required: true,
            enum: ['Theft', 'Violence', 'Fraud', 'Cybercrime', 'Other'],
        },
        location: {
            type: String,
            required: true,
        },
        lat: {
            type: Number,
        },
        lng: {
            type: Number,
        },
        image: {
            type: String, // URL/Path to the image
            default: '',
        },
        status: {
            type: String,
            enum: ['Pending', 'Under Investigation', 'Resolved', 'Rejected'],
            default: 'Pending',
        },
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        assignedOfficer: {
            type: String, // You could link this to a User specific role, but for simplicity keeping as String name/ID
            default: null,
        },
        remarks: {
            type: String,
            default: '',
        },
    },
    {
        timestamps: true,
    }
);

const Complaint = mongoose.model('Complaint', complaintSchema);

module.exports = Complaint;
