part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

//training video event
class TrainingVideoEvent extends HomeEvent {}

//Vendor Detail event
class GetVendorDetailEvent extends HomeEvent {}

//Vendor Call Detail event
class VendorCallDetailEvent extends HomeEvent {
  final String? type;

  VendorCallDetailEvent({this.type});
}

//create blog event
class CreateBlogEvent extends HomeEvent {
  final Map<String, dynamic> formData;
  final List<MultipartFile> files;

  CreateBlogEvent({required this.formData, required this.files});
}

//Update Blog event
class UpdateBlogEvent extends HomeEvent {
  final Map<String, dynamic> formData;
  final List<MultipartFile> files;
  final String docId;

  UpdateBlogEvent({
    required this.formData,
    required this.files,
    required this.docId,
  });
}

//Get Vendor Blog Details event
class GetVendorBlogDetailsEvent extends HomeEvent {}

//Delete Blog Event
class DeleteBlogEvent extends HomeEvent {
  final String documentId;

  DeleteBlogEvent({required this.documentId});
}

//Get Login History Event
class GetLoginHistoryEvent extends HomeEvent {}

//Get Payment detail Event
class GetPaymentDetailEvent extends HomeEvent {}

//Get Transaction Earning Event
class GetTransactionEarningEvent extends HomeEvent {}
