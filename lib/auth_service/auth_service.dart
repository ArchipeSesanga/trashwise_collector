
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> registerCollector({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = credential.user!.uid;

    await _db.collection("collectors").doc(userId).set({
      "fullName": fullName,
      "email": email,
      "role": "collector",
      "createdAt": FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<bool> loginCollector({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = credential.user!.uid;

    final snapshot = await _db.collection("collectors").doc(userId).get();

    if (!snapshot.exists) throw "Account not registered as collector";

    if (snapshot.data()!["role"] != "collector") {
      throw "Access denied: not a collector";
    }

    return true;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
