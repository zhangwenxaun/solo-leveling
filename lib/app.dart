import 'package:flutter/material.dart';

import 'core/app_controller.dart';
import 'features/barracks_page.dart';
import 'features/battle_page.dart';
import 'features/home_page.dart';
import 'features/tasks_page.dart';

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppController>(
      future: AppController.create(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return AppControllerScope(
          controller: snapshot.data!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Solo Leveling',
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00D2FF),
                brightness: Brightness.dark,
                primary: const Color(0xFF00D2FF),
                secondary: const Color(0xFFB88B00),
                surface: const Color(0xFF11131B),
              ),
              scaffoldBackgroundColor: const Color(0xFF0D0E15),
              useMaterial3: true,
            ),
            home: const RootShell(),
          ),
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const TasksPage(),
      const BattlePage(),
      const BarracksPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bolt), label: '首页'),
          NavigationDestination(icon: Icon(Icons.assignment), label: '任务'),
          NavigationDestination(icon: Icon(Icons.sports_martial_arts), label: '战斗'),
          NavigationDestination(icon: Icon(Icons.shield), label: '兵营'),
        ],
      ),
    );
  }
}
