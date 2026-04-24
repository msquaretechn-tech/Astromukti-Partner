part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

// initial state
class HomeInitialState extends HomeState {}

// loading
class HomeLoadingState extends HomeState {
  final bool isLoading;

  HomeLoadingState({required this.isLoading});
}

// error state
class HomeErrorState extends HomeState {
  final dynamic error;

  HomeErrorState({required this.error});
}


//training video state
class TrainingVideoSuccessState extends HomeState {
  final List<TrainingVideoModel> video;

  TrainingVideoSuccessState({required this.video});
}

//Vendor Detail state
class VendorDetailSuccessState extends HomeState {
  final VendorDetailsModel vendorDetail;
  final List<CallWaitingModel>? callWaitingList;

  VendorDetailSuccessState({
    required this.vendorDetail,
    this.callWaitingList,
  });
}

//Vendor Call Detail state
class VendorCallDetailSuccessState extends HomeState {
  final List<VendorCallDetailModel> callHistory;

  VendorCallDetailSuccessState({required this.callHistory});
}


//create blog state
class CreateBlogSuccessState extends HomeState {
  final dynamic response;

  CreateBlogSuccessState({required this.response});
}

//Get Vendor Blog List state
class GetBlogListSuccessState extends HomeState {
  final List<VendorBlogDetailModel> blogList;

  GetBlogListSuccessState({required this.blogList});
}

//Update Blog state
class UpdateBlogSuccessState extends HomeState {
  final dynamic response;

  UpdateBlogSuccessState({required this.response});
}

//Delete blog state
class DeleteBlogSuccessState extends HomeState {
  final dynamic response;

  DeleteBlogSuccessState({required this.response});
}

//Get Login History state
class GetLoginHistorySuccessState extends HomeState {
  final List<LoginHistoryModel> loginHistory;

  GetLoginHistorySuccessState({required this.loginHistory});
}

//Get Payment Details state
class GetPaymentDetailSuccessState extends HomeState {
  final List<PaymentDetailModel> paymentDetail;

  GetPaymentDetailSuccessState({required this.paymentDetail});
}

// Get Transaction Earning
class GetTransactionEarningSuccessState extends HomeState {
  final TransactionEarningModel earningData;

  GetTransactionEarningSuccessState({required this.earningData});
}

