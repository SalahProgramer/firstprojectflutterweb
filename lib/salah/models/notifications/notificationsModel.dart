class NotificationsModel {
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? name;
  final String? url;
  final String? destination;
  final String? navigate;

  NotificationsModel({
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.name,
    this.url,
    this.destination,
    this.navigate,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      title: json['title'] ?? 'إشعار جديد',
      body: json['body'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      name: json['name'],
      url: json['url'],
      destination: json['destination'],
      navigate: json['navigate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'name': name,
      'url': url,
      'destination': destination,
      'navigate': navigate,
    };
  }
}
