class Notification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final int? orderId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.orderId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      orderId: json['order_id'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'order_id': orderId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PaginatedNotifications {
  final List<Notification> notifications;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  PaginatedNotifications({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    var notificationList = (json['data'] as List)
        .map((notificationJson) => Notification.fromJson(notificationJson))
        .toList();

    return PaginatedNotifications(
      notifications: notificationList,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}