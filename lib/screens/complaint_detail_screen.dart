import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint_model.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../utils/constants.dart';

import 'package:url_launcher/url_launcher.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  // Helpers for admin update
  String? _newStatus;
  final _remarksController = TextEditingController();

  // Comments
  final _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoadingComments = false;

  final List<String> _statuses = [
    'Pending',
    'Under Investigation',
    'Resolved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _newStatus = widget.complaint.status;
    _remarksController.text = widget.complaint.remarks;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
    });
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final comments = await Provider.of<ComplaintProvider>(
        context,
        listen: false,
      ).fetchComments(user.token, widget.complaint.id);
      if (mounted) {
        setState(() {
          _comments = comments;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final success = await Provider.of<ComplaintProvider>(
        context,
        listen: false,
      ).addComment(user.token, widget.complaint.id, _commentController.text);
      if (success) {
        _commentController.clear();
        _fetchComments(); // Refresh list
      }
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _newStatus,
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _newStatus = val;
                });
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(labelText: 'Remarks'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = Provider.of<AuthProvider>(
                context,
                listen: false,
              ).user;
              if (user != null) {
                await Provider.of<ComplaintProvider>(
                  context,
                  listen: false,
                ).updateStatus(
                  user.token,
                  widget.complaint.id,
                  _newStatus!,
                  _remarksController.text,
                );
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to list to refresh
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;
    // Replace backslashes with forward slashes for URL if windows path
    final imagePath = widget.complaint.image.replaceAll('\\', '/');
    final imageUrl = widget.complaint.image.isNotEmpty
        ? '${Constants.baseUrl.replaceAll('/api', '')}/$imagePath'
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Image not available')),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.complaint.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  widget.complaint.status,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(widget.complaint.status),
                ),
              ),
              child: Text(
                widget.complaint.status,
                style: TextStyle(
                  color: _getStatusColor(widget.complaint.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.category, 'Type', widget.complaint.type),
            _buildDetailRow(
              Icons.location_on,
              'Location',
              widget.complaint.location,
            ),
            _buildDetailRow(
              Icons.description,
              'Description',
              widget.complaint.description,
            ),
            if (widget.complaint.remarks.isNotEmpty)
              _buildDetailRow(
                Icons.note,
                'Officer Remarks',
                widget.complaint.remarks,
              ),

            if (isAdmin) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Complainant Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.person, 'Name', widget.complaint.userName),
              _buildDetailRow(Icons.phone, 'Phone', widget.complaint.userPhone),
              _buildDetailRow(
                Icons.home,
                'Address',
                widget.complaint.userAddress,
              ),
            ],

            const SizedBox(height: 32),
            if (isAdmin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Status'),
                ),
              ),

            const SizedBox(height: 32),
            const Divider(),
            const Text(
              'Discussion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Text(
                    'No comments yet.',
                    style: TextStyle(color: Colors.grey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (ctx, i) {
                      final comment = _comments[i];
                      final isMe =
                          comment['senderId']['_id'] ==
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).user?.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment['senderId']['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  comment['createdAt'].toString().substring(
                                    0,
                                    10,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(comment['text']),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Under Investigation':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
