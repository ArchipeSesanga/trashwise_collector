import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashwisecollector/views/widgets/pickup_request_card.dart';
import 'package:trashwisecollector/views/request_detail_view.dart';

class PendingRequestsView extends StatelessWidget {
  const PendingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Requests"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("RequestPickUps")
            .where("Status", isEqualTo: "Pending") // 👈 Filter pending
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending requests"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final requestDoc = docs[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestDetailView(requestDoc: requestDoc),
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
