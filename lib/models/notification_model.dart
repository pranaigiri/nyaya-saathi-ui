class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;
  final String? applicationId;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    this.type = 'application_status_update',
    required this.isRead,
    required this.createdAt,
    this.applicationId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'application_status_update',
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      applicationId: json['application_id']?.toString(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    String? createdAt,
    String? applicationId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      applicationId: applicationId ?? this.applicationId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'body': body,
    'type': type,
    'is_read': isRead,
    'created_at': createdAt,
    'application_id': applicationId,
  };
}
