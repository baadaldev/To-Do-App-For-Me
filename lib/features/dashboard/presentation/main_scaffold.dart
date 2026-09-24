import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../ai_coach/presentation/ai_coach_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../gamification/presentation/gamification_screen.dart';
import '../../heatmap/presentation/heatmap_screen.dart';
import '../../reflection/presentation/daily_reflection_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tasks/presentation/task_list_screen.dart';
import 'dashboard_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      DashboardScreen(
        onNavigateToPlanner: () => _onTabSelected(1),
        onNavigateToHeatmap: () => _onTabSelected(2),
        onNavigateToAnalytics: () => _onTabSelected(4),
      ),
      const TaskListScreen(),
      const HeatmapScreen(),
      const AiCoachScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.track_changes_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 10),
                  Text(
                    'Discipline Tracker',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Consistency Over Intensity',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist_rounded),
              title: const Text('Daily Planner'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Heatmap Calendar'),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology_rounded),
              title: const Text('AI Coach Insights'),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text('Analytics & Trends'),
              selected: _currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded, color: AppColors.accent),
              title: const Text('Achievements & Badges'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement_rounded, color: AppColors.secondary),
              title: const Text('Daily Reflection Journal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyReflectionScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings & Export'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Heatmap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Coach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
