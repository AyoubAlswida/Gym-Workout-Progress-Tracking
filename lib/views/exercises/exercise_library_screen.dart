import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/domain_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../viewmodels/exercise_viewmodel.dart';
import 'exercise_form_dialog.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseVM = context.watch<ExerciseViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exerciseLibrary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchExercises,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: exerciseVM.setSearchQuery,
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(l10n.allMuscleGroups),
                    selected: exerciseVM.muscleGroupFilter == null,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                    onSelected: (_) => exerciseVM.setMuscleGroupFilter(null),
                  ),
                ),
                ...kMuscleGroups.map(
                  (muscle) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FilterChip(
                      label: Text(localizedMuscleGroup(l10n, muscle)),
                      selected: exerciseVM.muscleGroupFilter == muscle,
                      selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                      onSelected: (_) => exerciseVM.setMuscleGroupFilter(
                          exerciseVM.muscleGroupFilter == muscle ? null : muscle),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: exerciseVM.exercises.isEmpty
                ? Center(child: Text(l10n.noExercisesFound))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    itemCount: exerciseVM.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exerciseVM.exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${localizedMuscleGroup(l10n, exercise.muscleGroup)}'
                            ' · ${localizedEquipment(l10n, exercise.equipment)}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                          trailing: exercise.isCustom
                              ? Chip(
                                  label: Text(l10n.customBadge,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      AppTheme.primary.withValues(alpha: 0.15),
                                  visualDensity: VisualDensity.compact,
                                )
                              : null,
                          onTap: exercise.isCustom
                              ? () => showExerciseFormDialog(context,
                                  exercise: exercise)
                              : null,
                          onLongPress: exercise.isCustom
                              ? () => _confirmDelete(context, exercise.id!,
                                  exercise.name)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showExerciseFormDialog(context),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, int exerciseId, String name) async {
    final l10n = AppLocalizations.of(context);
    final exerciseVM = context.read<ExerciseViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteExercise),
        content: Text(l10n.deleteExerciseConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final deleted = await exerciseVM.deleteExercise(exerciseId);
      if (!deleted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exerciseInUse)),
        );
      }
    }
  }
}
