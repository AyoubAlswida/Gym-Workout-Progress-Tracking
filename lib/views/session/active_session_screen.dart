import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/coach/coach_service.dart';
import '../../core/localization/domain_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/workout_set.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../exercises/exercise_picker_sheet.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatElapsed(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    final hours = seconds ~/ 3600;
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }

  Future<void> _finish(BuildContext context) async {
    final sessionVM = context.read<SessionViewModel>();
    final workoutVM = context.read<WorkoutViewModel>();
    await sessionVM.finishSession(notes: _notesController.text);
    await workoutVM.loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context);
    final unit = settingsVM.isMetric ? l10n.kg : l10n.lbs;
    final routineName = sessionVM.activeSession?.routineName;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routineName == null
                  ? l10n.workout
                  : routineName == 'Quick Workout'
                      ? l10n.quickWorkout
                      : localizedRoutineName(l10n, routineName, true),
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              sessionVM.isResting
                  ? l10n.restLabel(sessionVM.restSecondsRemaining)
                  : _formatElapsed(sessionVM.elapsedSeconds),
              style: TextStyle(
                color: sessionVM.isResting
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ...sessionVM.exerciseGroups.map(
                    (group) => _ExerciseGroupCard(
                      key: ValueKey(group.exercise.id),
                      group: group,
                      unit: unit,
                      isMetric: settingsVM.isMetric,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final exercise = await showExercisePickerSheet(context);
                      if (exercise != null && context.mounted) {
                        await sessionVM.addExercise(exercise);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addExercise),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.sessionNotes,
                      hintText: l10n.sessionNotesHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => _finish(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: Text(l10n.finishWorkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseGroupCard extends StatefulWidget {
  final SessionExerciseGroup group;
  final String unit;
  final bool isMetric;

  const _ExerciseGroupCard({
    super.key,
    required this.group,
    required this.unit,
    required this.isMetric,
  });

  @override
  State<_ExerciseGroupCard> createState() => _ExerciseGroupCardState();
}

class _ExerciseGroupCardState extends State<_ExerciseGroupCard> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  bool get _isCardio => widget.group.exercise.category == 'Cardio';

  static const _metersPerKm = 1000.0;
  static const _metersPerMile = 1609.34;

  double get _metersPerUnit => widget.isMetric ? _metersPerKm : _metersPerMile;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) =>
      weight == weight.roundToDouble()
          ? weight.toStringAsFixed(0)
          : weight.toStringAsFixed(1);

  String _reasonLabel(AppLocalizations l10n, SuggestionReason reason) {
    switch (reason) {
      case SuggestionReason.addRep:
        return l10n.coachReasonAddRep;
      case SuggestionReason.increaseWeight:
        return l10n.coachReasonIncreaseWeight;
      case SuggestionReason.maintain:
        return l10n.coachReasonMaintain;
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }

  /// e.g. "12:30 — 2.5 km", or just "12:30" when no distance was logged.
  String _cardioSummary(WorkoutSet set, AppLocalizations l10n) {
    final duration = _formatDuration(set.durationSeconds ?? 0);
    final meters = set.distanceMeters;
    if (meters == null || meters <= 0) return duration;
    final distance = (meters / _metersPerUnit).toStringAsFixed(2);
    final distUnit = widget.isMetric ? l10n.kmUnit : l10n.miUnit;
    return '$duration — $distance $distUnit';
  }

  Future<void> _toggleSet(BuildContext context, WorkoutSet set) async {
    final sessionVM = context.read<SessionViewModel>();
    final l10n = AppLocalizations.of(context);
    await sessionVM.toggleSetCompletion(set);
    final pr = sessionVM.consumeLatestPr();
    if (pr != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text(
            l10n.newPr(pr.exerciseName, _formatWeight(pr.weight), widget.unit),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.read<SessionViewModel>();
    final l10n = AppLocalizations.of(context);
    final group = widget.group;
    final lastSet = sessionVM.lastPerformanceFor(group.exercise.id!);
    final suggestion =
        _isCardio ? null : sessionVM.suggestionFor(group.exercise.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.exercise.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (group.targetSets != null && group.targetReps != null)
                  Text(
                    l10n.targetSetsReps(group.targetSets!, group.targetReps!),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            if (lastSet != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isCardio
                      ? l10n.lastTimeGeneric(_cardioSummary(lastSet, l10n))
                      : l10n.lastTime(_formatWeight(lastSet.weight),
                          widget.unit, lastSet.reps),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13),
                ),
              ),
            if (suggestion != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.coachTryWeightReps(_formatWeight(suggestion.weight), widget.unit, suggestion.reps)} · ${_reasonLabel(l10n, suggestion.reason)}',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            ...group.sets.asMap().entries.map((entry) {
              final set = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: set.isCompleted
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(l10n.setNumber(entry.key + 1),
                        style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    Text(
                      _isCardio
                          ? _cardioSummary(set, l10n)
                          : l10n.setSummary(_formatWeight(set.weight),
                              widget.unit, set.reps),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    IconButton(
                      icon: Icon(
                        set.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: set.isCompleted
                            ? AppTheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      onPressed: () => _toggleSet(context, set),
                    ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                if (_isCardio) ...[
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: l10n.durationMinutesField,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _distanceController,
                      decoration: InputDecoration(
                        labelText: l10n.distanceField(
                            widget.isMetric ? l10n.kmUnit : l10n.miUnit),
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: l10n.weight,
                        isDense: true,
                        border: const OutlineInputBorder(),
                        hintText: suggestion != null
                            ? _formatWeight(suggestion.weight)
                            : lastSet != null
                                ? _formatWeight(lastSet.weight)
                                : null,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: InputDecoration(
                        labelText: l10n.reps,
                        isDense: true,
                        border: const OutlineInputBorder(),
                        hintText: suggestion?.reps.toString() ??
                            lastSet?.reps.toString(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  onPressed: () {
                    if (_isCardio) {
                      final minutes =
                          double.tryParse(_durationController.text) ?? 0.0;
                      final distance =
                          double.tryParse(_distanceController.text);
                      if (minutes > 0) {
                        sessionVM.addSet(
                          group.exercise.id!,
                          0,
                          0,
                          durationSeconds: (minutes * 60).round(),
                          distanceMeters: (distance != null && distance > 0)
                              ? distance * _metersPerUnit
                              : null,
                        );
                        _durationController.clear();
                        _distanceController.clear();
                      }
                    } else {
                      final weight =
                          double.tryParse(_weightController.text) ?? 0.0;
                      final reps = int.tryParse(_repsController.text) ?? 0;
                      if (weight > 0 && reps > 0) {
                        sessionVM.addSet(group.exercise.id!, weight, reps);
                        _repsController.clear();
                      }
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
