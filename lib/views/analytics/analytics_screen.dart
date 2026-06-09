import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/body_measurement.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _show1Rm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsVM = context.watch<AnalyticsViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final unit = settingsVM.isMetric ? l10n.kg : l10n.lbs;
    final dateFormat = DateFormat.MMMd(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAnalytics),
      ),
      body: RefreshIndicator(
        onRefresh: () => analyticsVM.load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Strength progress ---
              Text(l10n.strengthProgress,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.exercisesWithData.isEmpty)
                _EmptyChart(message: l10n.noDataYet)
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: analyticsVM.selectedExercise?.id,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: analyticsVM.exercisesWithData
                            .map((e) => DropdownMenuItem(
                                value: e.id, child: Text(e.name)))
                            .toList(),
                        onChanged: (id) {
                          final exercise = analyticsVM.exercisesWithData
                              .where((e) => e.id == id)
                              .firstOrNull;
                          if (exercise != null) {
                            analyticsVM.selectExercise(exercise);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                            value: false,
                            label: Text(l10n.maxWeight,
                                style: const TextStyle(fontSize: 12))),
                        ButtonSegment(
                            value: true,
                            label: Text(l10n.estimated1Rm,
                                style: const TextStyle(fontSize: 12))),
                      ],
                      selected: {_show1Rm},
                      onSelectionChanged: (selection) {
                        setState(() => _show1Rm = selection.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProgressChart(
                  points: analyticsVM.progressPoints,
                  show1Rm: _show1Rm,
                  dateFormat: dateFormat,
                ),
              ],
              const SizedBox(height: 32),

              // --- Weekly volume ---
              Text(l10n.weeklyVolume,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.weeklyVolume.every((w) => w.volume == 0))
                _EmptyChart(message: l10n.noDataYet)
              else
                _VolumeChart(
                  points: analyticsVM.weeklyVolume,
                  dateFormat: dateFormat,
                ),
              const SizedBox(height: 32),

              // --- Personal records ---
              Text(l10n.personalRecords,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.personalRecords.isEmpty)
                _EmptyChart(message: l10n.noDataYet, height: 80)
              else
                ...analyticsVM.personalRecords.map(
                  (pr) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: AppTheme.primary),
                      title: Text(pr.exerciseName),
                      subtitle: Text(l10n.setSummary(
                          _formatWeight(pr.weight), unit, pr.reps)),
                      trailing: Text(dateFormat.format(pr.date),
                          style: const TextStyle(color: AppTheme.textLight)),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // --- Body weight ---
              Text(l10n.bodyWeightChart,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.measurements.length < 2)
                _EmptyChart(message: l10n.noDataYet, height: 120)
              else
                _BodyWeightChart(measurements: analyticsVM.measurements),
              const SizedBox(height: 32),

              // --- Measurement history ---
              Text(l10n.measurementHistory,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.measurements.isEmpty)
                _EmptyChart(message: l10n.noDataYet, height: 80)
              else
                ...analyticsVM.measurements.map(
                  (m) => Card(
                    child: ListTile(
                      title: Text(l10n.weightEntry(
                          m.bodyWeight.toStringAsFixed(1), unit)),
                      subtitle: Text(l10n.bodyFatEntry(
                          m.bodyFatPercentage.toStringAsFixed(1))),
                      trailing: Text(
                        dateFormat.format(DateTime.parse(m.date)),
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatWeight(double weight) => weight == weight.roundToDouble()
    ? weight.toStringAsFixed(0)
    : weight.toStringAsFixed(1);

class _EmptyChart extends StatelessWidget {
  final String message;
  final double height;

  const _EmptyChart({required this.message, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: AppTheme.textLight)),
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<ExerciseProgressPoint> points;
  final bool show1Rm;
  final DateFormat dateFormat;

  const _ProgressChart({
    required this.points,
    required this.show1Rm,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _EmptyChart(message: AppLocalizations.of(context).noDataYet);
    }
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(),
            show1Rm ? e.value.estimated1Rm : e.value.maxWeight))
        .toList();
    final labelInterval = (points.length / 4).ceil().clamp(1, 100).toDouble();

    return SizedBox(
      height: 250,
      // Time axes must stay left-to-right even in RTL locales.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: labelInterval,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dateFormat.format(points[index].date),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textLight),
                      ),
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
                color: AppTheme.primary,
                barWidth: 4,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  final List<WeeklyVolumePoint> points;
  final DateFormat dateFormat;

  const _VolumeChart({required this.points, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dateFormat.format(points[index].weekStart),
                        style: const TextStyle(
                            fontSize: 9, color: AppTheme.textLight),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: points
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.volume,
                        color: AppTheme.primary,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _BodyWeightChart extends StatelessWidget {
  final List<BodyMeasurement> measurements;

  const _BodyWeightChart({required this.measurements});

  @override
  Widget build(BuildContext context) {
    // Measurements arrive newest-first; the chart needs oldest-first.
    final ascending = measurements.reversed.toList();
    final spots = ascending
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bodyWeight))
        .toList();

    return SizedBox(
      height: 200,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppTheme.textMain,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
