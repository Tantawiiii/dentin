import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../services/storage_service.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Storage Service
  sl.registerLazySingleton(() => StorageService(sl<SharedPreferences>()));

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

  sl.registerFactory(
    () => LoginCubit(
      repository: sl<LoginRepository>(),
      storageService: sl<StorageService>(),
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerFactory(
    () => RegisterCubit(
      repository: sl<RegisterRepository>(),
      storageService: sl<StorageService>(),
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerFactory(
    () => ForgetPasswordCubit(
      repository: sl<ForgetPasswordRepository>(),
    ),
  );

  sl.registerFactory(
    () => PostCubit(
      sl<PostRepository>(),
    ),
  );

  sl.registerFactory(
    () => StoriesCubit(
      sl<StoriesRepository>(),
    ),
  );
}
