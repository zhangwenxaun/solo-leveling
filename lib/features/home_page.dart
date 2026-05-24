import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppControllerScope.of(context);
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Stack(
          children: [
            Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D0E15), Color(0xFF111B2A)]))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(app: app),
                    const SizedBox(height: 16),
                    _StatusRow(app: app),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _ToggleCard(
                            title: '学习 20min',
                            subtitle: '奖励按单位累计',
                            onTap: () => app.applyActivity(ToggleType.study, 20 / 60),
                          ),
                          _ToggleCard(
                            title: '看屏幕 20min',
                            subtitle: '消耗 eye，增加 fatigue',
                            onTap: () => app.applyActivity(ToggleType.screen, 20 / 60),
                          ),
                          _ToggleCard(
                            title: '远望恢复',
                            subtitle: '点击查看属性说明',
                            onTap: () => _showPropertyHelp(context),
                          ),
                          _ToggleCard(
                            title: '日结算',
                            subtitle: '结算任务与经验',
                            onTap: app.settleDay,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LogPanel(app: app),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPropertyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11131B),
        title: const Text('属性说明'),
        content: const Text('EYE：视力健康度。\nFATIGUE：疲劳值。\n连续看屏幕会先扣 EYE，归零后转化为疲劳惩罚。'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.app});
  final dynamic app;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(app.profile.nickname, style: Theme.of(context).textTheme.headlineMedium),
              Text('Lv.${app.profile.currentLevel}  EXP ${app.profile.accumulatedExp}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        _Chip(label: '金币 ${app.profile.currentCoins}'),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.app});
  final dynamic app;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _InfoBox(title: 'EYE', value: app.status.eye.toStringAsFixed(0))),
        const SizedBox(width: 12),
        Expanded(child: _InfoBox(title: 'FATIGUE', value: app.status.fatigue.toStringAsFixed(0))),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF11131B),
          title: Text(title),
          content: Text(title == 'EYE'
              ? '视力健康度，连续看屏幕会下降。'
              : '疲劳值，越高奖励越少，过高会触发弱化。'),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF171A24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2E3B)),
        ),
        child: Column(children: [Text(title), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF171A24), Color(0xFF0D0E15)]),
          border: Border.all(color: const Color(0xFF3F4A63)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.app});
  final dynamic app;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF11131B), borderRadius: BorderRadius.circular(16)),
      child: ListView(
        children: app.logs.map<Widget>((e) => Text('• $e', style: const TextStyle(color: Colors.white70))).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}
