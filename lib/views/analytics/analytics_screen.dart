import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Strength Progress (Squat)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 60),
                        FlSpot(1, 65),
                        FlSpot(2, 65),
                        FlSpot(3, 70),
                        FlSpot(4, 75),
                      ],
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text('Measurement History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Weight: 75kg'),
                subtitle: const Text('Body Fat: 15%'),
                trailing: const Text('Apr 5, 2026'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Weight: 76kg'),
                subtitle: const Text('Body Fat: 16%'),
                trailing: const Text('Mar 20, 2026'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
