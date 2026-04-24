import 'package:astro_mukti/model/payout_model.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class PayoutStats {}

class SetPayOutInitialState extends PayoutStats {}

class PayOutLoadingStats extends PayoutStats {
  final bool isLoading;
  PayOutLoadingStats({required this.isLoading});
}

class PayoutGetStats extends PayoutStats {
  final WithdrawalResponse stats;
  PayoutGetStats({required this.stats});
}

class PayOutError extends PayoutStats {
  final String error;
  PayOutError({required this.error});
}
