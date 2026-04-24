import 'package:flutter/foundation.dart';

@immutable
abstract class StateEvent {}

class StateGetEvent extends StateEvent {}
