import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'routines/routines_screen.dart';
import 'analytics/analytics_screen.dart';
import 'profile/profile_screen.dart';
import 'session/active_session_screen.dart';
import '../l10n/gen/app_localizations.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RoutinesScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionViewModel = context.watch<SessionViewModel>();
    final l10n = AppLocalizations.of(context);

    if (sessionViewModel.activeSession != null) {
      return const ActiveSessionScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Analytics lives in an IndexedStack and won't rebuild on tab
            // switch; refresh so freshly finished sessions show up.
            context.read<AnalyticsViewModel>().load();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard), label: l10n.navHome),
          BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt), label: l10n.navRoutines),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart), label: l10n.navAnalytics),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: l10n.navProfile),
        ],
      ),
    );
  }
}
