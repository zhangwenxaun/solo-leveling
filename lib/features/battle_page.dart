import 'package:flutter/material.dart';

import '../core/app_controller.dart';

class BattlePage extends StatelessWidget {
  const BattlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppControllerScope.of(context);
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('战斗', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: app.runBattle,
                  child: const Text('开始抽 3 打 1'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: app.logs.map((e) => ListTile(title: Text(e))).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
