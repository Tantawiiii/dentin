import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/register/data/specialties.dart';
import 'data/models/job_models.dart';
import 'data/repo/job_repository.dart';
import 'job_details_screen.dart';
import 'post_job_screen.dart';
import 'widgets/job_item_widget.dart';
import 'widgets/job_item_shimmer.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late final JobRepository _jobRepository;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<Job> _allJobs = [];
  List<Job> _jobs = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _selectedJobType = AppTexts.jobsAllJobs;
  String? _selectedSpecialization;
  Timer? _searchDebounceTimer;
  String _previousSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _jobRepository = di.sl<JobRepository>();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _previousSearchQuery = _searchController.text.trim();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _allJobs = [];
        _jobs = [];
        _errorMessage = null;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
    }

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
        _isLoadingMore = false;
      } else {
        _isLoading = false;
        _isLoadingMore = true;
      }
    });

    try {
      final pageToLoad = refresh ? 1 : _currentPage;

      final response = await _jobRepository.getJobs(
        page: pageToLoad,
        specialization: _selectedSpecialization,
      );

      if (mounted) {
        setState(() {
          if (pageToLoad == 1) {
            _allJobs = response.data;
            _currentPage = 2;
          } else {
            _allJobs.addAll(response.data);
            _currentPage++;
          }
          _hasMore = response.meta?.hasMorePages ?? false;

          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.trim().toLowerCase();
    final locationQuery = _locationController.text.trim().toLowerCase();
    final jobType = _selectedJobType == AppTexts.jobsAllJobs
        ? null
        : _selectedJobType;

    List<Job> filtered = List.from(_allJobs);

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        final title = job.title.toLowerCase();
        final description = job.description.toLowerCase();
        final location = job.location.toLowerCase();
        final companyName = job.company.name?.toLowerCase() ?? '';
        return title.contains(searchQuery) ||
            description.contains(searchQuery) ||
            location.contains(searchQuery) ||
            companyName.contains(searchQuery);
      }).toList();
    }

    // Apply location filter
    if (locationQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.location.toLowerCase().contains(locationQuery);
      }).toList();
    }

    // Apply type filter
    if (jobType != null) {
      filtered = filtered.where((job) {
        return job.type.toLowerCase() == jobType.toLowerCase();
      }).toList();
    }

    setState(() {
      _jobs = filtered;
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0;

    if (currentScroll >= (maxScroll - delta)) {
      _loadJobs();
    }
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text.trim();
    if (currentQuery == _previousSearchQuery) return;
    _previousSearchQuery = currentQuery;
    _searchDebounceTimer?.cancel();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (_searchController.text.trim() == currentQuery) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }

          _applyFilters();
        }
      }
    });
  }

  void _openJobDetails(Job job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: job.id, initialJob: job),
      ),
    );
  }

  void _showPostJobScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const PostJobScreen()))
        .then((result) {
          if (result == true) {
            _loadJobs(refresh: true);
          }
        });
  }

  void _handleJobTypeFilter(String type) {
    setState(() {
      _selectedJobType = type;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _applyFilters();
  }

  void _handleSpecializationFilter(String? specialization) {
    setState(() {
      _selectedSpecialization = specialization;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _loadJobs(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppTexts.jobsTitle),
            Text(
              AppTexts.jobsFindYourNextCareer,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ElevatedButton.icon(
              onPressed: _showPostJobScreen,
              icon: Icon(Icons.add, size: 18.sp),
              label: Text(
                AppTexts.jobsPostJob,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadJobs(refresh: true),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          AppTextField(
            controller: _searchController,
            hint: AppTexts.jobsSearchPlaceholder,
            leadingIcon: Icons.search,
          ),
          SizedBox(height: 16.h),

          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(AppTexts.jobsAllJobs),
                SizedBox(width: 4.w),
                _buildFilterChip(AppTexts.jobsFullTime),
                SizedBox(width: 4.w),
                _buildFilterChip(AppTexts.jobsPartTime),
                SizedBox(width: 4.w),
                _buildFilterChip(AppTexts.jobsRemote),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSpecializationChip(AppTexts.jobsAllSpecializations),
                SizedBox(width: 4.w),
                ...Specialties.specialties.map((specialty) {
                  return Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: _buildSpecializationChip(specialty),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedJobType == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _handleJobTypeFilter(label);
        }
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    );
  }

  Widget _buildSpecializationChip(String label) {
    final isSelected =
        _selectedSpecialization == label ||
        (label == AppTexts.jobsAllSpecializations &&
            _selectedSpecialization == null);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _handleSpecializationFilter(
            label == AppTexts.jobsAllSpecializations ? null : label,
          );
        }
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jobs.isEmpty) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        cacheExtent: 500,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        itemCount: 6,
        itemBuilder: (context, index) {
          return const JobItemShimmer();
        },
      );
    }

    if (_errorMessage != null && _jobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  PrimaryButton(
                    title: AppTexts.jobsErrorRetry,
                    onPressed: () => _loadJobs(refresh: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_jobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.jobsListEmptyTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppTexts.jobsListEmptySubtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      cacheExtent: 500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: _jobs.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _jobs.length) {
          return const JobItemShimmer();
        }

        final job = _jobs[index];
        return JobItemWidget(job: job, onTap: () => _openJobDetails(job));
      },
    );
  }
}
