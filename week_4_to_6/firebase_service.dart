import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/policy.dart';
import '../../models/claim.dart';
import '../../models/app_user.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // POLICIES
  Future<List<Policy>> getPolicies() async {
    final snapshot = await _db.collection('policies').get();
    return snapshot.docs
        .map((doc) => Policy.fromJson({'id': doc.id, ...doc.data()}))
        .toList();  // corrected capitalization
  }

  // CLAIMS
  Future<List<Claim>> getClaims() async {
    final snapshot = await _db.collection('claims').get();
    return snapshot.docs
        .map((doc) => Claim.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  // CUSTOMERS
  Future<List<AppUser>> getCustomers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => AppUser.fromJson({'uid': doc.id, ...doc.data()}))
        .toList();
  }
}