import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../friends/cubit/friend_requests_cubit.dart';
import '../../friends/cubit/friend_requests_state.dart';
import '../../friends/data/models/friend_request_model.dart';
import '../../messages/data/models/chat_user_model.dart';
import '../../profile/data/models/profile_response.dart';
import '../cubit/users_list_cubit.dart';
import '../cubit/users_list_state.dart';
import '../data/models/users_list_response.dart';
import '../data/repo/users_repository.dart';
import 'widgets/advanced_filters_widget.dart';
import 'widgets/search_and_filters_widget.dart';
import 'widgets/user_card.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late UsersListCubit _usersListCubit;
  late FriendRequestsCubit _friendRequestsCubit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  UsersListFilters _filters = UsersListFilters();
  UsersListFilters _tempFilters = UsersListFilters();
  bool _showFilters = false;
  int _perPage = 10;
  int? _currentUserId;
  Map<int, FriendRequestStatus> _friendStatusMap = {};

  final Map<String, TextEditingController> _filterControllers = {};

  @override
  void initState() {
    super.initState();
    _usersListCubit = UsersListCubit(di.sl<UsersRepository>());
    _friendRequestsCubit = di.sl<FriendRequestsCubit>();

    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    _loadUsers();
    _loadFriendStatuses();

    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final searchText = _searchController.text;
        setState(() {
          _tempFilters = _tempFilters.copyWith(userName: searchText);
          _filters = _tempFilters;
        });
        _loadUsers();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      final state = _usersListCubit.state;
      if (state is UsersListLoaded) {
        if (state.currentPage < state.totalPages && !state.isLoadingMore) {
          _usersListCubit.loadNextPage(filters: _filters, perPage: _perPage);
        }
      }
    }
  }

  void _loadUsers() {
    _usersListCubit.loadUsers(filters: _filters, page: 1, perPage: _perPage);
  }

  void _loadFriendStatuses() {
    if (_currentUserId != null) {
      _friendRequestsCubit.loadFriendRequests();
    }
  }

  void _applyFilters() {
    setState(() {
      _filters = _tempFilters;
      _showFilters = false;
    });
    _loadUsers();
  }

  void _clearFilters() {
    setState(() {
      _tempFilters = UsersListFilters();
      _filters = UsersListFilters();
      _searchController.clear();
      _showFilters = false;
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    for (var controller in _filterControllers.values) {
      controller.dispose();
    }
    _filterControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _usersListCubit),
        BlocProvider.value(value: _friendRequestsCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppTexts.medicalProfessionals),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Column(
          children: [
            SearchAndFiltersWidget(
              searchController: _searchController,
              showFilters: _showFilters,
              perPage: _perPage,
              onFilterToggle: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              onPerPageChanged: (value) {
                setState(() {
                  _perPage = value;
                });
                _loadUsers();
              },
              advancedFilters: AdvancedFiltersWidget(
                tempFilters: _tempFilters,
                filterControllers: _filterControllers,
                onFiltersChanged: (filters) {
                  setState(() {
                    _tempFilters = filters;
                  });
                },
                onApplyFilters: _applyFilters,
                onClearFilters: _clearFilters,
              ),
            ),
            Expanded(
              child: BlocBuilder<FriendRequestsCubit, dynamic>(
                bloc: _friendRequestsCubit,
                buildWhen: (previous, current) =>
                    current is FriendRequestsLoaded,
                builder: (context, friendState) {
                  if (friendState is FriendRequestsLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _friendStatusMap = friendState.friendStatusMap;
                        });
                      }
                    });
                  }
                  return BlocBuilder<UsersListCubit, UsersListState>(
                    bloc: _usersListCubit,
                    buildWhen: (previous, current) {
                      if (previous.runtimeType != current.runtimeType) {
                        return true;
                      }
                      if (previous is UsersListLoaded &&
                          current is UsersListLoaded) {
                        // Only rebuild if users list changed, loading state changed, or page changed
                        return previous.users.length != current.users.length ||
                            previous.isLoadingMore != current.isLoadingMore ||
                            previous.currentPage != current.currentPage ||
                            previous.totalUsers != current.totalUsers;
                      }
                      return false;
                    },
                    builder: (context, state) {
                      if (state is UsersListLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (state is UsersListError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: _loadUsers,
                                child: const Text(AppTexts.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is UsersListLoaded) {
                        if (state.users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  AppTexts.noUsersFound,
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
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppTexts.showingUsers} ${state.users.length} ${AppTexts.ofUsers} ${state.totalUsers} ${AppTexts.users}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (_hasActiveFilters())
                                    TextButton(
                                      onPressed: _clearFilters,
                                      child: Text(
                                        AppTexts.clearFilters,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                  top: 0,
                                  bottom: 16.h,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                cacheExtent: 1000,
                                shrinkWrap: false,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: true,
                                itemCount:
                                    state.users.length +
                                    (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.users.length) {
                                    return RepaintBoundary(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            height: 24.h,
                                            width: 24.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary
                                                        .withOpacity(0.6),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final user = state.users[index];
                                  final friendStatus =
                                      _friendStatusMap[user.id] ??
                                      FriendRequestStatus.none;
                                  return RepaintBoundary(
                                    key: ValueKey('user_${user.id}'),
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: UserCard(
                                        user: user,
                                        friendStatus: friendStatus,
                                        onProfileTap: () {
                                          Navigator.of(context).pushNamed(
                                            AppRoutes.userProfile,
                                            arguments: user.id,
                                          );
                                        },
                                        onMessageTap: () {
                                          _navigateToChat(user, friendStatus);
                                        },
                                        onFriendTap: () {
                                          _handleFriendAction(user.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filters.userName != null ||
        _filters.email != null ||
        _filters.phone != null ||
        _filters.graduationYear != null ||
        _filters.graduationGrade != null ||
        _filters.postgraduateDegree != null ||
        _filters.experienceYears != null;
  }

  void _handleFriendAction(int userId) {
    final status = _friendStatusMap[userId] ?? FriendRequestStatus.none;

    if (status == FriendRequestStatus.none) {
      _friendRequestsCubit.sendFriendRequest(userId);
    } else if (status == FriendRequestStatus.pending) {
      final friendshipId = _getFriendshipId(userId);
      if (friendshipId != null) {
        _friendRequestsCubit.cancelFriendRequest(friendshipId);
      }
    } else if (status == FriendRequestStatus.friends) {
      final friendshipId = _getFriendshipId(userId);
      if (friendshipId != null) {
        _friendRequestsCubit.removeFriend(friendshipId, userId);
      }
    }
  }

  String? _getFriendshipId(int userId) {
    if (_currentUserId == null) return null;
    final sortedIds = [_currentUserId!, userId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _navigateToChat(Doctor user, FriendRequestStatus friendStatus) {
    // Check if user is a friend before allowing chat
    if (friendStatus != FriendRequestStatus.friends) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need to be friends with ${user.firstName} ${user.lastName} to start chatting',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Convert Doctor to ChatUser
    final now = DateTime.now().toIso8601String();
    final chatUser = ChatUser(
      id: user.id,
      userName: user.userName,
      profileImage: user.profileImage,
      createdAt: user.createdAt ?? now,
      updatedAt: user.createdAt ?? now,
    );


    Navigator.of(context).pushNamed(AppRoutes.chat, arguments: chatUser);
  }
}
