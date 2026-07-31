import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glow_aura/core/theme/app_theme.dart';
import 'package:glow_aura/features/scan/data/models/skin_analysis_history.dart';

class ScoreTrendChart extends StatelessWidget {
  final List<SkinAnalysisHistoryItem> items;
  const ScoreTrendChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();

    final sorted = [...items]
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final spots = <FlSpot>[
      for (var i = 0; i < sorted.length; i++)
        FlSpot(i.toDouble(), sorted[i].overallScore.toDouble()),
    ];

    return Container(
      padding: const EdgeInsets.all(AppColors.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xu hướng điểm da', style: AppTextStyles.title()),
          const SizedBox(height: AppColors.s12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTextStyles.caption(
                            color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval:
                          (sorted.length / 4).clamp(1, sorted.length).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        final d = sorted[i].capturedAt;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${d.day}/${d.month}',
                              style: AppTextStyles.caption(
                                  color: AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final item = sorted[s.x.toInt()];
                      return LineTooltipItem(
                        '${item.overallScore} điểm\n${item.capturedAt.day}/${item.capturedAt.month}',
                        AppTextStyles.caption(color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}