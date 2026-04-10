import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultRoutines = ['Push Day', 'Pull Day', 'Legs', 'Full Body'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: defaultRoutines.length,
        itemBuilder: (context, index) {
          final routine = defaultRoutines[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(routine, style: Theme.of(context).textTheme.titleLarge),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_fill, color: AppTheme.primary, size: 36),
                onPressed: () {
                  context.read<SessionViewModel>().initSession(routine);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom routines coming soon!')),
          );
        },
      ),
    );
  }
}
