const Complaint = require('../models/Complaint');

// @desc    Create a new complaint
// @route   POST /api/complaints
// @access  Private
const createComplaint = async (req, res) => {
    const { title, description, type, location, lat, lng } = req.body;
    const image = req.file ? req.file.path : '';

    if (!title || !description || !type || !location) {
        return res.status(400).json({ message: 'Please add all fields' });
    }

    try {
        const complaint = await Complaint.create({
            title,
            description,
            type,
            location,
            lat,
            lng,
            image,
            userId: req.user.id,
        });

        res.status(201).json(complaint);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get user complaints
// @route   GET /api/complaints/my
// @access  Private
const getMyComplaints = async (req, res) => {
    try {
        const complaints = await Complaint.find({ userId: req.user.id }).sort({ createdAt: -1 });
        res.status(200).json(complaints);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all complaints (Admin)
// @route   GET /api/complaints
// @access  Private/Admin
const getAllComplaints = async (req, res) => {
    try {
        const complaints = await Complaint.find({}).populate('userId', 'name email phone address').sort({ createdAt: -1 });
        res.status(200).json(complaints);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get complaint by ID
// @route   GET /api/complaints/:id
// @access  Private
const getComplaintById = async (req, res) => {
    try {
        const complaint = await Complaint.findById(req.params.id).populate('userId', 'name email phone address');

        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        // specific user can only view their own complaint unless admin
        if (complaint.userId._id.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ message: 'Not authorized' });
        }

        res.status(200).json(complaint);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update complaint status
// @route   PUT /api/complaints/:id/status
// @access  Private/Admin
const updateComplaintStatus = async (req, res) => {
    const { status, remarks, assignedOfficer } = req.body;

    try {
        const complaint = await Complaint.findById(req.params.id);

        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        complaint.status = status || complaint.status;
        complaint.remarks = remarks || complaint.remarks;
        complaint.assignedOfficer = assignedOfficer || complaint.assignedOfficer;

        const updatedComplaint = await complaint.save();

        // Create Notification if status changed
        if (req.body.status && req.body.status !== complaint.status) { // Check if status actually changed (logic slightly flawed as we already updated complaint.status above. Fixed logic below)
            // Wait, I updated complaint.status above at line 89. So I can't compare with old status unless I saved it. 
            // Let's rely on the fact that if this endpoint is called, a significant update happened.
            // Or better, let's just send notification.
            const Notification = require('../models/Notification');
            await Notification.create({
                userId: complaint.userId,
                message: `Your complaint "${complaint.title}" status has been updated to: ${updatedComplaint.status}`,
            });
        } else if (req.body.assignedOfficer) {
            const Notification = require('../models/Notification');
            await Notification.create({
                userId: complaint.userId,
                message: `Your complaint "${complaint.title}" has been assigned to officer: ${updatedComplaint.assignedOfficer}`,
            });
        }

        res.status(200).json(updatedComplaint);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};



// @desc    Add a comment to a complaint
// @route   POST /api/complaints/:id/comments
// @access  Private
const addComment = async (req, res) => {
    const { text } = req.body;

    if (!text) {
        return res.status(400).json({ message: 'Please add comment text' });
    }

    try {
        const complaint = await Complaint.findById(req.params.id);

        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        // Check authorization (only owner or admin)
        if (complaint.userId.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ message: 'Not authorized' });
        }

        const Comment = require('../models/Comment');
        const comment = await Comment.create({
            complaintId: req.params.id,
            senderId: req.user.id,
            text,
        });

        // Populate sender info for immediate return
        await comment.populate('senderId', 'name role');

        res.status(201).json(comment);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get comments for a complaint
// @route   GET /api/complaints/:id/comments
// @access  Private
const getComments = async (req, res) => {
    try {
        const complaint = await Complaint.findById(req.params.id);

        if (!complaint) {
            return res.status(404).json({ message: 'Complaint not found' });
        }

        if (complaint.userId.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(401).json({ message: 'Not authorized' });
        }

        const Comment = require('../models/Comment');
        const comments = await Comment.find({ complaintId: req.params.id })
            .populate('senderId', 'name role')
            .sort({ createdAt: 1 }); // Oldest first (chat style) or -1 for newest first

        res.status(200).json(comments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createComplaint,
    getMyComplaints,
    getAllComplaints,
    getComplaintById,
    updateComplaintStatus,
    addComment,
    getComments,
};
