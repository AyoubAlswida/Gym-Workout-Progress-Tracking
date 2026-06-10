import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../core/coach/coach_service.dart';
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

enum _MeasurementType { weight, bodyFat, waist, chest, arms, hips, thighs }

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _show1Rm = false;
  _MeasurementType _measurementType = _MeasurementType.weight;

  String _measurementLabel(AppLocalizations l10n, _MeasurementType type) {
    switch (type) {
      case _MeasurementType.weight:
        return l10n.bodyWeightField;
      case _MeasurementType.bodyFat:
        return l10n.bodyFatField;
      case _MeasurementType.waist:
        return l10n.waistField;
      case _MeasurementType.chest:
        return l10n.chestField;
      case _MeasurementType.arms:
        return l10n.armsField;
      case _MeasurementType.hips:
        return l10n.hipsField;
      case _MeasurementType.thighs:
        return l10n.thighsField;
    }
  }

  double? _measurementValue(BodyMeasurement m, _MeasurementType type) {
    switch (type) {
      case _MeasurementType.weight:
        return m.bodyWeight;
      case _MeasurementType.bodyFat:
        return m.bodyFatPercentage;
      case _MeasurementType.waist:
        return m.waist;
      case _MeasurementType.chest:
        return m.chest;
      case _MeasurementType.arms:
        return m.arms;
      case _MeasurementType.hips:
        return m.hips;
      case _MeasurementType.thighs:
        return m.thighs;
    }
  }

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
                const SizedBox(height: 16),
                _CoachInsightsCard(
                  suggestion: analyticsVM.coachSuggestion,
                  isPlateau: analyticsVM.isPlateau,
                  unit: unit,
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
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // --- Body trends (weight / fat / circumferences) ---
              Text(l10n.bodyTrends,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (analyticsVM.measurements.isEmpty)
                _EmptyChart(message: l10n.noDataYet, height: 120)
              else ...[
                DropdownButtonFormField<_MeasurementType>(
                  initialValue: _measurementType,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _MeasurementType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(_measurementLabel(l10n, t))))
                      .toList(),
                  onChanged: (t) {
                    if (t != null) setState(() => _measurementType = t);
                  },
                ),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  // Newest-first from the repo; the chart wants oldest-first.
                  // Entries without this measurement are skipped.
                  final points = analyticsVM.measurements.reversed
                      .map((m) => (
                            date: DateTime.parse(m.date),
                            value: _measurementValue(m, _measurementType),
                          ))
                      .where((p) => p.value != null)
                      .map((p) => (date: p.date, value: p.value!))
                      .toList();
                  if (points.length < 2) {
                    return _EmptyChart(message: l10n.noDataYet, height: 120);
                  }
                  return _MeasurementChart(points: points);
                }),
              ],
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
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
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

class _CoachInsightsCard extends StatelessWidget {
  final CoachSuggestion? suggestion;
  final bool isPlateau;
  final String unit;

  const _CoachInsightsCard({
    required this.suggestion,
    required this.isPlateau,
    required this.unit,
  });

  static String _reasonLabel(AppLocalizations l10n, SuggestionReason reason) {
    switch (reason) {
      case SuggestionReason.addRep:
        return l10n.coachReasonAddRep;
      case SuggestionReason.increaseWeight:
        return l10n.coachReasonIncreaseWeight;
      case SuggestionReason.maintain:
        return l10n.coachReasonMaintain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestion = this.suggestion;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(l10n.coachInsights,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (suggestion == null)
              Text(l10n.noSuggestionYet,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant))
            else ...[
              Text(l10n.coachSuggestedNextSet,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                l10n.coachTryWeightReps(
                    _formatWeight(suggestion.weight), unit, suggestion.reps),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(_reasonLabel(l10n, suggestion.reason),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
            if (isPlateau) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 20, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.plateauWarning,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(l10n.plateauTip,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;
  final double height;

  const _EmptyChart({required this.message, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
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
                        style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
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

class _MeasurementChart extends StatelessWidget {
  final List<({DateTime date, double value})> points;

  const _MeasurementChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
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
                color: Theme.of(context).colorScheme.onSurface,
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
