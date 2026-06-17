class Policy {
  final String id;
  final String policyNumber;
  final double coverageAmount;
  // ... add other fields as per your Firestore document

  Policy({
    required this.id,
    required this.policyNumber,
    required this.coverageAmount,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as String,
      policyNumber: json['policyNumber'] as String,
      coverageAmount: (json['coverageAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'policyNumber': policyNumber,
    'coverageAmount': coverageAmount,
  };
}