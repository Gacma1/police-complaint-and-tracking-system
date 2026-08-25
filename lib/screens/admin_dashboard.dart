import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import 'complaint_detail_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _refreshComplaints();
  }

  Future<void> _refreshComplaints() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<ComplaintProvider>(context, listen: false)
          .fetchAllComplaints(user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintData = Provider.of<ComplaintProvider>(context);
    
    // Simple verification statistics
    int pending = complaintData.complaints.where((c) => c.status == 'Pending').length;
    int resolved = complaintData.complaints.where((c) => c.status == 'Resolved').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatCard('Total', complaintData.complaints.length.toString(), Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard('Pending', pending.toString(), Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard('Resolved', resolved.toString(), Colors.green),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: complaintData.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshComplaints,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: complaintData.complaints.length,
                      itemBuilder: (ctx, i) {
                         final complaint = complaintData.complaints[i];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(complaint.status),
                                child: Text(
                                  complaint.status[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(complaint.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(complaint.type),
                                  Text(
                                    'Status: ${complaint.status}',
                                    style: TextStyle(
                                      color: _getStatusColor(complaint.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ComplaintDetailScreen(complaint: complaint),
                                  ),
                                );
                              },
                            ),
                          );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
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
