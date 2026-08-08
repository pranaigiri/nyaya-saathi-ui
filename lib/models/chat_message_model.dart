class ChatMessageModel {
  final int id;
  final int? applicationId;
  final String senderId;
  final String recipientId;
  final String message;
  final bool isFromAuthority;
  final String sentAt;

  ChatMessageModel({
    required this.id,
    this.applicationId,
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.isFromAuthority,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      applicationId: json['application_id'],
      senderId: json['sender_id'] ?? 'bot',
      recipientId: json['recipient_id'] ?? 'user',
      message: json['message'] ?? '',
      isFromAuthority: json['is_from_authority'] ?? false,
      sentAt: json['sent_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
