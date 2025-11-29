import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String id;
  final String userId;
  final String fullName;
  final String address;
  final String note;
  final int wasteCategory;
  final int estimatedWeight;
   String status;
  final DateTime preferredPickupDate;

  Request({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.address,
    required this.note,
    required this.wasteCategory,
    required this.estimatedWeight,
    required this.status,
    required this.preferredPickupDate,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Safety check for required fields, especially Timestamp conversion
    final pickupTimestamp = data['PreferredPickupDate'] as Timestamp?;

    return Request(
      id: doc.id,
      userId: data['UserId'] ?? '', // Used to fetch user details
      fullName: data['FullName'] ?? 'N/A',
      address: data['Address'] ?? 'No address provided',
      note: data['Note'] ?? 'No special instructions.',
      wasteCategory: data['WasteCategory'] ?? 0,
      estimatedWeight: data['EstimatedWeight'] ?? 0,
      status: data['Status'] ?? 'Pending',
      preferredPickupDate: pickupTimestamp?.toDate() ?? DateTime.now(),
    );
  }
}