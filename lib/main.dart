import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'core/config/firebase_config.dart';
import 'core/di/inject.dart' as di;
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'shared/widgets/app_toast.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('❌ Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      try {
        if (kDebugMode) {
          print('🌐 Initializing Connectivity Service...');
        }
        await ConnectivityService().initialize();
        if (kDebugMode) {
          print('✅ Connectivity Service initialized');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ Connectivity Service initialization failed: $e');
          print('Stack trace: $stackTrace');
        }
      }

      try {
        if (kDebugMode) {
          print('🔥 Initializing Firebase with explicit config...');
        }

        try {
          if (Firebase.apps.isEmpty) {
            final options = FirebaseConfig.currentPlatform;
            if (kDebugMode) {
              if (options != null) {
                print('📦 Calling Firebase.initializeApp with explicit options...');
                print('📦 Project ID: ${options.projectId}');
              } else {
                print('📦 Calling Firebase.initializeApp (auto-detect from config files)...');
              }
            }
            
            await (options != null
                ? Firebase.initializeApp(options: options)
                : Firebase.initializeApp()).timeout(
              const Duration(seconds: 30),
            );
            
            if (kDebugMode) {
              final app = Firebase.app();
              print('✅ Firebase initialized successfully');
              print('📊 Project ID: ${app.options.projectId}');
              if (app.options.authDomain != null) {
                print('📊 Auth Domain: ${app.options.authDomain}');
              }
              if (app.options.databaseURL != null) {
                print('📊 Database URL: ${app.options.databaseURL}');
              }
            }
          } else {
            if (kDebugMode) {
              print('✅ Firebase already initialized');
              print('📊 Using existing Firebase instance');
            }
          }
        } catch (e, stackTrace) {
          if (e.toString().contains('duplicate-app')) {
            if (kDebugMode) {
              print('✅ Firebase already initialized (duplicate-app caught)');
            }
          } else {
            if (kDebugMode) {
              print('❌ Firebase.initializeApp failed: $e');
              print('Stack trace: $stackTrace');
            }
            // Don't rethrow - let the app continue even if Firebase fails
            if (kDebugMode) {
              print('⚠️ Continuing app initialization despite Firebase error');
            }
          }
        }

        try {
          if (kDebugMode) {
            print('📊 Initializing FirebaseService...');
          }
          await FirebaseService.initialize();
          if (kDebugMode) {
            print('✅ FirebaseService initialized');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('⚠️ FirebaseService initialization failed: $e');
            print('Stack trace: $stackTrace');
          }
        }

        try {
          if (kDebugMode) {
            print('📱 Initializing FCM background handler...');
          }
          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );
          if (kDebugMode) {
            print('✅ FCM background handler registered');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('⚠️ FCM background handler registration failed: $e');
            print('Stack trace: $stackTrace');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ Firebase initialization failed: $e');
          print('Stack trace: $stackTrace');
        }
      }

      try {
        await di.init();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ Dependency injection failed: $e');
          print('Stack trace: $stackTrace');
        }
        rethrow;
      }

      try {
        final storageService = di.sl<StorageService>();
        final dioClient = di.sl<DioClient>();
        final token = storageService.getToken();

        if (token != null) {
          dioClient.setAuthToken(token);
        }

        try {
          await FCMService().initialize(storageService);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ FCM initialization error: $e');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('⚠️ Error setting up services: $e');
          print('Stack trace: $stackTrace');
        }
      }

      // Performance optimizations
      if (kDebugMode) {
        // Enable performance overlay in debug mode
        // PerformanceOverlayOption.all can be enabled if needed
      }

      runApp(const MyApp());
    },
    (error, stack) {
      if (kDebugMode) {
        print('❌ Async Error: $error');
        print('Stack trace: $stack');
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'DentIn',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          onGenerateRoute: onGenerateAppRoute,
          initialRoute: AppRoutes.splash,
          builder: (context, child) {
            return ConnectivityWrapper(child: child!);
          },
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
            physics: const BouncingScrollPhysics(),
          ),
          // Performance optimizations
          showPerformanceOverlay: false,
          checkerboardRasterCacheImages: false,
          checkerboardOffscreenLayers: false,
        );
      },
    );
  }
}
