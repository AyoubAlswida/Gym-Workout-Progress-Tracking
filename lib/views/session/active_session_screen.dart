import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: AppTheme.cardColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
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
                color: sessionVM.isResting ? Colors.red : AppTheme.textLight,
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
                  backgroundColor: AppTheme.textMain,
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

  const _ExerciseGroupCard({super.key, required this.group, required this.unit});

  @override
  State<_ExerciseGroupCard> createState() => _ExerciseGroupCardState();
}

class _ExerciseGroupCardState extends State<_ExerciseGroupCard> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) =>
      weight == weight.roundToDouble()
          ? weight.toStringAsFixed(0)
          : weight.toStringAsFixed(1);

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
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
              ],
            ),
            if (lastSet != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.lastTime(
                      _formatWeight(lastSet.weight), widget.unit, lastSet.reps),
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 13),
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
                      l10n.setSummary(
                          _formatWeight(set.weight), widget.unit, set.reps),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    IconButton(
                      icon: Icon(
                        set.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: set.isCompleted
                            ? AppTheme.primary
                            : AppTheme.textLight,
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
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: l10n.weight,
                      isDense: true,
                      border: const OutlineInputBorder(),
                      hintText: lastSet != null
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
                      hintText: lastSet?.reps.toString(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  onPressed: () {
                    final weight =
                        double.tryParse(_weightController.text) ?? 0.0;
                    final reps = int.tryParse(_repsController.text) ?? 0;
                    if (weight > 0 && reps > 0) {
                      sessionVM.addSet(group.exercise.id!, weight, reps);
                      _repsController.clear();
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
