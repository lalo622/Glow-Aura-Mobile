import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glow_aura/core/network/api_client.dart';

import '../data/models/skin_analysis_history.dart';
import '../services/skin_analysis_service.dart';

const int _defaultPageSize = 5;

// Service Provider
final skinAnalysisServiceProvider = Provider<SkinAnalysisService>((ref) {
  return SkinAnalysisService(ApiClient.instance.dio);
});

// History Paging State

class HistoryPagingState {
  final List<SkinAnalysisHistoryItem> items;
  final int page;
  final int totalPages;

  final bool isLoading;

  final bool isLoadingMore;

  final Object? error;

  const HistoryPagingState({
    this.items = const [],
    this.page = 0,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasMore => page > 0 && page < totalPages;

  bool get isEmpty => items.isEmpty && !isLoading;

  HistoryPagingState copyWith({
    List<SkinAnalysisHistoryItem>? items,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return HistoryPagingState(
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// History Paging Notifier

class HistoryPagingNotifier extends StateNotifier<HistoryPagingState> {
  final SkinAnalysisService _service;

  HistoryPagingNotifier(this._service)
      : super(
          const HistoryPagingState(
            isLoading: true,
          ),
        ) {
    // Page đầu tiên phải luôn là replace=true.
    _loadPage(
      1,
      replace: true,
    );
  }
 
  // Refresh  
  Future<void> refresh() {
    // Không tạo thêm request nếu page 1 đang tải.
    if (state.isLoading) {
      return Future.value();
    }

    return _loadPage(
      1,
      replace: true,
    );
  }

  // Load More
  Future<void> loadMore() {
    // Page == 0 nghĩa là page 1 chưa load thành công.
    if (state.page == 0) {
      return Future.value();
    }

    if (state.isLoading) {
      return Future.value();
    }

    if (state.isLoadingMore) {
      return Future.value();
    }

    if (!state.hasMore) {
      return Future.value();
    }

    final nextPage = state.page + 1;

    return _loadPage(
      nextPage,
      replace: false,
    );
  }

  // Load Page
  Future<void> _loadPage(
    int page, {
    required bool replace,
  }) async {
    state = state.copyWith(
      isLoading: replace,
      isLoadingMore: !replace,
      clearError: true,
    );

    final result = await _service.getHistory(
      page: page,
      pageSize: _defaultPageSize,
    );

    // API ERROR
    if (result.error != null) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: result.error,
      );

      return;
    }

    // API SUCCESS
    final response = result.data!;

    final newItems = replace
        ? response.items
        : [
            ...state.items,
            ...response.items,
          ];

    state = state.copyWith(
      items: newItems,
      page: response.page,
      totalPages: response.totalPages,
      isLoading: false,
      isLoadingMore: false,
      clearError: true,
    );
  }
}

// History Provider
final historyPagingProvider =
    StateNotifierProvider<HistoryPagingNotifier, HistoryPagingState>(
  (ref) {
    final service = ref.watch(
      skinAnalysisServiceProvider,
    );

    return HistoryPagingNotifier(service);
  },
);

// Recent Scans

final recentScansProvider =
    FutureProvider.autoDispose.family<SkinAnalysisHistoryResponse, int>(
  (ref, limit) async {
    final service = ref.watch(
      skinAnalysisServiceProvider,
    );

    final result = await service.getHistory(
      page: 1,
      pageSize: limit,
    );

    if (result.error != null) {
      throw result.error!;
    }

    return result.data!;
  },
);