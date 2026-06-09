import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/routine.dart';
import '../../models/routine_exercise.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../exercises/exercise_picker_sheet.dart';

class RoutineEditorScreen extends StatefulWidget {
  /// Null creates a new routine.
  final Routine? routine;

  const RoutineEditorScreen({super.key, this.routine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late final TextEditingController _nameController;
  final List<RoutineExercise> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
    if (widget.routine != null) {
      context
          .read<RoutineViewModel>()
          .getRoutineExercises(widget.routine!.id!)
          .then((items) {
        if (mounted) setState(() => _items.addAll(items));
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercise = await showExercisePickerSheet(context);
    if (exercise == null || !mounted) return;
    if (_items.any((item) => item.exerciseId == exercise.id)) return;
    setState(() {
      _items.add(RoutineExercise(
        routineId: widget.routine?.id ?? 0,
        exerciseId: exercise.id!,
        targetSets: 3,
        targetReps: 10,
        orderIndex: _items.length,
        exerciseName: exercise.name,
      ));
    });
  }

  void _updateItem(int index, {int? sets, int? reps}) {
    final item = _items[index];
    setState(() {
      _items[index] = RoutineExercise(
        id: item.id,
        routineId: item.routineId,
        exerciseId: item.exerciseId,
        targetSets: (sets ?? item.targetSets).clamp(1, 20),
        targetReps: (reps ?? item.targetReps).clamp(1, 100),
        orderIndex: item.orderIndex,
        exerciseName: item.exerciseName,
      );
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routineNeedsNameAndExercise)),
      );
      return;
    }
    final routineVM = context.read<RoutineViewModel>();
    await routineVM.saveRoutine(
      Routine(
        id: widget.routine?.id,
        name: name,
        isPreset: widget.routine?.isPreset ?? false,
      ),
      _items,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? l10n.newRoutine : l10n.editRoutine),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save,
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.routineName,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: ValueKey('${item.exerciseId}-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    color: Colors.red.shade400,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _items.removeAt(index));
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(item.exerciseName ?? ''),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Stepper(
                            label: l10n.targetSetsReps(
                                item.targetSets, item.targetReps),
                            onSetsChanged: (delta) => _updateItem(index,
                                sets: item.targetSets + delta),
                            onRepsChanged: (delta) => _updateItem(index,
                                reps: item.targetReps + delta),
                          ),
                        ],
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_handle,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: Text(l10n.addExercise),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact sets/reps adjuster: "- 3 x 10 +" rows for sets and reps.
class _Stepper extends StatelessWidget {
  final String label;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;

  const _Stepper({
    required this.label,
    required this.onSetsChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () => onSetsChanged(-1),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () => onSetsChanged(1),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.exposure_minus_1, size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () => onRepsChanged(-1),
        ),
        IconButton(
          icon: const Icon(Icons.plus_one, size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () => onRepsChanged(1),
        ),
      ],
    );
  }
}
