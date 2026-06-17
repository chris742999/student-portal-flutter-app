import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/policy_model.dart';

class PolicyRepository {
  final FirebaseFirestore firestore;

  PolicyRepository(this.firestore);

  Future<List<PolicyModel>> getPolicies() async {
    final snapshot =
    await firestore.collection('policies').get();

    return snapshot.docs.map((doc) {
      return PolicyModel.fromJson(doc.data());
    }).toList();
  }
}