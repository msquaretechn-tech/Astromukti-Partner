import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repository/repository.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  Repository homeRepository = Repository();

  BannerBloc() : super(BannerInitialState()) {
    on<BannerGetEvent>(getBannerData);
  }

  Future<void> getBannerData(BannerGetEvent event, Emitter<BannerState> emit) async {
    emit(BannerLoadingState(isLoading: true));
    try {
      List<dynamic> banners = await homeRepository.getBanner();

      emit(BannerGetState(banners: banners));
    } catch (e) {
      print("Error: $e");
      emit(BannerErrorState(error: e.toString()));
    }
  }
}

// EVENTS
@immutable
abstract class BannerEvent {}

class BannerGetEvent extends BannerEvent {}

// STATES
@immutable
abstract class BannerState {}

class BannerInitialState extends BannerState {}

class BannerLoadingState extends BannerState {
  final bool isLoading;
  BannerLoadingState({required this.isLoading});
}

class BannerErrorState extends BannerState {
  final String error;
  BannerErrorState({required this.error});
}

class BannerGetState extends BannerState {
  final List<dynamic> banners;
  BannerGetState({required this.banners});
}
