import 'package:get_it/get_it.dart';
import 'package:tropanartov/features/home/data/datasources/mock_datasource.dart';
import 'package:tropanartov/features/home/data/repositories/main_repository_impl.dart';
import 'package:tropanartov/features/home/domain/repositories/main_repository.dart';
import 'package:tropanartov/features/home/domain/usecases/get_places.dart';
import 'package:tropanartov/features/home/domain/usecases/get_current_position.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/map/data/services/osrm_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => HomeBloc(
    getPlaces: sl(),
    getCurrentPosition: sl(),
    osrmService: sl(),
  ));

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