import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../model/call_waiting_model.dart';
import '../../model/login_history_model.dart';
import '../../model/payment_detail_model.dart';
import '../../model/traning_video_model.dart';
import '../../model/transaction_earning_model.dart';
import '../../model/vender_detail_model.dart';
import '../../model/vendor_blog_detail_model.dart';
import '../../model/vendor_call_detail_model.dart';
import '../../repository/repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Repository homeRepository = Repository();

  HomeBloc() : super(HomeInitialState()) {
    on<TrainingVideoEvent>(trainingVideo);
    on<GetVendorDetailEvent>(getVendorDetail);
    on<VendorCallDetailEvent>(getVendorCallDetail);
    on<CreateBlogEvent>(createBlog);
    on<UpdateBlogEvent>(blogUpdate);
    on<GetVendorBlogDetailsEvent>(getBlogList);
    on<DeleteBlogEvent>(deleteBlogDetail);
    on<GetLoginHistoryEvent>(loginHistory);
    on<GetPaymentDetailEvent>(fetchPaymentReport);
    on<GetTransactionEarningEvent>(getTransactionEarning);

  }


  // training video
  Future<void> trainingVideo(TrainingVideoEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    List<TrainingVideoModel> videoList = await homeRepository.getTrainingVideo();
    emit(TrainingVideoSuccessState(video: videoList));
  }

  //Vendor Detail
  Future<void> getVendorDetail(GetVendorDetailEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    VendorDetailsModel vendorList = await homeRepository.getVendorDetail();
    List<CallWaitingModel> callWaitingModel = await homeRepository.getVendorWaitingCall();
    emit(VendorDetailSuccessState(vendorDetail: vendorList, callWaitingList: callWaitingModel));
  }

  //Vendor Call Detail
  Future<void> getVendorCallDetail(
      VendorCallDetailEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoadingState(isLoading: true));

    final callList =
    await homeRepository.getVendorCallDetail(event.type);

    emit(VendorCallDetailSuccessState(callHistory: callList));
  }



  // create blog
  Future<void> createBlog(CreateBlogEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response = await homeRepository.createBlogApi(event.formData, event.files);

      emit(CreateBlogSuccessState(response: response));

      List<VendorBlogDetailModel> blogList = await homeRepository.getVendorBlogDetail();
      emit(GetBlogListSuccessState(blogList: blogList));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  //get Vendor blog list
  Future<void> getBlogList(GetVendorBlogDetailsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      List<VendorBlogDetailModel> blogList = await homeRepository.getVendorBlogDetail();
      emit(GetBlogListSuccessState(blogList: blogList));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  //Update Blog
  Future<void> blogUpdate(UpdateBlogEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response = await homeRepository.updateBlogApi(event.formData, event.files, event.docId);
      emit(UpdateBlogSuccessState(response: response));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  //Delete Vendor blog
  Future<void> deleteBlogDetail(DeleteBlogEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      await homeRepository.deleteVehicle(event.documentId);

      List<VendorBlogDetailModel> blogList = await homeRepository.getVendorBlogDetail();
      emit(GetBlogListSuccessState(blogList: blogList));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

//Login History Details
  Future<void> loginHistory(GetLoginHistoryEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      List<LoginHistoryModel> loginHistoryList = await homeRepository.getLoginHistoryDetail();
      emit(GetLoginHistorySuccessState(loginHistory: loginHistoryList));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  //Payment Report
  Future<void> fetchPaymentReport(GetPaymentDetailEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    try {
      List<PaymentDetailModel> paymentDetailList = await homeRepository.getPaymentReport();
      emit(GetPaymentDetailSuccessState(paymentDetail: paymentDetailList));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  //Transaction Earning
  Future<void> getTransactionEarning(GetTransactionEarningEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState(isLoading: true));
    TransactionEarningModel earningList = await homeRepository.getTransactionEarning();
    emit(GetTransactionEarningSuccessState(earningData: earningList));
  }


}
