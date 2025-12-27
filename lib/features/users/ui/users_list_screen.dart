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
  bool _isLoadingMore = false;

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
    if (!_isLoadingMore &&
        _scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      final state = _usersListCubit.state;
      if (state is UsersListLoaded) {
        if (state.currentPage < state.totalPages) {
          setState(() => _isLoadingMore = true);
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
    _filterControllers.values.forEach((controller) => controller.dispose());
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
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      if (state is UsersListLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _isLoadingMore = false);
                          }
                        });
                      }
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
                              padding: EdgeInsets.all(16.w),
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
                              child: GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                physics: const BouncingScrollPhysics(),
                                cacheExtent: 500,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _getCrossAxisCount(
                                        context,
                                      ),
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 12.h,
                                      childAspectRatio: 0.7,
                                    ),
                                itemCount: state.users.length,
                                itemBuilder: (context, index) {
                                  final user = state.users[index];
                                  return RepaintBoundary(
                                    key: ValueKey('user_${user.id}'),
                                    child: UserCard(
                                      user: user,
                                      friendStatus:
                                          _friendStatusMap[user.id] ??
                                          FriendRequestStatus.none,
                                      onProfileTap: () {
                                        Navigator.of(context).pushNamed(
                                          AppRoutes.userProfile,
                                          arguments: user.id,
                                        );
                                      },
                                      onMessageTap: () {
                                        // Navigate to chat
                                      },
                                      onFriendTap: () {
                                        _handleFriendAction(user.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (state.currentPage < state.totalPages)
                              Padding(
                                padding: EdgeInsets.all(16.h),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
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

  int _getCrossAxisCount(BuildContext context) {
    if (!mounted) return 2;
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
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
}
