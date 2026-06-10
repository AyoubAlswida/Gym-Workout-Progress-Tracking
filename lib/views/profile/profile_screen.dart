import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/backup_file_service.dart';
import '../../services/backup_service.dart';
import '../../viewmodels/exercise_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/workout_viewmodel.dart';
import '../exercises/exercise_library_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).dividerColor,
            child: Icon(Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              l10n.athlete,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            child: ListTile(
              title: Text(l10n.language),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('EN')),
                  ButtonSegment(value: 'ar', label: Text('ع')),
                ],
                selected: {settingsVM.locale.languageCode},
                onSelectionChanged: (selection) {
                  settingsVM.setLocale(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.theme,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem)),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text(l10n.themeLight)),
                      ButtonSegment(
                          value: ThemeMode.dark, label: Text(l10n.themeDark)),
                    ],
                    selected: {settingsVM.themeMode},
                    onSelectionChanged: (selection) {
                      settingsVM.setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(l10n.measurementUnit),
              subtitle: Text(
                  settingsVM.isMetric ? l10n.metricUnits : l10n.imperialUnits),
              trailing: Switch(
                value: settingsVM.isMetric,
                activeThumbColor: AppTheme.primary,
                onChanged: (val) {
                  settingsVM.toggleUnits();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.restTimerDuration,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [30, 60, 90, 120, 180].map((seconds) {
                      return ChoiceChip(
                        label: Text(l10n.secondsValue(seconds)),
                        selected: settingsVM.restTimerSeconds == seconds,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                        onSelected: (_) {
                          settingsVM.setRestTimerSeconds(seconds);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: AppTheme.primary),
              title: Text(l10n.exerciseLibrary),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExerciseLibraryScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.monitor_weight_outlined,
                  color: AppTheme.primary),
              title: Text(l10n.logNewMeasurement),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showMeasurementDialog(context),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.table_chart, color: AppTheme.primary),
                  title: Text(l10n.exportCsv),
                  onTap: () => _exportCsv(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup, color: AppTheme.primary),
                  title: Text(l10n.exportJson),
                  onTap: () => _exportJson(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.restore, color: AppTheme.primary),
                  title: Text(l10n.restoreBackup),
                  onTap: () => _restoreBackup(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final csv = await BackupService().exportWorkoutCsv();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final saved =
        await BackupFileService().saveTextFile(csv, 'gym_workouts_$date.csv');
    if (saved && context.mounted) _showSnack(context, l10n.exportSuccess);
  }

  Future<void> _exportJson(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final json = await BackupService().exportJsonBackup();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final saved =
        await BackupFileService().saveTextFile(json, 'gym_backup_$date.json');
    if (saved && context.mounted) _showSnack(context, l10n.exportSuccess);
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreWarningTitle),
        content: Text(l10n.restoreWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final content = await BackupFileService()
        .pickTextFile(allowedExtensions: ['json']);
    if (content == null || !context.mounted) return;

    try {
      await BackupService().importJsonBackup(content);
    } on BackupException catch (e) {
      if (context.mounted) {
        _showSnack(
            context,
            e.reason == 'newerVersion'
                ? l10n.importNewerVersion
                : l10n.importInvalidFile);
      }
      return;
    }

    if (!context.mounted) return;
    // Every viewmodel caches DB state; refresh them all.
    await context.read<WorkoutViewModel>().loadSessions();
    if (!context.mounted) return;
    await context.read<ExerciseViewModel>().loadExercises();
    if (!context.mounted) return;
    await context.read<RoutineViewModel>().loadRoutines();
    if (!context.mounted) return;
    await context.read<ProfileViewModel>().loadMeasurements();
    if (context.mounted) _showSnack(context, l10n.restoreSuccess);
  }

  Future<void> _showMeasurementDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final profileVM = context.read<ProfileViewModel>();
    final settingsVM = context.read<SettingsViewModel>();
    final lengthUnit = settingsVM.isMetric ? l10n.cmUnit : l10n.inUnit;
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final waistController = TextEditingController();
    final chestController = TextEditingController();
    final armsController = TextEditingController();
    final hipsController = TextEditingController();
    final thighsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? optionalNumberValidator(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      return double.tryParse(value) == null ? l10n.invalidNumber : null;
    }

    Widget optionalField(TextEditingController controller, String label) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: '$label ($lengthUnit)'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: optionalNumberValidator,
      );
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logNewMeasurement),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: weightController,
                    autofocus: true,
                    decoration:
                        InputDecoration(labelText: l10n.bodyWeightField),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        double.tryParse(value ?? '') == null
                            ? l10n.invalidNumber
                            : null,
                  ),
                  TextFormField(
                    controller: bodyFatController,
                    decoration: InputDecoration(labelText: l10n.bodyFatField),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        double.tryParse(value ?? '') == null
                            ? l10n.invalidNumber
                            : null,
                  ),
                  ExpansionTile(
                    title: Text(l10n.moreMeasurements,
                        style: const TextStyle(fontSize: 14)),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: [
                      optionalField(waistController, l10n.waistField),
                      optionalField(chestController, l10n.chestField),
                      optionalField(armsController, l10n.armsField),
                      optionalField(hipsController, l10n.hipsField),
                      optionalField(thighsController, l10n.thighsField),
                    ],
                  ),
                ],
              ),
            ),
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
      double? optional(TextEditingController c) =>
          c.text.trim().isEmpty ? null : double.parse(c.text);
      await profileVM.addMeasurement(
        double.parse(weightController.text),
        double.parse(bodyFatController.text),
        waist: optional(waistController),
        chest: optional(chestController),
        arms: optional(armsController),
        hips: optional(hipsController),
        thighs: optional(thighsController),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.measurementLogged)),
        );
      }
    }
  }
}
