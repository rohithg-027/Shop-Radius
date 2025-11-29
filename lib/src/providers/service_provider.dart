import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../services/api_service.dart';

final serviceListProvider = FutureProvider.autoDispose.family<List<Service>, String?>((ref, vendorId) async {
  final data = await apiService.getServices(vendorId: vendorId);
  return data.map<Service>((e) => Service.fromJson(e as Map<String, dynamic>)).toList();
});