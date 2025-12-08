import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../services/storage_service.dart';
import '../../features/auth/login/data/repo/login_repository.dart';
import '../../features/auth/login/cubit/login_cubit.dart';

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

  // Login Cubit (factory - each screen gets a new instance)
  sl.registerFactory(
    () => LoginCubit(
      repository: sl<LoginRepository>(),
      storageService: sl<StorageService>(),
      dioClient: sl<DioClient>(),
    ),
  );
}
