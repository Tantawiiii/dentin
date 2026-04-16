import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../../messages/data/models/chat_user_model.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsCubit _notificationsCubit;
  int? _currentUserId;
  bool _showAllNotifications = false;

  @override
  void initState() {
    super.initState();
    _notificationsCubit = di.sl<NotificationsCubit>();
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    if (_currentUserId != null) {
      _notificationsCubit.loadNotifications();
    }
  }

  String _formatTime(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');

      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return '';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendAccepted:
        return Icons.check_circle;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.postLike:
        return Icons.favorite;
      case NotificationType.postComment:
        return Icons.comment;
      case NotificationType.postShare:
        return Icons.share;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Colors.blue;
      case NotificationType.friendAccepted:
        return Colors.green;
      case NotificationType.newMessage:
        return Colors.purple;
      case NotificationType.postLike:
        return Colors.red;
      case NotificationType.postComment:
        return Colors.orange;
      case NotificationType.postShare:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getNotificationBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Colors.blue.shade50;
      case NotificationType.friendAccepted:
        return Colors.green.shade50;
      case NotificationType.newMessage:
        return Colors.purple.shade50;
      case NotificationType.postLike:
        return Colors.red.shade50;
      case NotificationType.postComment:
        return Colors.orange.shade50;
      case NotificationType.postShare:
        return Colors.teal.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getNotificationBorderColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Colors.blue.shade200;
      case NotificationType.friendAccepted:
        return Colors.green.shade200;
      case NotificationType.newMessage:
        return Colors.purple.shade200;
      case NotificationType.postLike:
        return Colors.red.shade200;
      case NotificationType.postComment:
        return Colors.orange.shade200;
      case NotificationType.postShare:
        return Colors.teal.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.read) {
      _notificationsCubit.markAsRead(notification.id);
    }
    switch (notification.type) {
      case NotificationType.friendRequest:
        Navigator.of(context).pushNamed(AppRoutes.friendRequests);
        break;
      case NotificationType.friendAccepted:
        Navigator.of(context).pushNamed(AppRoutes.friendRequests);
        break;
      case NotificationType.newMessage:
        final senderId =
            notification.data != null && notification.data!['sender_id'] != null
            ? notification.data!['sender_id'] as int
            : notification.senderId;

        if (senderId > 0) {
          final receiverUser = ChatUser(
            id: senderId,
            userName: notification.senderName,
            profileImage: notification.senderImage,
            createdAt: '',
            updatedAt: '',
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ChatDetailScreen(receiverUser: receiverUser),
            ),
          );
        }
        break;
      case NotificationType.postLike:
      case NotificationType.postComment:
      case NotificationType.postShare:
        if (notification.data != null &&
            notification.data!['post_id'] != null) {
          // Navigate to post details
          // Note: You may need to add a post details route
          // Navigator.of(context).pushNamed(
          //   AppRoutes.postDetails,
          //   arguments: notification.data!['post_id'],
          // );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _notificationsCubit.state is NotificationActionLoading;
    final unreadCount = _notificationsCubit.unreadCount;

    return BlocProvider.value(
      value: _notificationsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppTexts.notifications, style: TextStyle(fontSize: 18.sp),),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bounce(
                      onTap: isLoading || unreadCount == 0
                          ? null
                          : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(AppTexts.markAllAsRead),
                            content:
                            Text(AppTexts.markAllAsReadConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(AppTexts.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text(AppTexts.markAllAsRead),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          _notificationsCubit.markAllAsRead();
                        }
                      },
                      child: Icon(Icons.done_all,color: AppColors.info,size: 24.sp),
                    ),

                    SizedBox(width: 12.w),

                    Bounce(
                      onTap: isLoading
                          ? null
                          : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(AppTexts.clearAll),
                            content:
                            Text(AppTexts.clearAllConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(AppTexts.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text(AppTexts.clearAll),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          _notificationsCubit.clearAllNotifications();
                        }
                      },
                      child: Icon(Icons.delete_outline,   color: AppColors.error, size: 24.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading ||
                state is NotificationsInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is NotificationsError) {
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
                          _notificationsCubit.loadNotifications();
                        }
                      },
                      child: Text(AppTexts.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationsLoaded ||
                state is NotificationActionLoading) {
              final isLoading = state is NotificationActionLoading;
              final notifications = state is NotificationsLoaded
                  ? state.notifications
                  : (state as NotificationActionLoading).notifications;
              final unreadCount = state is NotificationsLoaded
                  ? state.unreadCount
                  : (state as NotificationActionLoading).unreadCount;

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppTexts.noNotificationsYet,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppTexts.notificationsDescription,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(18.w),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.surface,
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         AppColors.primary.withValues(alpha: 0.1),
                  //         AppColors.primary.withValues(alpha: 0.05),
                  //       ],
                  //     ),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       ElevatedButton(
                  //         onPressed: isLoading || unreadCount == 0
                  //             ? null
                  //             : () async {
                  //                 final confirmed = await showDialog<bool>(
                  //                   context: context,
                  //                   builder: (context) => AlertDialog(
                  //                     title: Text(AppTexts.markAllAsRead),
                  //                     content: Text(
                  //                       AppTexts.markAllAsReadConfirmation,
                  //                     ),
                  //                     actions: [
                  //                       TextButton(
                  //                         onPressed: () =>
                  //                             Navigator.pop(context, false),
                  //                         child: Text(AppTexts.cancel),
                  //                       ),
                  //                       TextButton(
                  //                         onPressed: () =>
                  //                             Navigator.pop(context, true),
                  //                         child: Text(
                  //                           AppTexts.markAllAsRead,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 );
                  //
                  //                 if (confirmed == true) {
                  //                   _notificationsCubit.markAllAsRead();
                  //                 }
                  //               },
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: AppColors.primary,
                  //           foregroundColor: Colors.white,
                  //           disabledBackgroundColor:
                  //               AppColors.textSecondary,
                  //         ),
                  //         child: Row(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Icon(Icons.done_all, size: 18.sp),
                  //             SizedBox(width: 4.w),
                  //             Text(AppTexts.markAllAsRead),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(width: 8.w),
                  //       OutlinedButton(
                  //         onPressed: isLoading
                  //             ? null
                  //             : () async {
                  //                 final confirmed = await showDialog<bool>(
                  //                   context: context,
                  //                   builder: (context) => AlertDialog(
                  //                     title: Text(AppTexts.clearAll),
                  //                     content: Text(
                  //                       AppTexts.clearAllConfirmation,
                  //                     ),
                  //                     actions: [
                  //                       TextButton(
                  //                         onPressed: () =>
                  //                             Navigator.pop(context, false),
                  //                         child: Text(AppTexts.cancel),
                  //                       ),
                  //                       TextButton(
                  //                         onPressed: () =>
                  //                             Navigator.pop(context, true),
                  //                         style: TextButton.styleFrom(
                  //                           foregroundColor:
                  //                               AppColors.error,
                  //                         ),
                  //                         child: Text(AppTexts.clearAll),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 );
                  //
                  //                 if (confirmed == true) {
                  //                   _notificationsCubit
                  //                       .clearAllNotifications();
                  //                 }
                  //               },
                  //         style: OutlinedButton.styleFrom(
                  //           side: BorderSide(color: AppColors.error),
                  //           foregroundColor: AppColors.error,
                  //         ),
                  //         child: Row(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Icon(Icons.delete_outline, size: 18.sp),
                  //             SizedBox(width: 4.w),
                  //             Text(AppTexts.clearAll),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            cacheExtent: 500,
                            addAutomaticKeepAlives: true,
                            addRepaintBoundaries: true,
                            itemCount: _showAllNotifications
                                ? notifications.length
                                : (notifications.length > 3
                                      ? 3
                                      : notifications.length),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];

                              return RepaintBoundary(
                                key: ValueKey(
                                  'notification_${notification.id}',
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getNotificationBackgroundColor(
                                      notification.type,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: _getNotificationBorderColor(
                                        notification.type,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        _handleNotificationTap(notification),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icon based on notification type
                                          Container(
                                            width: 32.r,
                                            height: 32.r,
                                            decoration: BoxDecoration(
                                              color: _getNotificationColor(
                                                notification.type,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              _getNotificationIcon(
                                                notification.type,
                                              ),
                                              color: _getNotificationColor(
                                                notification.type,
                                              ),
                                              size: 16.sp,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        notification.title,
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              !notification.read
                                                              ? AppColors
                                                                    .textPrimary
                                                              : AppColors
                                                                    .textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                    if (!notification.read)
                                                      Container(
                                                        width: 8.w,
                                                        height: 8.h,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors
                                                                  .purple
                                                                  .shade500,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  notification.message,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  _formatTime(
                                                    notification.timestamp,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: AppColors
                                                        .textSecondary
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Delete button (like React)
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: AppColors.textSecondary,
                                              size: 16.sp,
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    _notificationsCubit
                                                        .deleteNotification(
                                                          notification.id,
                                                        );
                                                  },
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Show more button (like React)
                        if (!_showAllNotifications && notifications.length > 3)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllNotifications = true;
                                });
                              },
                              child: Text(
                                'Show ${notifications.length - 3} more',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.purple.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
