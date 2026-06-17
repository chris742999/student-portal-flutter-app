class PolicyModel {
  final String id;
  final String policyNumber;
  final String policyType;
  final double premium;
  final String status;
  final DateTime startDate;
  final DateTime expiryDate;

  PolicyModel({
    required this.id,
    required this.policyNumber,
    required this.policyType,
    required this.premium,
    required this.status,
    required this.startDate,
    required this.expiryDate,
  });

  factory PolicyModel.fromJson(
      Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'],
      policyNumber: json['policyNumber'],
      policyType: json['policyType'],
      premium: json['premium'].toDouble(),
      status: json['status'],
      startDate:
      DateTime.parse(json['startDate']),
      expiryDate:
      DateTime.parse(json['expiryDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policyNumber': policyNumber,
      'policyType': policyType,
      'premium': premium,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}