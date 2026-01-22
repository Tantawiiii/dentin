import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import 'home_screen.dart';
import '../explore_stories/explore_stories_screen.dart';
import '../messages/messages_screen.dart';
import '../store/store_screen.dart';
import '../jobs/jobs_screen.dart';
import '../rent_clinic/ui/rent_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  VoidCallback? _homeRefreshCallback;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onRefreshReady: (callback) {
          _homeRefreshCallback = callback;
        },
      ),
      const JobsScreen(),
      const ExploreStoriesScreen(),
      const StoreScreen(),
      const RentListScreen(),
      const MessagesScreen(),
    ];
  }

  void _handleBottomNavTap(int index) {
    if (index == 0 && _currentIndex == 0) {
      _homeRefreshCallback?.call();
    } else {
      // غير التبويب العادي
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _handleBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
          iconSize: 24.sp,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: AppTexts.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.work_outline),
              activeIcon: const Icon(Icons.work),
              label: AppTexts.jobs,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: const Icon(Icons.explore),
              label: AppTexts.exploreStories,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
              label: AppTexts.store,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business_outlined),
              activeIcon: const Icon(Icons.business),
              label: AppTexts.rentClinic,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: AppTexts.messages,
            ),
          ],
        ),
      ),
    );
  }
}
