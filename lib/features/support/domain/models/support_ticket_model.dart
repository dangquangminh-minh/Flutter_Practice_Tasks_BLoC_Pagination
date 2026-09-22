class SupportTicket {
  final int id;
  final String title;
  final String body;
  final int userId;

  SupportTicket({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }
}