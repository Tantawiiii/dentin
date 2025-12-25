import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/friend_requests_cubit.dart';
import '../cubit/friend_requests_state.dart';
import '../data/models/friend_request_model.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../../messages/data/models/chat_user_model.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late FriendRequestsCubit _friendRequestsCubit;
  late TabController _tabController;
  int? _currentUserId;
  final FirebaseService _firebaseService = di.sl<FirebaseService>();
  final TextEditingController _searchController = TextEditingController();

  final Map<int, String> _lastMessages = {};
  final Map<int, int> _unreadCounts = {};
  final Map<int, StreamSubscription<DatabaseEvent>?> _messageSubscriptions = {};
  String _searchTerm = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _friendRequestsCubit = di.sl<FriendRequestsCubit>();
    _tabController = TabController(length: 3, vsync: this);
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    if (_currentUserId != null) {
      _friendRequestsCubit.loadFriendRequests();
    }

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchTerm = _searchController.text;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _cancelAllSubscriptions();
    super.dispose();
  }

  void _cancelAllSubscriptions() {
    final subscriptions = Map<int, StreamSubscription<DatabaseEvent>?>.from(
      _messageSubscriptions,
    );
    _messageSubscriptions.clear();

    for (var entry in subscriptions.entries) {
      try {
        final subscription = entry.value;
        if (subscription != null) {
          subscription.cancel();
        }
      } catch (e) {
        // Ignore cancellation errors
      }
    }
  }

  void _fetchLastMessagesForFriends(List<FriendRequest> friends) {
    if (_currentUserId == null || !mounted) return;

    _cancelAllSubscriptions();
    _lastMessages.clear();
    _unreadCounts.clear();

    if (!mounted) return;

    for (final friend in friends) {
      if (!mounted) break;

      final otherUserId = friend.getOtherUserId(_currentUserId!);
      final roomId = _firebaseService.generateRoomId(
        _currentUserId!,
        otherUserId,
      );
      final messagesRef = _firebaseService.getMessagesRef(roomId);

      try {
        final subscription = messagesRef
            .orderByChild('timestamp')
            .limitToLast(50)
            .onValue
            .listen(
              (event) {
                if (!mounted) return;

                try {
                  if (event.snapshot.exists && event.snapshot.value != null) {
                    String? lastMessage;
                    int unreadCount = 0;
                    int? lastTimestamp = 0;

                    if (event.snapshot.value is Map) {
                      final messagesMap = Map<Object?, Object?>.from(
                        event.snapshot.value as Map<Object?, Object?>,
                      );

                      for (var entry in messagesMap.entries) {
                        if (entry.value == null || entry.value is! Map) {
                          continue;
                        }

                        final messageData = Map<String, dynamic>.from(
                          entry.value as Map<Object?, Object?>,
                        );

                        final timestamp = messageData['timestamp'] as int? ?? 0;
                        if (timestamp > (lastTimestamp ?? 0)) {
                          lastMessage = messageData['body']?.toString() ?? '';
                          lastTimestamp = timestamp;
                        }

                        if (messageData['sender_id'] == otherUserId &&
                            (messageData['read'] == false ||
                                messageData['read'] == null)) {
                          unreadCount++;
                        }
                      }
                    }

                    if (mounted) {
                      setState(() {
                        if (lastMessage != null) {
                          _lastMessages[otherUserId] = lastMessage;
                        }
                        if (unreadCount > 0) {
                          _unreadCounts[otherUserId] = unreadCount;
                        } else {
                          _unreadCounts.remove(otherUserId);
                        }
                      });
                    }
                  }
                } catch (e) {
                  // Ignore parsing errors
                }
              },
              onError: (_) {},
              cancelOnError: true,
            );

        if (mounted) {
          _messageSubscriptions[otherUserId] = subscription;
        } else {
          subscription.cancel();
        }
      } catch (e) {
        // Ignore setup errors
      }
    }
  }

  String _formatTime(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  void _openChat(int userId, String userName, String? profileImage) {
    final receiverUser = ChatUser(
      id: userId,
      userName: userName,
      profileImage: profileImage,
      createdAt: '',
      updatedAt: '',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(receiverUser: receiverUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _friendRequestsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppTexts.friendRequests),
          backgroundColor: AppColors.surface,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(
                child: _IncomingTabBadge(
                  friendRequestsCubit: _friendRequestsCubit,
                ),
              ),
              Tab(text: AppTexts.outgoing),
              Tab(text: AppTexts.friends),
            ],
          ),
        ),
        body: BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
          builder: (context, state) {
            if (state is FriendRequestsLoading ||
                state is FriendRequestsInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is FriendRequestsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentUserId != null) {
                          _friendRequestsCubit.loadFriendRequests();
                        }
                      },
                      child: Text(AppTexts.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is FriendRequestsLoaded ||
                state is FriendRequestActionLoading) {
              final isLoading = state is FriendRequestActionLoading;
              List<FriendRequest> incomingRequests;
              List<FriendRequest> outgoingRequests;
              List<FriendRequest> friends;

              if (state is FriendRequestsLoaded) {
                incomingRequests = state.incomingRequests;
                outgoingRequests = state.outgoingRequests;
                friends = state.friends;
              } else {
                final loadingState = state as FriendRequestActionLoading;
                incomingRequests = loadingState.incomingRequests;
                outgoingRequests = loadingState.outgoingRequests;
                friends = loadingState.friends;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _fetchLastMessagesForFriends(friends);
                }
              });

              return TabBarView(
                controller: _tabController,
                children: [
                  _IncomingRequestsTab(
                    requests: incomingRequests,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    formatTime: _formatTime,
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                  _OutgoingRequestsTab(
                    requests: outgoingRequests,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    formatTime: _formatTime,
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                  _FriendsTab(
                    friends: friends,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    searchController: _searchController,
                    searchTerm: _searchTerm,
                    lastMessages: _lastMessages,
                    unreadCounts: _unreadCounts,
                    onChatTap: _openChat,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _IncomingTabBadge extends StatelessWidget {
  final FriendRequestsCubit friendRequestsCubit;

  const _IncomingTabBadge({required this.friendRequestsCubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppTexts.incoming),
        BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
          bloc: friendRequestsCubit,
          buildWhen: (previous, current) {
            if (current is FriendRequestsLoaded) {
              return previous != current;
            }
            return false;
          },
          builder: (context, state) {
            if (state is FriendRequestsLoaded) {
              final count = state.incomingRequests.length;
              if (count > 0) {
                return Container(
                  margin: EdgeInsets.only(left: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _IncomingRequestsTab extends StatelessWidget {
  final List<FriendRequest> requests;
  final bool isLoading;
  final int? currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const _IncomingRequestsTab({
    required this.requests,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppTexts.noIncomingRequests,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      cacheExtent: 500,
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _IncomingRequestItem(
          key: ValueKey('incoming_${request.friendshipId}'),
          request: request,
          isLoading: isLoading,
          currentUserId: currentUserId!,
          formatTime: formatTime,
          friendRequestsCubit: friendRequestsCubit,
        );
      },
    );
  }
}

class _IncomingRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isLoading;
  final int currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const _IncomingRequestItem({
    super.key,
    required this.request,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = request.getOtherUserId(currentUserId);
    final otherUserName = request.getOtherUserName(currentUserId);
    final otherUserImage = request.getOtherUserImage(currentUserId);

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _UserAvatar(
              userId: otherUserId,
              userName: otherUserName,
              userImage: otherUserImage,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatTime(request.createdAt),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 28.sp,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          friendRequestsCubit.acceptFriendRequest(
                            request.friendshipId,
                            otherUserId,
                          );
                        },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 4.w),
                IconButton(
                  icon: Icon(Icons.cancel, color: AppColors.error, size: 28.sp),
                  onPressed: isLoading
                      ? null
                      : () {
                          friendRequestsCubit.rejectFriendRequest(
                            request.friendshipId,
                            otherUserId,
                          );
                        },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutgoingRequestsTab extends StatelessWidget {
  final List<FriendRequest> requests;
  final bool isLoading;
  final int? currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const _OutgoingRequestsTab({
    required this.requests,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppTexts.noOutgoingRequests,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      cacheExtent: 500,
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _OutgoingRequestItem(
          key: ValueKey('outgoing_${request.friendshipId}'),
          request: request,
          isLoading: isLoading,
          currentUserId: currentUserId!,
          formatTime: formatTime,
          friendRequestsCubit: friendRequestsCubit,
        );
      },
    );
  }
}

class _OutgoingRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isLoading;
  final int currentUserId;
  final String Function(int) formatTime;
  final FriendRequestsCubit friendRequestsCubit;

  const _OutgoingRequestItem({
    super.key,
    required this.request,
    required this.isLoading,
    required this.currentUserId,
    required this.formatTime,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = request.getOtherUserId(currentUserId);
    final otherUserName = request.getOtherUserName(currentUserId);
    final otherUserImage = request.getOtherUserImage(currentUserId);

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _UserAvatar(
              userId: otherUserId,
              userName: otherUserName,
              userImage: otherUserImage,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          AppTexts.pending,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatTime(request.createdAt),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error, size: 24.sp),
              onPressed: isLoading
                  ? null
                  : () {
                      friendRequestsCubit.cancelFriendRequest(
                        request.friendshipId,
                      );
                    },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  final List<FriendRequest> friends;
  final bool isLoading;
  final int? currentUserId;
  final TextEditingController searchController;
  final String searchTerm;
  final Map<int, String> lastMessages;
  final Map<int, int> unreadCounts;
  final void Function(int, String, String?) onChatTap;

  const _FriendsTab({
    required this.friends,
    required this.isLoading,
    required this.currentUserId,
    required this.searchController,
    required this.searchTerm,
    required this.lastMessages,
    required this.unreadCounts,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final filteredFriends = searchTerm.isEmpty
        ? friends
        : friends.where((friend) {
            final otherUserName = friend.getOtherUserName(currentUserId!);
            return otherUserName.toLowerCase().contains(
              searchTerm.toLowerCase(),
            );
          }).toList();

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.surface,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: AppTexts.searchFriends,
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
        if (filteredFriends.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${filteredFriends.length} ${AppTexts.friendsCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (filteredFriends.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchTerm.isEmpty
                        ? Icons.people_outline
                        : Icons.search_off,
                    size: 64.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    searchTerm.isEmpty
                        ? AppTexts.noFriendsYet
                        : AppTexts.noFriendsFound,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (searchTerm.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        AppTexts.tryDifferentSearchTerm,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              cacheExtent: 500,
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return _FriendItem(
                  key: ValueKey('friend_${friend.friendshipId}'),
                  friend: friend,
                  isLoading: isLoading,
                  currentUserId: currentUserId!,
                  lastMessage:
                      lastMessages[friend.getOtherUserId(currentUserId!)],
                  unreadCount:
                      unreadCounts[friend.getOtherUserId(currentUserId!)] ?? 0,
                  onChatTap: onChatTap,
                  friendRequestsCubit: di.sl<FriendRequestsCubit>(),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FriendItem extends StatelessWidget {
  final FriendRequest friend;
  final bool isLoading;
  final int currentUserId;
  final String? lastMessage;
  final int unreadCount;
  final void Function(int, String, String?) onChatTap;
  final FriendRequestsCubit friendRequestsCubit;

  const _FriendItem({
    super.key,
    required this.friend,
    required this.isLoading,
    required this.currentUserId,
    this.lastMessage,
    required this.unreadCount,
    required this.onChatTap,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = friend.getOtherUserId(currentUserId);
    final otherUserName = friend.getOtherUserName(currentUserId);
    final otherUserImage = friend.getOtherUserImage(currentUserId);

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          onTap: () => onChatTap(otherUserId, otherUserName, otherUserImage),
          child: Row(
            children: [
              _FriendAvatar(
                userId: otherUserId,
                userName: otherUserName,
                userImage: otherUserImage,
                unreadCount: unreadCount,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            otherUserName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            AppTexts.friends,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      lastMessage != null
                          ? (lastMessage!.length > 30
                                ? '${lastMessage!.substring(0, 30)}...'
                                : lastMessage!)
                          : AppTexts.noMessagesYet,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: unreadCount > 0
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.message,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    onPressed: () =>
                        onChatTap(otherUserId, otherUserName, otherUserImage),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 4.w),
                  IconButton(
                    icon: Icon(
                      Icons.person_remove,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppTexts.removeFriend),
                                content: Text(
                                  '${AppTexts.removeFriendConfirmation} $otherUserName ${AppTexts.removeFriendFromFriends}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppTexts.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      friendRequestsCubit.removeFriend(
                                        friend.friendshipId,
                                        otherUserId,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                    child: Text(AppTexts.removeFriendButton),
                                  ),
                                ],
                              ),
                            );
                          },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final int userId;
  final String userName;
  final String? userImage;

  const _UserAvatar({
    required this.userId,
    required this.userName,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.profile, arguments: userId);
      },
      child: CircleAvatar(
        radius: 32.r,
        backgroundColor: AppColors.primary,
        child: userImage != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userImage!,
                  width: 64.r,
                  height: 64.r,
                  fit: BoxFit.cover,
                  memCacheWidth: 128,
                  memCacheHeight: 128,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final int userId;
  final String userName;
  final String? userImage;
  final int unreadCount;

  const _FriendAvatar({
    required this.userId,
    required this.userName,
    this.userImage,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 32.r,
          backgroundColor: AppColors.primary,
          backgroundImage: userImage != null
              ? CachedNetworkImageProvider(userImage!)
              : null,
          child: userImage == null
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
