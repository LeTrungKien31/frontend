import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../provider.dart';

class ActivityModel {
  final String name;
  final String icon;
  final int kcalPerHour;
  final double met;

  const ActivityModel({
    required this.name,
    required this.icon,
    required this.kcalPerHour,
    required this.met,
  });
}

final defaultActivities = [
  ActivityModel(name: 'Đạp xe', icon: '🚴', kcalPerHour: 500, met: 7.5),
  ActivityModel(name: 'Bóng chuyền', icon: '🏐', kcalPerHour: 250, met: 4.0),
  ActivityModel(name: 'Đi bộ', icon: '🚶', kcalPerHour: 350, met: 3.5),
  ActivityModel(name: 'Nhảy dây', icon: '🤸', kcalPerHour: 800, met: 12.0),
  ActivityModel(name: 'Bóng đá', icon: '⚽', kcalPerHour: 540, met: 7.0),
  ActivityModel(name: 'Chạy bộ', icon: '🏃', kcalPerHour: 450, met: 7.5),
  ActivityModel(name: 'Bóng rổ', icon: '🏀', kcalPerHour: 550, met: 6.5),
];

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});
  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  Future<void> _showAddDialog(ActivityModel activity) async {
    final minutesController = TextEditingController(text: '30');
    final weightController = TextEditingController(text: '65');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm ${activity.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Thời gian (phút)',
                suffixText: 'phút',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cân nặng',
                suffixText: 'kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final minutes = int.tryParse(minutesController.text) ?? 30;
        final weight = double.tryParse(weightController.text) ?? 65;

        // Validate input
        if (minutes <= 0 || weight <= 0) {
          throw Exception('Invalid input values');
        }

        await ref
            .read(activityServiceProvider)
            .add(
              name: activity.name,
              met: activity.met,
              minutes: minutes,
              weightKg: weight,
            );

        ref.invalidate(todayKcalOutProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${activity.name} $minutes phút'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('VẬN ĐỘNG'),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: (defaultActivities.length / 2).ceil(),
        itemBuilder: (ctx, rowIndex) {
          final firstIndex = rowIndex * 2;
          final secondIndex = firstIndex + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActivityCard(defaultActivities[firstIndex]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: secondIndex < defaultActivities.length
                      ? _buildActivityCard(defaultActivities[secondIndex])
                      : const SizedBox(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return InkWell(
      onTap: () => _showAddDialog(activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  activity.icon,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${activity.kcalPerHour} Kcal/giờ',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
