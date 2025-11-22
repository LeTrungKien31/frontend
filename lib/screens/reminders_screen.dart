import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderModel {
  final String id;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1=Mon, 7=Sun
  bool isEnabled;

  ReminderModel({
    required this.id,
    required this.time,
    required this.daysOfWeek,
    this.isEnabled = true,
  });
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<ReminderModel> _reminders = [
    ReminderModel(
      id: '1',
      time: const TimeOfDay(hour: 7, minute: 20),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      isEnabled: true,
    ),
    ReminderModel(
      id: '2',
      time: const TimeOfDay(hour: 10, minute: 50),
      daysOfWeek: [2, 4, 6],
      isEnabled: true,
    ),
    ReminderModel(
      id: '3',
      time: const TimeOfDay(hour: 4, minute: 0),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      isEnabled: true,
    ),
    ReminderModel(
      id: '4',
      time: const TimeOfDay(hour: 22, minute: 0),
      daysOfWeek: [2, 4, 5, 6],
      isEnabled: false,
    ),
  ];

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return 'Mỗi ngày';
    final dayNames = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days.map((d) => dayNames[d]).join(' ');
  }

  void _showAddReminderDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetReminderScreen(
          onSave: (time, days) {
            setState(() {
              _reminders.add(ReminderModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                time: time,
                daysOfWeek: days,
              ));
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('THÔNG BÁO'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Water glass icon
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('💧', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reminders.length,
              itemBuilder: (ctx, index) => _buildReminderCard(_reminders[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(reminder.time),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDays(reminder.daysOfWeek),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isEnabled,
            onChanged: (value) {
              setState(() {
                reminder.isEnabled = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SetReminderScreen extends StatefulWidget {
  final Function(TimeOfDay time, List<int> days) onSave;
  
  const SetReminderScreen({super.key, required this.onSave});
  
  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  int _selectedHour = 4;
  int _selectedMinute = 50;
  final Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};
  bool _repeat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('THIẾT LẬP THÔNG BÁO'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Chọn thời gian',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            '${_selectedHour.toString().padLeft(2, '0')} : ${_selectedMinute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('giờ', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 60),
              Text('phút', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 30),
          _buildTimePicker('Chọn giờ:', _selectedHour, (val) {
            setState(() => _selectedHour = val);
          }, 24),
          const SizedBox(height: 16),
          _buildTimePicker('Chọn phút:', _selectedMinute, (val) {
            setState(() => _selectedMinute = val);
          }, 60),
          const SizedBox(height: 16),
          _buildRepeatOption(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('HỦY BỎ'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                        _selectedDays.toList(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Set remind sucess')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('THIẾT LẬP'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, int value, Function(int) onChanged, int max) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.waterBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text('🕐', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              items: List.generate(max, (i) => DropdownMenuItem(
                value: i,
                child: Text(i.toString().padLeft(2, '0')),
              )),
              onChanged: (val) => onChanged(val ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.waterBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text('Lặp lại', style: TextStyle(fontSize: 16)),
            const Spacer(),
            Switch(
              value: _repeat,
              onChanged: (val) => setState(() => _repeat = val),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}