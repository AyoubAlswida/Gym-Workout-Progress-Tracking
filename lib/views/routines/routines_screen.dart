import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/domain_translations.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/routine.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navRoutines),
      ),
      body: routineVM.routines.isEmpty
          ? Center(child: Text(l10n.noRoutinesYet))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              itemCount: routineVM.routines.length,
              itemBuilder: (context, index) {
                final routine = routineVM.routines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    title: Text(
                      localizedRoutineName(
                          l10n, routine.name, routine.isPreset),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      l10n.exercisesCount(
                          routineVM.exerciseCountFor(routine.id!)),
                      style: const TextStyle(color: AppTheme.textLight),
                    ),
                    onTap: () => _openEditor(context, routine),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              _openEditor(context, routine);
                            } else if (action == 'delete') {
                              _confirmDelete(context, routine);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'edit', child: Text(l10n.edit)),
                            PopupMenuItem(
                                value: 'delete', child: Text(l10n.delete)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill,
                              color: AppTheme.primary, size: 36),
                          onPressed: () => _startSession(context, routine),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openEditor(context, null),
      ),
    );
  }

  Future<void> _startSession(BuildContext context, Routine routine) async {
    final sessionVM = context.read<SessionViewModel>();
    final routineVM = context.read<RoutineViewModel>();
    final exercises = await routineVM.getRoutineExercises(routine.id!);
    await sessionVM.initSessionFromRoutine(routine, exercises);
  }

  void _openEditor(BuildContext context, Routine? routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(routine: routine),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Routine routine) async {
    final l10n = AppLocalizations.of(context);
    final routineVM = context.read<RoutineViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteRoutine),
        content: Text(l10n.deleteRoutineConfirm(
            localizedRoutineName(l10n, routine.name, routine.isPreset))),
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
      await routineVM.deleteRoutine(routine.id!);
    }
  }
}
