import 'package:flutter/material.dart';
import '../../features/policies/models/policy_model.dart';

class PolicyCard extends StatelessWidget {
  final PolicyModel policy;

  const PolicyCard({
    super.key,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              policy.policyType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              policy.policyNumber,
            ),
            Text(
              'KES ${policy.premium}',
            ),
            Text(policy.status),
          ],
        ),
      ),
    );
  }
}