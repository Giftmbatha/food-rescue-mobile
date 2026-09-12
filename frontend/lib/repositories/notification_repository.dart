import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _api;

  NotificationRepository(this._api);

  Future<List<NotificationModel>>
      getNotifications() async {
    final response =
        await _api.get('/notifications');

    dynamic data = response;

    if (data is Map<String, dynamic>) {
      data = data['data'] ?? data;
    }

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> markAsRead(
    String id,
  ) async {
    await _api.put(
      '/notifications/$id/read',
    );
  }

  Future<void> delete(
    String id,
  ) async {
    await _api.delete(
      '/notifications/$id',
    );
  }
}
