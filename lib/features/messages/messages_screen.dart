import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import '../../core/services/storage_service.dart';
import '../friends/cubit/friend_requests_cubit.dart';
import 'cubit/chat_cubit.dart';
import 'cubit/chat_state.dart';
import 'data/models/conversation_model.dart';
import 'ui/chat_detail_screen.dart';
import 'widgets/conversation_item_widget.dart';
import 'widgets/conversation_list_shimmer.dart';
import 'widgets/conversation_search_field.dart';
import 'widgets/new_message_friends_sheet.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late ChatCubit _chatCubit;
  late FriendRequestsCubit _friendRequestsCubit;
  int? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatCubit = di.sl<ChatCubit>();
    _friendRequestsCubit = di.sl<FriendRequestsCubit>();
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    if (_currentUserId != null) {
      _chatCubit.loadConversations(_currentUserId!);
      _friendRequestsCubit.loadFriendRequests();
    }

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatCubit),
        BlocProvider.value(value: _friendRequestsCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _showFriendsForNewMessage,
              icon: Icon(Icons.add_comment_rounded, color: AppColors.primary, size: 30.r,),
              tooltip: 'New message',
            ),
          ],
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ConversationsLoading || state is ChatInitial) {
              return const ConversationListShimmer();
            }

            if (state is ConversationsError) {
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
                          _chatCubit.loadConversations(_currentUserId!);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            List<Conversation> conversations = [];
            if (state is ConversationsLoaded) {
              conversations = state.conversations;
            } else if (state is MessagesLoaded) {
              conversations = state.conversations;
            } else if (state is MessageSent) {
              conversations = state.conversations;
            } else if (state is MessageSending) {
              conversations = state.conversations;
            } else if (state is MessageSendError) {
              conversations = state.conversations;
            }

            final filteredConversations = conversations.where((conversation) {
              if (_searchQuery.isEmpty) return true;
              final user = conversation.user;
              return user.userName.toLowerCase().contains(_searchQuery);
            }).toList();

            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                ConversationSearchField(
                  controller: _searchController,
                  searchQuery: _searchQuery,
                  onClear: () => _searchController.clear(),
                ),
                Expanded(
                  child: filteredConversations.isEmpty
                      ? Center(
                          child: Text(
                            'No conversations match your search',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (_currentUserId != null) {
                              await _chatCubit.refreshConversations(
                                _currentUserId!,
                              );
                            }
                          },
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          strokeWidth: 2.5,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            cacheExtent: 1000,
                            itemCount: filteredConversations.length,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            addAutomaticKeepAlives: true,
                            addRepaintBoundaries: true,
                            itemBuilder: (context, index) {
                              final conversation = filteredConversations[index];
                              return ConversationItemWidget(
                                key: ValueKey(
                                  'conversation_${conversation.user.id}',
                                ),
                                conversation: conversation,
                                currentUserId: _currentUserId,
                                formatTime: _formatTime,
                                chatCubit: _chatCubit,
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFriendsForNewMessage() {
    if (_currentUserId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider.value(
        value: _friendRequestsCubit,
        child: NewMessageFriendsSheet(
          currentUserId: _currentUserId!,
          onFriendSelected: (chatUser) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(receiverUser: chatUser),
              ),
            );
          },
        ),
      ),
    );
  }
}
