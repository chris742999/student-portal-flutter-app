import 'package:cloud_firestore/cloud_firestore.dart';

class Claim {
  final String id;
  final String claimNumber;
  final double amount;
  final DateTime claimDate;
  // ... add other fields

  Claim({
    required this.id,
    required this.claimNumber,
    required this.amount,
    required this.claimDate,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      claimNumber: json['claimNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      claimDate: (json['claimDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'claimNumber': claimNumber,
    'amount': amount,
    'claimDate': claimDate,
  };
}