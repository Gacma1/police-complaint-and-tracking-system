const express = require('express');
const router = express.Router();
const {
    createComplaint,
    getMyComplaints,
    getAllComplaints,
    getComplaintById,
    updateComplaintStatus,
    addComment,
    getComments,
} = require('../controllers/complaintController');
const { protect, admin } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/', protect, upload.single('image'), createComplaint);
router.get('/my', protect, getMyComplaints);
router.get('/', protect, admin, getAllComplaints);
router.get('/:id', protect, getComplaintById);
router.put('/:id/status', protect, admin, updateComplaintStatus);
router.route('/:id/comments').post(protect, addComment).get(protect, getComments);

module.exports = router;
