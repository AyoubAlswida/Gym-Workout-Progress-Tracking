import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.cardColor,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            sessionVM.finishSession();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sessionVM.activeSession?.routineName ?? 'Workout'),
            if (sessionVM.isResting)
              Text(
                'Rest: ${sessionVM.restSecondsRemaining}s',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sessionVM.activeSets.length,
                itemBuilder: (context, index) {
                  final set = sessionVM.activeSets[index];
                  return Card(
                    color: set.isCompleted
                        ? AppTheme.primary.withOpacity(0.1)
                        : AppTheme.cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            'Set ${index + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${set.weight} kg x ${set.reps} reps',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(
                              set.isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: set.isCompleted
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                              size: 32,
                            ),
                            onPressed: () {
                              sessionVM.toggleSetCompletion(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    backgroundColor: AppTheme.primary,
                    onPressed: () {
                      final weight =
                          double.tryParse(_weightController.text) ?? 0.0;
                      final reps = int.tryParse(_repsController.text) ?? 0;
                      if (weight > 0 && reps > 0) {
                        sessionVM.addSet(1, weight, reps);
                        _repsController.clear();
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  sessionVM.finishSession();
                  context.read<WorkoutViewModel>().loadSessions();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.textMain,
                ),
                child: const Text('Finish Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
