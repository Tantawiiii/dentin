import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_constants.dart';
import '../data/models/friend_request_model.dart';
import 'friend_requests_state.dart';

class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  final FirebaseService _firebaseService;
  final StorageService _storageService;
  final ApiService _apiService;

  StreamSubscription<DatabaseEvent>? _friendshipsSubscription;
  int? _currentUserId;

  List<FriendRequest> _incomingRequests = [];
  List<FriendRequest> _outgoingRequests = [];
  List<FriendRequest> _friends = [];
  Map<int, FriendRequestStatus> _friendStatusMap = {};

  FriendRequestsCubit(
    this._firebaseService,
    this._storageService,
    this._apiService,
  ) : super(FriendRequestsInitial());

  List<FriendRequest> get incomingRequests => _incomingRequests;
  List<FriendRequest> get outgoingRequests => _outgoingRequests;
  List<FriendRequest> get friends => _friends;
  Map<int, FriendRequestStatus> get friendStatusMap => _friendStatusMap;

  Future<void> loadFriendRequests() async {
    _currentUserId = _storageService.getUserData()?.id;
    if (_currentUserId == null) {
      emit(FriendRequestsError('User not authenticated'));
      return;
    }

    emit(FriendRequestsLoading());

    try {
      await _setupRealtimeListener();
    } catch (e) {
      emit(FriendRequestsError(e.toString()));
    }
  }

  Future<void> _setupRealtimeListener() async {
    if (_currentUserId == null) return;

    final friendshipsRef = _firebaseService.getFriendshipsRef();

    _friendshipsSubscription = friendshipsRef.onValue.listen((event) {
      if (!event.snapshot.exists) {
        _incomingRequests = [];
        _outgoingRequests = [];
        _friends = [];
        _friendStatusMap = {};
        emit(
          FriendRequestsLoaded(
            incomingRequests: _incomingRequests,
            outgoingRequests: _outgoingRequests,
            friends: _friends,
            friendStatusMap: _friendStatusMap,
          ),
        );
        return;
      }

      _incomingRequests = [];
      _outgoingRequests = [];
      _friends = [];
      _friendStatusMap = {};

      for (var child in event.snapshot.children) {
        final friendshipId = child.key ?? '';
        final friendshipData = Map<String, dynamic>.from(
          child.value as Map<Object?, Object?>,
        );

        final friendRequest = FriendRequest.fromFirebase(
          friendshipId,
          friendshipData,
          _currentUserId!,
        );

        final otherUserId = friendRequest.getOtherUserId(_currentUserId!);
        _friendStatusMap[otherUserId] = friendRequest.status;

        if (friendRequest.status == FriendRequestStatus.pending) {
          if (friendRequest.isPendingForMe(_currentUserId!)) {
            _incomingRequests.add(friendRequest);
          } else if (friendRequest.isSentByMe(_currentUserId!)) {
            _outgoingRequests.add(friendRequest);
          }
        } else if (friendRequest.status == FriendRequestStatus.friends) {
          _friends.add(friendRequest);
        }
      }

      _incomingRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _outgoingRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _friends.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(
        FriendRequestsLoaded(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    });
  }

  Future<void> sendFriendRequest(int userId) async {
    if (_currentUserId == null) return;

    final userData = _storageService.getUserData();
    if (userData == null) return;

    final currentState = state;
    if (currentState is FriendRequestsLoaded) {
      emit(
        FriendRequestActionLoading(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    }

    try {
      final userResponse = await _apiService.get<dynamic>(
        ApiConstants.updateUser(userId),
      );

      if (userResponse.statusCode != null && userResponse.statusCode! < 400) {
        final userJson = userResponse.data as Map<String, dynamic>;
        final otherUserData = userJson['data'] as Map<String, dynamic>;

        await _firebaseService.sendFriendRequest(
          userId1: _currentUserId!,
          userName1: userData.userName,
          userImage1: userData.profileImage,
          userId2: userId,
          userName2: otherUserData['user_name'] ?? '',
          userImage2: otherUserData['profile_image'],
        );

        try {
          await _apiService.post<dynamic>('/api/friend-requests/$userId');
        } catch (e) {
          print('Backend API error (ignored): $e');
        }
      }
    } catch (e) {
      emit(FriendRequestsError('Failed to send friend request: $e'));
    }
  }

  Future<void> acceptFriendRequest(String friendshipId, int userId) async {
    final currentState = state;
    if (currentState is FriendRequestsLoaded) {
      emit(
        FriendRequestActionLoading(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    }

    try {
      await _firebaseService.acceptFriendRequest(friendshipId);

      try {
        await _apiService.put<dynamic>('/api/friend-requests/$userId/accept');
      } catch (e) {
        print('Backend API error (ignored): $e');
      }
    } catch (e) {
      emit(FriendRequestsError('Failed to accept friend request: $e'));
    }
  }

  Future<void> rejectFriendRequest(String friendshipId, int userId) async {
    final currentState = state;
    if (currentState is FriendRequestsLoaded) {
      emit(
        FriendRequestActionLoading(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    }

    try {
      await _firebaseService.rejectFriendRequest(friendshipId);

      try {
        await _apiService.put<dynamic>('/api/friend-requests/$userId/reject');
      } catch (e) {
        print('Backend API error (ignored): $e');
      }
    } catch (e) {
      emit(FriendRequestsError('Failed to reject friend request: $e'));
    }
  }

  Future<void> cancelFriendRequest(String friendshipId) async {
    final currentState = state;
    if (currentState is FriendRequestsLoaded) {
      emit(
        FriendRequestActionLoading(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    }

    try {
      await _firebaseService.cancelFriendRequest(friendshipId);
    } catch (e) {
      emit(FriendRequestsError('Failed to cancel friend request: $e'));
    }
  }

  Future<void> removeFriend(String friendshipId, int userId) async {
    final currentState = state;
    if (currentState is FriendRequestsLoaded) {
      emit(
        FriendRequestActionLoading(
          incomingRequests: _incomingRequests,
          outgoingRequests: _outgoingRequests,
          friends: _friends,
          friendStatusMap: _friendStatusMap,
        ),
      );
    }

    try {
      await _firebaseService.removeFriend(friendshipId);

      // إرسال للـ backend API للتوثيق
      try {
        await _apiService.delete<dynamic>('/api/friends/$userId');
      } catch (e) {
        print('Backend API error (ignored): $e');
      }
    } catch (e) {
      emit(FriendRequestsError('Failed to remove friend: $e'));
    }
  }

  @override
  Future<void> close() {
    _friendshipsSubscription?.cancel();
    return super.close();
  }
}
