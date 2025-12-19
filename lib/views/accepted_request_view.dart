import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashwisecollector/views/request_detail_view.dart';
import 'package:trashwisecollector/views/widgets/pickup_request_card.dart';

class AcceptedRequestsView extends StatelessWidget {
  const AcceptedRequestsView({super.key});

  static const routeName = '/accepted_requests';

  @override
  Widget build(BuildContext context) {
    // we only filter by Status.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accepted Pickups'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("RequestPickUps")
            .where('Status', isEqualTo: 'Accepted') // Filter only accepted requests
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No accepted requests. Go back and accept some!"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final requestDoc = docs[index];
              
              return InkWell(
                onTap: () {
                  // Navigate back to the detail view to mark as collected
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RequestDetailView(requestDoc: requestDoc),
                    ),
                  );
                },
                child: PickupRequestCard(doc: requestDoc),
              );
            },
          );
        },
      ),
    );
  }
}