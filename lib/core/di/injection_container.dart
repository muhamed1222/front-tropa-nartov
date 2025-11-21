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
import 'package:tropanartov/core/network/dio_client.dart';
import 'package:tropanartov/services/auth_service_instance.dart';
import 'package:tropanartov/services/user_service.dart';
import 'package:tropanartov/services/strapi_service.dart';
import 'package:tropanartov/config/environment_config.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Dio клиент
  sl.registerLazySingleton(() => createDio());

  // StrapiService для работы со Strapi CMS
  sl.registerLazySingleton(() => StrapiService(baseUrl: EnvironmentConfig.strapiBaseUrl));

  // AuthService использует StrapiService
  sl.registerLazySingleton(() => AuthService(strapiService: sl<StrapiService>()));

  // UserService использует только AuthService
  sl.registerLazySingleton(() => UserService(authService: sl()));

  // BLoC
  sl.registerFactory(() => HomeBloc(
    getPlaces: sl(),
    getCurrentPosition: sl(),
    osrmService: sl(),
  ));

  sl.registerFactory(() => RoutesBloc(
        strapiService: sl<StrapiService>(),
        authService: sl<AuthService>(),
      ));
  
  sl.registerFactory(() => FavouritesBloc(
        authService: sl<AuthService>(),
        // StrapiService и datasources будут получены через di.sl внутри
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