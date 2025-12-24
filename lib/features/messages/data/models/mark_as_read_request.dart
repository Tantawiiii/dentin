class MarkAsReadRequest {
  final int receiverId;

  MarkAsReadRequest({required this.receiverId});

  Map<String, dynamic> toJson() {
    return {'receiver_id': receiverId};
  }
}
