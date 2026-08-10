class SkinAnalysisResult {
  final String sessionId;
  final String analysisCode;
  final String imageUrl; 
  final String detectedSkinType;
  final AcneSummary acneSummary;
  final List<AcneDetection> detections;
  final String advice;
  final List<String> recommendations;
  final List<String> redFlags;
  final List<RecommendedProduct> recommendedProducts;
  final String disclaimer;
  final int overallScore;
  final String sourceModel;
  final bool isMock;

  const SkinAnalysisResult({
    required this.sessionId,
    required this.analysisCode,
    required this.imageUrl,
    required this.detectedSkinType,
    required this.acneSummary,
    required this.detections,
    required this.advice,
    required this.recommendations,
    required this.redFlags,
    required this.recommendedProducts,
    required this.disclaimer,
    required this.overallScore,
    required this.sourceModel,
    required this.isMock,
  });

  /// true nếu RAG không trả được tư vấn (advice rỗng) dù request vẫn thành công.
  bool get hasAdvice => advice.trim().isNotEmpty;

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      sessionId: json['sessionId'] as String? ?? '',
      analysisCode: json['analysisCode'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      detectedSkinType: json['detectedSkinType'] as String? ?? '',
      acneSummary: AcneSummary.fromJson(
        json['acneSummary'] as Map<String, dynamic>? ?? const {},
      ),
      detections: (json['detections'] as List<dynamic>? ?? const [])
          .map((e) => AcneDetection.fromJson(e as Map<String, dynamic>))
          .toList(),
      advice: json['advice'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      redFlags: (json['redFlags'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      recommendedProducts:
          (json['recommendedProducts'] as List<dynamic>? ?? const [])
              .map((e) => RecommendedProduct.fromJson(e as Map<String, dynamic>))
              .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
      overallScore: json['overallScore'] as int? ?? 0,
      sourceModel: json['sourceModel'] as String? ?? '',
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'analysisCode': analysisCode,
        'imageUrl': imageUrl,
        'detectedSkinType': detectedSkinType,
        'acneSummary': acneSummary.toJson(),
        'detections': detections.map((d) => d.toJson()).toList(),
        'advice': advice,
        'recommendations': recommendations,
        'redFlags': redFlags,
        'recommendedProducts':
            recommendedProducts.map((p) => p.toJson()).toList(),
        'disclaimer': disclaimer,
        'overallScore': overallScore,
        'sourceModel': sourceModel,
        'isMock': isMock,
      };
}

class AcneSummary {
  final int totalAcne;
  final int blackheads;
  final int whiteheads;
  final int pimples;
  final String severity;

  const AcneSummary({
    required this.totalAcne,
    required this.blackheads,
    required this.whiteheads,
    required this.pimples,
    required this.severity,
  });

  factory AcneSummary.fromJson(Map<String, dynamic> json) {
    return AcneSummary(
      totalAcne: json['totalAcne'] as int? ?? 0,
      blackheads: json['blackheads'] as int? ?? 0,
      whiteheads: json['whiteheads'] as int? ?? 0,
      pimples: json['pimples'] as int? ?? 0,
      severity: json['severity'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'totalAcne': totalAcne,
        'blackheads': blackheads,
        'whiteheads': whiteheads,
        'pimples': pimples,
        'severity': severity,
      };
}

class AcneDetection {
  final int id;
  final String className;
  final String labelVi;
  final double confidence;
  final AcneBoundingBox bbox;

  const AcneDetection({
    required this.id,
    required this.className,
    required this.labelVi,
    required this.confidence,
    required this.bbox,
  });

  factory AcneDetection.fromJson(Map<String, dynamic> json) {
    return AcneDetection(
      id: json['id'] as int? ?? 0,
      className: json['className'] as String? ?? '',
      labelVi: json['labelVi'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      bbox: AcneBoundingBox.fromJson(
        json['bbox'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'className': className,
        'labelVi': labelVi,
        'confidence': confidence,
        'bbox': bbox.toJson(),
      };
}

class AcneBoundingBox {
  final double x1, y1, x2, y2;

  const AcneBoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory AcneBoundingBox.fromJson(Map<String, dynamic> json) {
    return AcneBoundingBox(
      x1: (json['x1'] as num?)?.toDouble() ?? 0.0,
      y1: (json['y1'] as num?)?.toDouble() ?? 0.0,
      x2: (json['x2'] as num?)?.toDouble() ?? 0.0,
      y2: (json['y2'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};

  double get width => x2 - x1;
  double get height => y2 - y1;
}

class RecommendedProduct {
  final String id;
  final String name;
  final String brand;
  final int price;
  final String imageUrl; 
  final String category;
  final String matchReason;

  const RecommendedProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.matchReason,
  });

  bool get isBase64 => imageUrl.startsWith('data:image');

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      matchReason: json['matchReason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'matchReason': matchReason,
      };
}