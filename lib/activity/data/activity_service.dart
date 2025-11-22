import '../../core/dio_client.dart';

class ActivityService {
  final DioClient _client;

  ActivityService(this._client);

  /// Add activity log
  Future<void> add({
    required String name,
    required double met,
    required int minutes,
    required double weightKg,
  }) async {
    try {
      await _client.post('/activity', data: {
        'name': name,
        'met': met,
        'minutes': minutes,
        'weightKg': weightKg,
      });
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  /// Get today's total calories burned
  Future<int> todayKcalOut() async {
    try {
      final res = await _client.get('/activity/today/total');
      return (res.data['totalKcal'] as num).toInt();
    } catch (e) {
      throw Exception('Failed to get today calories: $e');
    }
  }

  /// Calculate calories burned
  /// Formula: MET × 3.5 × weight(kg) / 200 × minutes
  int calculateKcal(double met, double weightKg, int minutes) {
    double perMin = met * 3.5 * weightKg / 200.0;
    return (perMin * minutes).round();
  }
}