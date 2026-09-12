import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/api_service.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ApiService(),
  );
});

final notificationsProvider =
    FutureProvider<List<NotificationModel>>(
  (ref) {
    return ref
        .read(notificationRepositoryProvider)
        .getNotifications();
  },
);
