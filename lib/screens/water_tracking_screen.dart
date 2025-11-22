import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../provider.dart';

class WaterTrackingScreen extends ConsumerStatefulWidget {
  const WaterTrackingScreen({super.key});
  @override
  ConsumerState<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends ConsumerState<WaterTrackingScreen> {
  DateTime selectedDate = DateTime.now();
  final int dailyGoal = 2675;
  final TextEditingController _customAmountController = TextEditingController(text: '1000');

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _addWater(int amount) async {
    await ref.read(waterServiceProvider).add(amount);
    ref.invalidate(todayWaterProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm +$amount ml'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayWater = ref.watch(todayWaterProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: todayWater.when(
                data: (current) => _buildContent(current),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateStr = '${selectedDate.day.toString().padLeft(2, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.waterBlue),
            onPressed: () => _changeDate(-1),
          ),
          Text(dateStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.waterBlue)),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.waterBlue),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int currentWater) {
    final percentage = (currentWater / dailyGoal * 100).clamp(0.0, 100.0);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildWaterGlass(percentage, currentWater),
          const SizedBox(height: 30),
          _buildQuickAddButtons(),
          const SizedBox(height: 20),
          _buildCustomInput(),
          const SizedBox(height: 16),
          _buildCaloriesInput(),
          const SizedBox(height: 20),
          _buildReminderButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWaterGlass(double percentage, int current) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: WaterGlassPainter(percentage / 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.waterBlueDark)),
              const SizedBox(height: 4),
              Text('$current/$dailyGoal ml',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    final amounts = [100, 50, 200, 500];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: amounts.map((amt) {
        final isFirst = amt == 100;
        return ElevatedButton(
          onPressed: () => _addWater(amt),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFirst ? AppColors.error : AppColors.waterBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(isFirst ? '-$amt' : '+$amt'),
        );
      }).toList(),
    );
  }

  Widget _buildCustomInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: AppColors.waterBlue),
          const SizedBox(width: 12),
          const Text('Uống nước', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixText: '+',
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = int.tryParse(_customAmountController.text) ?? 0;
              if (amt > 0) _addWater(amt);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.waterBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('Thêm số Calories', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildReminderButton() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/reminders'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/alarm.png', width: 24, height: 24,
                errorBuilder: (_, __, ___) => const Icon(Icons.alarm, color: AppColors.warning)),
            const SizedBox(width: 8),
            const Text('Bật nhắc nhở uống nước',
                style: TextStyle(fontSize: 16, color: AppColors.warning)),
          ],
        ),
      ),
    );
  }
}

class WaterGlassPainter extends CustomPainter {
  final double fillPercent;
  WaterGlassPainter(this.fillPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, bgPaint);

    // Water fill arc
    final fillPaint = Paint()
      ..color = AppColors.waterBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * math.pi * fillPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );

    // Inner water wave effect
    if (fillPercent > 0) {
      final innerRadius = radius - 20;
      final waterHeight = innerRadius * 2 * fillPercent;
      final waterTop = center.dy + innerRadius - waterHeight;
      
      final wavePaint = Paint()
        ..color = AppColors.waterBlue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      final path = Path();
      path.addOval(Rect.fromCircle(center: center, radius: innerRadius));
      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(
        Rect.fromLTRB(0, waterTop, size.width, size.height),
        wavePaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant WaterGlassPainter old) => old.fillPercent != fillPercent;
}