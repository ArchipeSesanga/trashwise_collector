import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PickupRequestCard extends StatefulWidget {
  final DocumentSnapshot doc;

  const PickupRequestCard({super.key, required this.doc});

  @override
  State<PickupRequestCard> createState() => _PickupRequestCardState();
}

class _PickupRequestCardState extends State<PickupRequestCard> {
  // State variable to hold the fetched profile picture URL
  String _fetchedProfilePicUrl = ''; 
  
  // Define the maximum allowed length for the name
  static const int _maxNameLength = 15;

  @override
  void initState() {
    super.initState();
    // Start fetching the profile picture immediately
    _fetchProfilePictureUrl();
  }

  // Helper function to perform the secondary Firestore read to get the image URL
  void _fetchProfilePictureUrl() async {
    final data = widget.doc.data() as Map<String, dynamic>;
    
    // CRITICAL: Get the UserID from the pickup request document. 
    // This MUST match the document ID in the 'users' collection.
    // If your field name is different (e.g., 'RequesterId'), change 'UserID' below.
    final userID = data['UserId'] ?? ''; 

    if (userID.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          
          // Retrieve the ProfileImageUrl from the USER document (using the correct capitalization)
          final url = userData['ProfileImageUrl'] ?? '';

          // Update the UI state with the fetched URL
          if (mounted) {
            setState(() {
              _fetchedProfilePicUrl = url;
            });
          }
        }
      } catch (e) {
        print("Error fetching profile picture for user $userID: $e");
      }
    }
  }

  // Helper function to truncate the name
  String _truncateName(String name) {
    if (name.length > _maxNameLength) {
      return '${name.substring(0, _maxNameLength)}...';
    }
    return name;
  }

  // CATEGORY NAME and CATEGORY IMAGE functions...
  String _categoryName(int category) {
    switch (category) {
      case 0: return "Paper";
      case 1: return "Plastic";
      case 2: return "Glass";
      case 3: return "Metal";
      case 4: return "Organic";
      case 5: return "Electronic";
      default: return "Others";
    }
  }

  String _getCategoryImage(int category) {
    switch (category) {
      case 0: return "assets/paper.jpg";
      case 1: return "assets/plastic.jpg";
      case 2: return "assets/glass.jpg";
      case 3: return "assets/metal.jpg";
      case 4: return "assets/organic.jpg";
      case 5: return "assets/electronic.jpg";
      default: return "assets/others.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;

    final originalFullName = data['FullName'] ?? '';
    final fullName = _truncateName(originalFullName);
    
    final address = data['Address'] ?? '';
    final status = data['Status'] ?? '';
    final wasteCategory = data['WasteCategory'] ?? 0;
    final pickupTime = (data['PreferredPickupDate'] as Timestamp).toDate();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [

          // LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      // --- Use the fetched state variable for the image ---
                      backgroundImage: _fetchedProfilePicUrl.isNotEmpty 
                          ? NetworkImage(_fetchedProfilePicUrl) as ImageProvider
                          : const AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat("hh:mm a").format(pickupTime),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.green),
                    color: Colors.green.shade50,
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // RIGHT SIDE: CATEGORY IMAGE + LABEL
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getCategoryImage(wasteCategory),
                  width: 95,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _categoryName(wasteCategory),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}