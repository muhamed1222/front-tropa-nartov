import 'package:get_it/get_it.dart';
import 'package:tropanartov/features/home/data/datasources/mock_datasource.dart';
import 'package:tropanartov/features/home/data/repositories/main_repository_impl.dart';
import 'package:tropanartov/features/home/domain/repositories/main_repository.dart';
import 'package:tropanartov/features/home/domain/usecases/get_places.dart';
import 'package:tropanartov/features/home/domain/usecases/get_current_position.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/map/data/services/osrm_service.dart';
import 'package:tropanartov/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:tropanartov/features/favourites/presentation/bloc/favourites_bloc.dart';
import 'package:tropanartov/features/places/presentation/bloc/places_bloc.dart';
import 'package:tropanartov/features/user/presentation/bloc/user_bloc.dart';
import 'package:tropanartov/services/api_service_dio.dart';
import 'package:tropanartov/core/network/dio_client.dart';
import 'package:tropanartov/services/auth_service_instance.dart';
import 'package:tropanartov/services/user_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Dio клиент
  sl.registerLazySingleton(() => createDio());

  // ApiService на Dio
  sl.registerLazySingleton(() => ApiServiceDio(dio: sl()));

  // AuthService (instance-based) - регистрируем AuthServiceInstance, а не wrapper
  sl.registerLazySingleton(() => AuthService(apiService: sl<ApiServiceDio>()));

  // UserService (instance-based)
  sl.registerLazySingleton(() => UserService(
        apiService: sl(),
        authService: sl(),
      ));

  // BLoC
  sl.registerFactory(() => HomeBloc(
    getPlaces: sl(),
    getCurrentPosition: sl(),
    osrmService: sl(),
  ));

  sl.registerFactory(() => RoutesBloc(
        apiService: sl<ApiServiceDio>(),
        authService: sl<AuthService>(),
      ));
  
  sl.registerFactory(() => FavouritesBloc(
        apiService: sl<ApiServiceDio>(),
        authService: sl<AuthService>(),
      ));

  sl.registerFactory(() => PlacesBloc());

  sl.registerFactory(() => UserBloc());

  // Use cases
  sl.registerLazySingleton(() => GetPlaces(sl()));
  sl.registerLazySingleton(() => GetCurrentPosition(sl()));

  // Repository
  sl.registerLazySingleton<MainRepository>(() => MainRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<MockDatasource>(() => MockDatasource());

  // Services
  sl.registerLazySingleton(() => OsrmService());
}