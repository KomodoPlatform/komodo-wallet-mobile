import 'package:bloc/bloc.dart';

/// This is just a placeholder bloc to make the code compile in places
/// where a bloc is required but we don't have a bloc to use yet.
class PlaceholderBloc extends Bloc<PlaceholderEvent, PlaceholderState> {
  PlaceholderBloc() : super(PlaceholderState());
}

class PlaceholderState {}

sealed class PlaceholderEvent {}
