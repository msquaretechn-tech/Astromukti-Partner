import 'package:flutter/foundation.dart';
import 'package:astro_mukti/model/stats_model.dart';

@immutable
abstract class StatsState {}

class StatsInitialState extends StatsState {}

class StatsLoadingState extends StatsState {
  final bool isLoading;
  StatsLoadingState({required this.isLoading});
}

class StatsGetState extends StatsState {
  final StatsModel stats;
  StatsGetState({required this.stats});
}

class StatsErrorState extends StatsState {
  final String error;
  StatsErrorState({required this.error});
}
