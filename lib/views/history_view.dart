import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in to view history")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Collections'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("CompletedHistory")
            .where("CollectorId", isEqualTo: currentUser.uid) // filter by collector
            .orderBy("CompletedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No completed collections yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;

              final completedAt = data["CompletedAt"] as Timestamp?;
              final completedDate = completedAt != null
                  ? completedAt.toDate().toString().substring(0, 16)
                  : "Unknown date";

              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(data["FullName"] ?? "Unknown User"),
                subtitle: Text(data["Address"] ?? "No address"),
                trailing: Text(completedDate),
              );
            },
          );
        },
      ),
    );
  }
}
