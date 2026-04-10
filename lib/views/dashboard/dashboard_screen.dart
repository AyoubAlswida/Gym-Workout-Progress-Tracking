import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutVM = context.watch<WorkoutViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final sessionVM = context.read<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Athlete!'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Card (Mock Bar Chart for MVP)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workouts This Week', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final isToday = index == DateTime.now().weekday - 1;
                          final completed = workoutVM.workoutsCompletedThisWeek > index;
                          return Column(
                            children: [
                              Container(
                                width: 24,
                                height: completed ? 80 : 30, // Mock dynamic height
                                decoration: BoxDecoration(
                                  color: isToday ? AppTheme.primary : AppTheme.dividerColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(['M','T','W','T','F','S','S'][index], style: Theme.of(context).textTheme.bodySmall)
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Body Weight Card
              MetricCard(
                title: 'Latest Weight',
                value: profileVM.latestMeasurement != null 
                  ? '${profileVM.latestMeasurement!.bodyWeight.toStringAsFixed(1)} ${profileVM.isMetric ? 'kg' : 'lbs'}' 
                  : '--',
                icon: Icons.monitor_weight_outlined,
              ),
              const Spacer(),
              // Start Workout Button
              ElevatedButton.icon(
                onPressed: () {
                  sessionVM.initSession('Quick Workout');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('START NEW WORKOUT'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
