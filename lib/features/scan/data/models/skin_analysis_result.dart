
class SkinAnalysisResult {
  final String sessionId;
  final String analysisCode;
  final AcneSummary acneSummary;
  final List<AcneDetection> detections;
  final String advice;
  final List<String> recommendations;
  final List<String> redFlags;
  final String disclaimer;
  final int overallScore;
  final String sourceModel;
  final bool isMock;

  const SkinAnalysisResult({
    required this.sessionId,
    required this.analysisCode,
    required this.acneSummary,
    required this.detections,
    required this.advice,
    required this.recommendations,
    required this.redFlags,
    required this.disclaimer,
    required this.overallScore,
    required this.sourceModel,
    required this.isMock,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      sessionId: json['sessionId'] as String? ?? '',
      analysisCode: json['analysisCode'] as String? ?? '',
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
      disclaimer: json['disclaimer'] as String? ?? '',
      overallScore: json['overallScore'] as int? ?? 0,
      sourceModel: json['sourceModel'] as String? ?? '',
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'analysisCode': analysisCode,
        'acneSummary': acneSummary.toJson(),
        'detections': detections.map((d) => d.toJson()).toList(),
        'advice': advice,
        'recommendations': recommendations,
        'redFlags': redFlags,
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