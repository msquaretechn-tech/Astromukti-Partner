import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/booking_model.dart';
import '../../repository/repository.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  Repository homeRepository = Repository();

  BookingBloc() : super(BookingInitialState()) {
    on<BookingGetEvent>(getBookingData);
  }

  Future<void> getBookingData(BookingGetEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(isLoading: true));
    try {
      List<BookingModel> booking = await homeRepository.getBooking(event.status!);

      emit(BookingGetState(booking: booking));
    } catch (e) {
      print("Error: $e");
      emit(BookingErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class BookingEvent {}

class BookingGetEvent extends BookingEvent {
  final String? status;

  BookingGetEvent(this.status);}


// STATES
@immutable
abstract class BookingState {}

class BookingInitialState extends BookingState {}

class BookingLoadingState extends BookingState {
  final bool isLoading;
  BookingLoadingState({required this.isLoading});
}

class BookingErrorState extends BookingState {
  final String error;
  BookingErrorState({required this.error});
}

class BookingGetState extends BookingState {
  final List<BookingModel> booking;
  BookingGetState({required this.booking});
}
