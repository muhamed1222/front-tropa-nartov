import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'routes_event.dart';
part 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  RoutesBloc() : super(RoutesInitial()) {
    on<RoutesEvent>((event, emit) {

    });
  }
}
