import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/skin_analysis_history.dart';
import '../services/skin_analysis_service.dart';

final skinAnalysisHistoryProvider =
    FutureProvider.autoDispose<SkinAnalysisHistoryResponse>((ref) async {
  final service = ref.watch(skinAnalysisServiceProvider);
  final result = await service.getHistory();

  if (result.error != null) {
    throw result.error!;
  }

  return result.data!;
});


final recentScansProvider = FutureProvider.autoDispose
    .family<SkinAnalysisHistoryResponse, int>((ref, limit) async {
  final service = ref.watch(skinAnalysisServiceProvider);
  final result = await service.getHistory(limit: limit);

  if (result.error != null) {
    throw result.error!;
  }

  return result.data!;
});