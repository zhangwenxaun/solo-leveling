import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/rules_engine.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

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
              Text('任务', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              ...app.habits.map(
                (habit) {
                  final def = HabitEngine.definitionFor(habit.habitCode);
                  return Card(
                    color: const Color(0xFF11131B),
                    child: ListTile(
                      title: Text(
                        '${def.name}  ${habit.currentProgress.toStringAsFixed(0)}/${habit.targetValue.toStringAsFixed(0)} ${def.unitLabel}',
                      ),
                      subtitle: Text('阶段：${habit.evolutionState.name}  奖励：${habit.rewardCoins} 金币'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => app.addProgress(habit.habitCode, 20),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () => app.addProgress(habit.habitCode, 10),
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: app.settleDay,
                child: const Text('结算今日任务'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _refreshTasks(context),
                child: const Text('刷新任务券'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _manualMinutes(context),
                child: const Text('自定义时间/数量'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshTasks(BuildContext context) async {
    final app = AppControllerScope.of(context);
    await app.refreshTasks();
  }

  Future<void> _manualMinutes(BuildContext context) async {
    final app = AppControllerScope.of(context);
    final amountController = TextEditingController(text: '20');
    String selectedCode = app.habits.first.habitCode;
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11131B),
        title: const Text('输入完成量'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCode,
                isExpanded: true,
                items: app.habits
                    .map((habit) {
                      final def = HabitEngine.definitionFor(habit.habitCode);
                      return DropdownMenuItem(
                          value: habit.habitCode,
                          child: Text('${def.name} (${def.unitLabel})'));
                    })
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCode = value);
                },
              ),
              TextField(controller: amountController, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, amountController.text), child: const Text('确认')),
        ],
      ),
    );
    if (selected == null) return;
    final value = double.tryParse(selected) ?? 0;
    await app.addProgress(selectedCode, value);
  }
}
