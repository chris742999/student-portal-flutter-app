import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {

  Future<List<dynamic>> getPolicies() async {
    return [];
  }

  Future<List<dynamic>> getClaims() async {
    return [];
  }

  Future<Map<String, dynamic>> getStats() async {
    return {};
  }

}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});