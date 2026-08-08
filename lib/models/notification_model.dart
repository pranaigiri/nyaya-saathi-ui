class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final int? applicationId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.applicationId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      applicationId: json['application_id'],
    );
  }
}

