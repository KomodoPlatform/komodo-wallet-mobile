import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(DrawerClosedState()) {
    on<DrawerOpened>((event, emit) => emit(DrawerOpenState()));
    on<DrawerClosed>((event, emit) => emit(DrawerClosedState()));
    on<DrawerToggleRequested>((event, emit) {
      if (state is DrawerOpenState) {
        emit(DrawerClosedState());
      } else {
        emit(DrawerOpenState());
      }
    });
  }
}

sealed class DrawerState {}

final class DrawerOpenState extends DrawerState {}

final class DrawerClosedState extends DrawerState {}

abstract class DrawerEvent {}

class DrawerOpened extends DrawerEvent {}

class DrawerClosed extends DrawerEvent {}

class DrawerToggleRequested extends DrawerEvent {}
