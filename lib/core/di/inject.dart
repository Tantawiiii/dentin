import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/messages/cubit/chat_cubit.dart';
import '../../features/messages/data/repo/chat_repository.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/fcm_service.dart';
import '../services/remote_config_service.dart';
import '../../features/auth/login/data/repo/login_repository.dart';
import '../../features/auth/login/cubit/login_cubit.dart';
import '../../features/auth/register/data/repo/register_repository.dart';
import '../../features/auth/register/cubit/register_cubit.dart';
import '../../features/auth/forget_password/data/repo/forget_password_repository.dart';
import '../../features/auth/forget_password/cubit/forget_password_cubit.dart';
import '../../features/home/data/repo/post_repository.dart';
import '../../features/home/cubit/post_cubit.dart';
import '../../features/explore_stories/data/repo/stories_repository.dart';
import '../../features/explore_stories/cubit/stories_cubit.dart';
import '../../features/profile/data/repo/profile_repository.dart';
import '../../features/store/data/repo/product_repository.dart';
import '../../features/jobs/data/repo/job_repository.dart';
import '../../features/rent_clinic/data/repo/rent_repository.dart';
import '../../features/rent_clinic/cubit/rent_cubit.dart';
import '../../features/friends/cubit/friend_requests_cubit.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/home/services/firebase_comments_service.dart';
import '../../features/users/data/repo/users_repository.dart';
import '../../features/users/cubit/users_list_cubit.dart';
import '../../features/events/data/repo/event_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Storage Service
  sl.registerLazySingleton(() => StorageService(sl<SharedPreferences>()));

  // Firebase Service
  sl.registerLazySingleton(() => FirebaseService());

  // FCM Service
  sl.registerLazySingleton(() => FCMService());

  // Connectivity Service
  sl.registerLazySingleton(() => ConnectivityService());

  // Remote Config Service
  sl.registerLazySingleton(() => RemoteConfigService());

  // Dio Client
  sl.registerLazySingleton(
    () => DioClient(storageService: sl<StorageService>()),
  );

  // API Service
  sl.registerLazySingleton(() => ApiService(sl<DioClient>()));

  // Login Repository
  sl.registerLazySingleton(() => LoginRepository(sl<ApiService>()));

  // Register Repository
  sl.registerLazySingleton(() => RegisterRepository(sl<ApiService>()));

  // Forget Password Repository
  sl.registerLazySingleton(() => ForgetPasswordRepository(sl<ApiService>()));

  // Post Repository
  sl.registerLazySingleton(() => PostRepository(sl<ApiService>()));

  // Stories Repository
  sl.registerLazySingleton(() => StoriesRepository(sl<ApiService>()));

  // Profile Repository
  sl.registerLazySingleton(() => ProfileRepository(sl<ApiService>()));

  // Product Repository
  sl.registerLazySingleton(() => ProductRepository(sl<ApiService>()));

  // Job Repository
  sl.registerLazySingleton(() => JobRepository(sl<ApiService>()));

  // Chat Repository
  sl.registerLazySingleton(() => ChatRepository(sl<ApiService>()));

  // Rent Repository
  sl.registerLazySingleton(() => RentRepository(sl<ApiService>()));

  // Users Repository
  sl.registerLazySingleton(() => UsersRepository(sl<ApiService>()));

  // Event Repository
  sl.registerLazySingleton(() => EventRepository(sl<ApiService>()));

  sl.registerFactory(
    () => LoginCubit(
      repository: sl<LoginRepository>(),
      storageService: sl<StorageService>(),
      dioClient: sl<DioClient>(),
      fcmService: sl<FCMService>(),
    ),
  );

  sl.registerFactory(
    () => RegisterCubit(
      repository: sl<RegisterRepository>(),
      storageService: sl<StorageService>(),
      dioClient: sl<DioClient>(),
      fcmService: sl<FCMService>(),
    ),
  );

  sl.registerFactory(
    () => ForgetPasswordCubit(repository: sl<ForgetPasswordRepository>()),
  );

  sl.registerFactory(() => PostCubit(sl<PostRepository>()));

  sl.registerFactory(() => StoriesCubit(sl<StoriesRepository>()));

  sl.registerLazySingleton(
    () => ChatCubit(
      sl<ChatRepository>(),
      sl<FirebaseService>(),
      sl<StorageService>(),
    ),
  );

  sl.registerFactory(() => RentCubit(sl<RentRepository>()));

  // Friend Requests Cubit
  sl.registerLazySingleton(
    () => FriendRequestsCubit(
      sl<FirebaseService>(),
      sl<StorageService>(),
      sl<ApiService>(),
    ),
  );

  // Notifications Cubit
  sl.registerLazySingleton(
    () => NotificationsCubit(sl<FirebaseService>(), sl<StorageService>()),
  );

  // Users List Cubit
  sl.registerFactory(() => UsersListCubit(sl<UsersRepository>()));

  // Firebase Comments Service
  sl.registerLazySingleton(
    () => FirebaseCommentsService(
      firebaseService: sl<FirebaseService>(),
    ),
  );
}
