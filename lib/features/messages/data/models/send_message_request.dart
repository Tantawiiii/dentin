class SendMessageRequest {
  final String body;
  final int receiverId;

  SendMessageRequest({required this.body, required this.receiverId});

  Map<String, dynamic> toJson() {
    return {'body': body, 'receiver_id': receiverId};
  }
}
