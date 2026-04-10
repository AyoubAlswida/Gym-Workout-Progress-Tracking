import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.dividerColor,
            child: Icon(Icons.person, size: 50, color: AppTheme.textLight),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('Athlete Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
          Card(
            child: ListTile(
              title: const Text('Measurement Unit'),
              subtitle: Text(profileVM.isMetric ? 'Metric (KG/CM)' : 'Imperial (LBS/IN)'),
              trailing: Switch(
                value: profileVM.isMetric,
                activeThumbColor: AppTheme.primary,
                onChanged: (val) {
                  profileVM.toggleUnits();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Log New Measurement'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                profileVM.addMeasurement(74.5, 14.8);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Measurement logged securely offline!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
