import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/skin_analysis_result.dart';
import '../services/skin_analysis_service.dart';

sealed class SkinAnalysisState {
  const SkinAnalysisState();

  const factory SkinAnalysisState.idle() = SkinAnalysisIdle;
  const factory SkinAnalysisState.uploading(double progress) =
      SkinAnalysisUploading;
  const factory SkinAnalysisState.success(SkinAnalysisResult result) =
      SkinAnalysisSuccess;
  const factory SkinAnalysisState.error(String message) = SkinAnalysisError;

  T when<T>({
    required T Function() idle,
    required T Function(double progress) uploading,
    required T Function(SkinAnalysisResult result) success,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is SkinAnalysisIdle) return idle();
    if (state is SkinAnalysisUploading) return uploading(state.progress);
    if (state is SkinAnalysisSuccess) return success(state.result);
    if (state is SkinAnalysisError) return error(state.message);
    throw StateError('Unknown SkinAnalysisState: $state');
  }
}

final class SkinAnalysisIdle extends SkinAnalysisState {
  const SkinAnalysisIdle();
}

final class SkinAnalysisUploading extends SkinAnalysisState {
  final double progress;
  const SkinAnalysisUploading(this.progress);
}

final class SkinAnalysisSuccess extends SkinAnalysisState {
  final SkinAnalysisResult result;
  const SkinAnalysisSuccess(this.result);
}

final class SkinAnalysisError extends SkinAnalysisState {
  final String message;
  const SkinAnalysisError(this.message);
}

class SkinAnalysisViewmodel extends StateNotifier<SkinAnalysisState> {
  final SkinAnalysisService _service;
  CancelToken? _cancelToken;

  SkinAnalysisViewmodel(this._service) : super(const SkinAnalysisState.idle());

  Future<void> analyze(String imagePath) async {
    _cancelToken = CancelToken();
    state = const SkinAnalysisState.uploading(0.0);

    final result = await _service.analyzeImage(
      imagePath,
      cancelToken: _cancelToken,
      onProgress: (progress) {
        state = SkinAnalysisState.uploading(progress);
      },
    );

    if (result.error != null) {
      state = SkinAnalysisState.error(result.error!.message);
      return;
    }

    final data = result.data!;
    state = SkinAnalysisState.success(data);
  }

  void cancel() {
    _cancelToken?.cancel();
  }

  void reset() {
    state = const SkinAnalysisState.idle();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}

final skinAnalysisViewmodelProvider = StateNotifierProvider.autoDispose<
    SkinAnalysisViewmodel, SkinAnalysisState>(
  (ref) => SkinAnalysisViewmodel(ref.watch(skinAnalysisServiceProvider)),
);