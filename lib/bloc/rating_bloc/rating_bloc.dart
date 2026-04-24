import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/rating_model.dart';
import '../../repository/repository.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  Repository homeRepository = Repository();

  RatingBloc() : super(RatingInitialState()) {
    on<RatingGetEvent>(getRatingData);
  }

  Future<void> getRatingData(RatingGetEvent event, Emitter<RatingState> emit) async {
    emit(RatingLoadingState(isLoading: true));
    try {
      List<VendorRatingModel> ratings = await homeRepository.getVendorRating(event.type!);

      emit(RatingGetState(ratings: ratings));
    } catch (e) {
      print("Error: $e");
      emit(RatingErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class RatingEvent {}

class RatingGetEvent extends RatingEvent {
  final String? type;

  RatingGetEvent(this.type);}


// STATES
@immutable
abstract class RatingState {}

class RatingInitialState extends RatingState {}

class RatingLoadingState extends RatingState {
  final bool isLoading;
  RatingLoadingState({required this.isLoading});
}

class RatingErrorState extends RatingState {
  final String error;
  RatingErrorState({required this.error});
}

class RatingGetState extends RatingState {
  final List<VendorRatingModel> ratings;
  RatingGetState({required this.ratings});
}
