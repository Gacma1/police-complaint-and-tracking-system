class Complaint {
  final String id;
  final String title;
  final String description;
  final String type;
  final String location;
  final String image;
  final String status;
  final String assignedOfficer;
  final String remarks;
  final String createdAt;

  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAddress;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.image,
    required this.status,
    required this.assignedOfficer,
    required this.remarks,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userAddress,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] is Map ? json['userId'] : null;
    
    return Complaint(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 'Pending',
      assignedOfficer: json['assignedOfficer'] ?? '',
      remarks: json['remarks'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userName: user != null ? user['name'] ?? 'Unknown' : 'Unknown',
      userEmail: user != null ? user['email'] ?? 'Unknown' : 'Unknown',
      userPhone: user != null ? user['phone'] ?? 'N/A' : 'N/A',
      userAddress: user != null ? user['address'] ?? 'N/A' : 'N/A',
    );
  }
}
