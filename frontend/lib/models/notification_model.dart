class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ??
          json['message']?.toString() ??
          '',
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ),
    );
  }
}
