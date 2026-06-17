import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_provider.dart';
import '../models/policy_model.dart';
import '../repositories/policy_repository.dart';

final policyRepositoryProvider =
Provider<PolicyRepository>((ref) {
  return PolicyRepository(
    ref.read(apiServiceProvider),
  );
});

final policiesProvider =
FutureProvider<List<PolicyModel>>((ref) {
  return ref
      .read(policyRepositoryProvider)
      .getPolicies();
});