import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/policy_provider.dart';



class PoliciesScreen
    extends ConsumerWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref) {
    final policies =
    ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Policies'),
      ),
      body: policies.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),
        error: (error, stack) =>
            Center(
              child: Text(
                  'Error: $error'),
            ),
        data: (policiesList) {
          return ListView.builder(
            itemCount:
            policiesList.length,
            itemBuilder:
                (context, index) {
              final policy =
              policiesList[index];

              return ListTile(
                title: Text(
                    policy.policyType),
                subtitle: Text(
                    policy.policyNumber),
                trailing: Text(
                  'KES ${policy.premium}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}