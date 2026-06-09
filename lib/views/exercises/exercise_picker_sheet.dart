import 'package:flutter/material.dart';
import '../../core/localization/domain_translations.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/exercise.dart';
import '../../repositories/exercise_repository.dart';

/// Searchable bottom sheet returning the picked [Exercise], or null.
/// Reused by the active session and the routine editor.
Future<Exercise?> showExercisePickerSheet(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  // Standalone repository read: the sheet must not disturb the library
  // screen's filter state held in ExerciseViewModel.
  final _repository = ExerciseRepository();
  List<Exercise> _exercises = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final exercises = await _repository.getExercises(search: _search);
    if (mounted) setState(() => _exercises = exercises);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchExercises,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  _search = value;
                  _load();
                },
              ),
            ),
            Expanded(
              child: _exercises.isEmpty
                  ? Center(child: Text(l10n.noExercisesFound))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        return ListTile(
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${localizedMuscleGroup(l10n, exercise.muscleGroup)}'
                            ' · ${localizedEquipment(l10n, exercise.equipment)}',
                          ),
                          onTap: () => Navigator.of(context).pop(exercise),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
