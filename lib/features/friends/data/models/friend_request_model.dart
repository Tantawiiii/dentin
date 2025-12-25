enum FriendRequestStatus { none, pending, accepted, friends, rejected }

class FriendRequest {
  final String friendshipId;
  final int user1Id;
  final String user1Name;
  final String? user1Image;
  final int user2Id;
  final String user2Name;
  final String? user2Image;
  final FriendRequestStatus status;
  final int requestedBy;
  final int createdAt;
  final int updatedAt;
  final int? acceptedAt;
  final int? rejectedAt;

  FriendRequest({
    required this.friendshipId,
    required this.user1Id,
    required this.user1Name,
    this.user1Image,
    required this.user2Id,
    required this.user2Name,
    this.user2Image,
    required this.status,
    required this.requestedBy,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.rejectedAt,
  });

  factory FriendRequest.fromFirebase(
    String friendshipId,
    Map<String, dynamic> data,
    int currentUserId,
  ) {
    FriendRequestStatus status;
    final statusString = data['status']?.toString().toLowerCase() ?? 'none';
    switch (statusString) {
      case 'pending':
        status = FriendRequestStatus.pending;
        break;
      case 'accepted':
      case 'friends':
        status = FriendRequestStatus.friends;
        break;
      case 'rejected':
        status = FriendRequestStatus.rejected;
        break;
      default:
        status = FriendRequestStatus.none;
    }

    // تحديد من هو المستخدم الآخر
    final user1Id = data['user1_id'] is int
        ? data['user1_id']
        : int.tryParse(data['user1_id']?.toString() ?? '0') ?? 0;
    final user2Id = data['user2_id'] is int
        ? data['user2_id']
        : int.tryParse(data['user2_id']?.toString() ?? '0') ?? 0;

    return FriendRequest(
      friendshipId: friendshipId,
      user1Id: user1Id,
      user1Name: data['user1_name'] ?? '',
      user1Image: data['user1_image'],
      user2Id: user2Id,
      user2Name: data['user2_name'] ?? '',
      user2Image: data['user2_image'],
      status: status,
      requestedBy: data['requested_by'] is int
          ? data['requested_by']
          : int.tryParse(data['requested_by']?.toString() ?? '0') ?? 0,
      createdAt: data['created_at'] is int
          ? data['created_at']
          : int.tryParse(data['created_at']?.toString() ?? '0') ?? 0,
      updatedAt: data['updated_at'] is int
          ? data['updated_at']
          : int.tryParse(data['updated_at']?.toString() ?? '0') ?? 0,
      acceptedAt: data['accepted_at'] is int
          ? data['accepted_at'] as int
          : data['accepted_at'] != null
              ? int.tryParse(data['accepted_at'].toString())
              : null,
      rejectedAt: data['rejected_at'] is int
          ? data['rejected_at'] as int
          : data['rejected_at'] != null
              ? int.tryParse(data['rejected_at'].toString())
              : null,
    );
  }

  // الحصول على بيانات المستخدم الآخر
  int getOtherUserId(int currentUserId) {
    return user1Id == currentUserId ? user2Id : user1Id;
  }

  String getOtherUserName(int currentUserId) {
    return user1Id == currentUserId ? user2Name : user1Name;
  }

  String? getOtherUserImage(int currentUserId) {
    return user1Id == currentUserId ? user2Image : user1Image;
  }

  bool isPendingForMe(int currentUserId) {
    return status == FriendRequestStatus.pending &&
        requestedBy != currentUserId;
  }

  bool isSentByMe(int currentUserId) {
    return requestedBy == currentUserId;
  }
}

