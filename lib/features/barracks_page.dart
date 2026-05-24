import 'package:flutter/material.dart';

import '../core/app_controller.dart';

class BarracksPage extends StatelessWidget {
  const BarracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppControllerScope.of(context);
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('背包 / 兵营', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              ...app.inventory.map((item) => ListTile(
                    title: Text(item.itemId),
                    trailing: Text('x${item.quantity}'),
                  )),
              const SizedBox(height: 12),
              ...app.barracks.map((soldier) => ListTile(
                    title: Text(soldier.soldierType),
                    subtitle: Text('Lv.${soldier.level}'),
                  )),
            ],
          ),
        );
      },
    );
  }
}
