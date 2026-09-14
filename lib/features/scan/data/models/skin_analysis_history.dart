import '../../../../core/network/api_endpoints.dart';

class SkinAnalysisHistoryResponse {
  final List<SkinAnalysisHistoryItem> items;
  final int total;
  // ── Thông tin phân trang — BE trả về (SkinAnalysisController.GetHistory)
  final int page;
  final int pageSize;
  final int totalPages;

  const SkinAnalysisHistoryResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory SkinAnalysisHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisHistoryResponse(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) =>
              SkinAnalysisHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class SkinAnalysisHistoryItem {
  final String analysisCode;
  final String sessionId;
  final DateTime capturedAt;
  final int acneCount;
  final int overallScore;
  final String adviceText;
  final String severity;
  final String imageUrl;
  final String detectedSkinType;

  const SkinAnalysisHistoryItem({
    required this.analysisCode,
    required this.sessionId,
    required this.capturedAt,
    required this.acneCount,
    required this.overallScore,
    required this.adviceText,
    required this.severity,
    this.imageUrl = '',
    this.detectedSkinType = '',
  });

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '${ApiEndpoints.baseUrl}$path';
  }

  factory SkinAnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisHistoryItem(
      analysisCode: json['analysisCode'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now(),
      acneCount: json['acneCount'] as int? ?? 0,
      overallScore: json['overallScore'] as int? ?? 0,
      adviceText: json['adviceText'] as String? ?? '',
      severity: json['severity'] as String? ?? 'unknown',
      imageUrl: json['imageUrl'] as String? ?? '',
      detectedSkinType: json['detectedSkinType'] as String? ?? '',
    );
  }
}