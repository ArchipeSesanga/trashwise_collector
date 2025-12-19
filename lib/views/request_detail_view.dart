import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:trashwisecollector/models/request_model.dart';
import 'package:trashwisecollector/routes/app_routes.dart';
import 'package:trashwisecollector/views/accepted_request_view.dart';

class CustomerDetails {
  final String firstName;
  final String lastName;
  final String phone;
  final String profileImageUrl;

  CustomerDetails({
    this.firstName = 'N/A',
    this.lastName = 'N/A',
    this.phone = 'N/A',
    this.profileImageUrl = '',
  });
}

String getCategoryName(int category) {
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

class RequestDetailView extends StatefulWidget {
  final DocumentSnapshot requestDoc;

  const RequestDetailView({super.key, required this.requestDoc});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView> {
  late Request _request;
  CustomerDetails _customer = CustomerDetails();
  bool _loadingCustomer = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _request = Request.fromFirestore(widget.requestDoc);
    _fetchCustomerDetails();
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(_request.userId)
          .get();

      if (snap.exists) {
        final data = snap.data()!;
        _customer = CustomerDetails(
          firstName: data["FirstName"] ?? "N/A",
          lastName: data["LastName"] ?? "N/A",
          phone: data["Phone"] ?? "N/A",
          profileImageUrl: data["ProfileImageUrl"] ?? "",
        );
      }
    } catch (e) {
      print("Customer load error: $e");
    }

    setState(() => _loadingCustomer = false);
  }

  Future<void> _acceptRequest() async {
  setState(() => _processing = true);

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    await FirebaseFirestore.instance
        .collection("RequestPickUps")
        .doc(_request.id)
        .update({
      "Status": "Accepted",
      "CollectorId": currentUser.uid,
      "AcceptedAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      _request.status = "Accepted";
      _processing = false;
    });

   Navigator.of(context).pushReplacementNamed(AppRoutes.accepted_requests);

  } catch (e) {
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to accept request: $e")),
    );
  }
}


 Future<void> _completeRequest() async {
  setState(() => _processing = true);

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final currentData = widget.requestDoc.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection("CompletedHistory")
        .add({
      ...currentData,
      "Status": "Completed",
      "CollectorId": currentUser.uid,  // important for rules
      "CompletedAt": FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection("RequestPickUps")
        .doc(_request.id)
        .delete();

    Navigator.of(context).pop();
  } catch (e) {
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to complete request: $e")),
    );
  }
}


  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Request Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CUSTOMER
            _loadingCustomer
                ? _section(
                    title: "Customer Details",
                    icon: Icons.person,
                    children: [const Center(child: CircularProgressIndicator())],
                  )
                : _section(
                    title: "Customer Details",
                    icon: Icons.person,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: _customer.profileImageUrl.isNotEmpty
                                ? NetworkImage(_customer.profileImageUrl)
                                : const AssetImage("assets/avatar_placeholder.png")
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${_customer.firstName} ${_customer.lastName}",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(_customer.phone),
                            ],
                          )
                        ],
                      )
                    ],
                  ),

            // LOCATION
            _section(
              title: "Pickup Location",
              icon: Icons.location_on,
              children: [
                Text(_request.address),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Map Preview"),
                )
              ],
            ),

            // WASTE
            _section(
              title: "Waste Details",
              icon: Icons.recycling,
              children: [
                Text("Category: ${getCategoryName(_request.wasteCategory)}"),
                Text("Estimated Weight: ${_request.estimatedWeight} kg"),
                Text(
                  "Preferred Date: ${DateFormat('MMM d, yyyy').format(_request.preferredPickupDate)}",
                ),
              ],
            ),

            // NOTE
            _section(
              title: "Request Note",
              icon: Icons.note,
              children: [
                Text(_request.note),
              ],
            ),

            const SizedBox(height: 10),

            // ACTION BUTTONS
            if (_processing)
              const CircularProgressIndicator()
            else if (_request.status == "Pending")
              ElevatedButton(
                onPressed: _acceptRequest,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green),
                child: const Text("Accept Request", style: TextStyle(color: Colors.black),),
              )
            else
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Navigate to Pickup"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _completeRequest,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orange),
                    child: const Text("Mark as Collected"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
