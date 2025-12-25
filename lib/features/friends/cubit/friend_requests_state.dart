import '../data/models/friend_request_model.dart';

abstract class FriendRequestsState {}

class FriendRequestsInitial extends FriendRequestsState {}

class FriendRequestsLoading extends FriendRequestsState {}

class FriendRequestsLoaded extends FriendRequestsState {
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> outgoingRequests;
  final List<FriendRequest> friends;
  final Map<int, FriendRequestStatus> friendStatusMap;

  FriendRequestsLoaded({
    required this.incomingRequests,
    required this.outgoingRequests,
    required this.friends,
    required this.friendStatusMap,
  });
}

class FriendRequestsError extends FriendRequestsState {
  final String message;

  FriendRequestsError(this.message);
}

class FriendRequestActionLoading extends FriendRequestsState {
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> outgoingRequests;
  final List<FriendRequest> friends;
  final Map<int, FriendRequestStatus> friendStatusMap;

  FriendRequestActionLoading({
    required this.incomingRequests,
    required this.outgoingRequests,
    required this.friends,
    required this.friendStatusMap,
  });
}


