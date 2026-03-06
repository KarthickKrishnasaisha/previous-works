import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CandlePoint {
  final DateTime time;
  final double close;
  CandlePoint({required this.time, required this.close});
}

class ChartPoint {
  final DateTime time;
  final double value;
  ChartPoint(this.time, this.value);
}

List<ChartPoint> computeSma(List<CandlePoint> data, int period) {
  if (data.length < period) return [];
  final result = <ChartPoint>[];
  double rollingSum = 0;

  for (int i = 0; i < data.length; i++) {
    rollingSum += data[i].close;
    if (i >= period) rollingSum -= data[i - period].close;
    if (i >= period - 1) {
      result.add(ChartPoint(data[i].time, rollingSum / period));
    }
  }
  return result;
}

List<ChartPoint> padToStart(List<CandlePoint> full, List<ChartPoint> sma) {
  if (sma.isEmpty) return [];
  final firstSmaTime = sma.first.time;
  final padded = <ChartPoint>[];
  
  for (final p in full) {
    if (p.time.isBefore(firstSmaTime)) {
      padded.add(ChartPoint(p.time, double.nan));
    } else {
      final idx = sma.indexWhere((s) => s.time == p.time);
      padded.add(idx == -1 ? ChartPoint(p.time, double.nan) : sma[idx]);
    }
  }
  return padded;
}

class TechnicalChartCard extends StatelessWidget {
  final List<CandlePoint> visibleData;

  const TechnicalChartCard({super.key, required this.visibleData});

  @override
  Widget build(BuildContext context) {
    final priceSeries = visibleData.map((e) => ChartPoint(e.time, e.close)).toList();
    
    final s20 = computeSma(visibleData, 20);
    final s50 = computeSma(visibleData, 50);
    final s200 = computeSma(visibleData, 200);
    
    final sma20 = padToStart(visibleData, s20);
    final sma50 = padToStart(visibleData, s50);
    final sma200 = padToStart(visibleData, s200);
    
    final periodLow = visibleData.map((e) => e.close).reduce(min);
    final periodHigh = visibleData.map((e) => e.close).reduce(max);
    
    final range = periodHigh - periodLow;
    final padding = range * 0.05;
    final yAxisMin = (periodLow - padding).floorToDouble();
    final yAxisMax = (periodHigh + padding).ceilToDouble();
    
    final lastPrice = visibleData.isNotEmpty ? visibleData.last.close : 0.0;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Technical Analysis',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1Y',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _StatItem(label: 'Latest', value: fmt.format(lastPrice), highlight: true),
              _StatItem(label: 'High', value: fmt.format(periodHigh)),
              _StatItem(label: 'Low', value: fmt.format(periodLow)),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _LegendItem(color: const Color(0xFF3B82F6), label: 'Price'),
                const SizedBox(width: 10),
                _LegendItem(color: const Color(0xFF22C55E), label: 'SMA 20', dashed: true),
                const SizedBox(width: 10),
                _LegendItem(color: const Color(0xFFF59E0B), label: 'SMA 50', dashed: true),
                const SizedBox(width: 10),
                _LegendItem(color: const Color(0xFFEF4444), label: 'SMA 200', dashed: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 340,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              backgroundColor: Colors.transparent,
              margin: const EdgeInsets.all(0),
              legend: const Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x : \$point.y',
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                color: const Color(0xFF1A2332),
                borderColor: Colors.white.withOpacity(0.2),
                borderWidth: 1,
              ),
              primaryXAxis: DateTimeAxis(
                majorGridLines: MajorGridLines(width: 0.3, color: Colors.white.withOpacity(0.04)),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9),
                dateFormat: DateFormat.MMM(),
                intervalType: DateTimeIntervalType.months,
                desiredIntervals: 5,
              ),
              primaryYAxis: NumericAxis(
                minimum: yAxisMin,
                maximum: yAxisMax,
                majorGridLines: MajorGridLines(width: 0.3, color: Colors.white.withOpacity(0.04)),
                axisLine: const AxisLine(width: 0),
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9),
                numberFormat: NumberFormat.currency(symbol: '\$', decimalDigits: 0),
                labelFormat: '{value}',
                desiredIntervals: 5,
              ),
              series: <CartesianSeries<ChartPoint, DateTime>>[
                LineSeries<ChartPoint, DateTime>(
                  dataSource: priceSeries,
                  xValueMapper: (p, _) => p.time,
                  yValueMapper: (p, _) => p.value,
                  width: 2.8,
                  color: const Color(0xFF3B82F6),
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
                LineSeries<ChartPoint, DateTime>(
                  dataSource: sma20,
                  xValueMapper: (p, _) => p.time,
                  yValueMapper: (p, _) => p.value.isNaN ? null : p.value,
                  width: 1.4,
                  dashArray: const <double>[5, 3],
                  color: const Color(0xFF22C55E),
                  emptyPointSettings: const EmptyPointSettings(mode: EmptyPointMode.gap),
                ),
                LineSeries<ChartPoint, DateTime>(
                  dataSource: sma50,
                  xValueMapper: (p, _) => p.time,
                  yValueMapper: (p, _) => p.value.isNaN ? null : p.value,
                  width: 1.4,
                  dashArray: const <double>[5, 3],
                  color: const Color(0xFFF59E0B),
                  emptyPointSettings: const EmptyPointSettings(mode: EmptyPointMode.gap),
                ),
                LineSeries<ChartPoint, DateTime>(
                  dataSource: sma200,
                  xValueMapper: (p, _) => p.time,
                  yValueMapper: (p, _) => p.value.isNaN ? null : p.value,
                  width: 1.4,
                  dashArray: const <double>[5, 3],
                  color: const Color(0xFFEF4444),
                  emptyPointSettings: const EmptyPointSettings(mode: EmptyPointMode.gap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatItem({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white.withOpacity(0.85),
            fontSize: 11,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendItem({required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 11 : 9,
          height: 2,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            gradient: dashed
                ? LinearGradient(
                    colors: [color, Colors.transparent, color, Colors.transparent],
                    stops: const [0, 0.4, 0.6, 1],
                  )
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 8.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

List<CandlePoint> demo1YData() {
  final now = DateTime.now();
  final rnd = Random(42);
  double price = 150;
  final points = <CandlePoint>[];
  
  int daysAdded = 0;
  int daysBack = 450;
  
  while (daysAdded < 320 && daysBack > 0) {
    final day = now.subtract(Duration(days: daysBack));
    daysBack--;
    
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) continue;
    
    price += (rnd.nextDouble() - 0.5) * 8;
    if (price < 80) price = 80;
    if (price > 250) price = 250;
    
    points.add(CandlePoint(time: day, close: double.parse(price.toStringAsFixed(2))));
    daysAdded++;
  }
  
  points.sort((a, b) => a.time.compareTo(b.time));
  final cutoff = now.subtract(const Duration(days: 365));
  return points.where((p) => p.time.isAfter(cutoff)).toList();
}
