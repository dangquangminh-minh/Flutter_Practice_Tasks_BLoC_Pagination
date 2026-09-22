class TicketLocalModel {
  final int id;
  final int postId;
  final int customerId;
  final String status;
  final DateTime updatedAt;

  TicketLocalModel({
    required this.id,
    required this.postId,
    required this.customerId,
    required this.status,
    required this.updatedAt,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'customerId': customerId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TicketLocalModel.fromJson(Map<String, dynamic> json) {
    return TicketLocalModel(
      id: json['id'],
      postId: json['postId'],
      customerId: json['customerId'],
      status: json['status'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}