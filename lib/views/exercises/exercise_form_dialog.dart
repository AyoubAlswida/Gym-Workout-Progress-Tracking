import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/domain_translations.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/exercise.dart';
import '../../viewmodels/exercise_viewmodel.dart';

/// Opens the add/edit form. Pass [exercise] to edit an existing custom one.
Future<void> showExerciseFormDialog(BuildContext context,
    {Exercise? exercise}) async {
  final l10n = AppLocalizations.of(context);
  final exerciseVM = context.read<ExerciseViewModel>();
  final nameController = TextEditingController(text: exercise?.name ?? '');
  final formKey = GlobalKey<FormState>();
  var category = exercise?.category ?? kCategories.first;
  var muscleGroup = exercise?.muscleGroup ?? kMuscleGroups.first;
  var equipment = exercise?.equipment ?? kEquipment.first;

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(exercise == null ? l10n.newExercise : l10n.editExercise),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.exerciseName),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? l10n.fieldRequired
                            : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(labelText: l10n.category),
                    items: kCategories
                        .map((key) => DropdownMenuItem(
                            value: key,
                            child: Text(localizedCategory(l10n, key))))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: muscleGroup,
                    decoration: InputDecoration(labelText: l10n.muscleGroup),
                    items: kMuscleGroups
                        .map((key) => DropdownMenuItem(
                            value: key,
                            child: Text(localizedMuscleGroup(l10n, key))))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => muscleGroup = value ?? muscleGroup),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: equipment,
                    decoration: InputDecoration(labelText: l10n.equipment),
                    items: kEquipment
                        .map((key) => DropdownMenuItem(
                            value: key,
                            child: Text(localizedEquipment(l10n, key))))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => equipment = value ?? equipment),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );

  if (saved == true) {
    final updated = Exercise(
      id: exercise?.id,
      name: nameController.text.trim(),
      category: category,
      muscleGroup: muscleGroup,
      equipment: equipment,
      isCustom: true,
    );
    if (exercise == null) {
      await exerciseVM.addExercise(updated);
    } else {
      await exerciseVM.updateExercise(updated);
    }
  }
}
