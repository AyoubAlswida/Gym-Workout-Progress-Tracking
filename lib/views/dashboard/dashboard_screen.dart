import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutVM = context.watch<WorkoutViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final sessionVM = context.read<SessionViewModel>();
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    // Weekday letters for the Mon..Sun chart, localized.
    final monday = DateTime(2024, 1, 1); // a Monday
    final dayFormat = DateFormat.E(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helloAthlete),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.workoutsThisWeek,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final isToday =
                              index == DateTime.now().weekday - 1;
                          final completed =
                              workoutVM.workoutsCompletedThisWeek > index;
                          return Column(
                            children: [
                              Container(
                                width: 24,
                                height: completed ? 80 : 30,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppTheme.primary
                                      : AppTheme.dividerColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dayFormat.format(
                                    monday.add(Duration(days: index))),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MetricCard(
                title: l10n.latestWeight,
                value: profileVM.latestMeasurement != null
                    ? '${profileVM.latestMeasurement!.bodyWeight.toStringAsFixed(1)} '
                        '${settingsVM.isMetric ? l10n.kg : l10n.lbs}'
                    : '--',
                icon: Icons.monitor_weight_outlined,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  sessionVM.initSession('Quick Workout');
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.startNewWorkout),
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
