import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../model/get_vendor.dart';
import '../../repository/repository.dart';
import '../../utils/image_picker_state.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Repository authRepository = Repository();
  final ImagePickerUtils imagePickerUtils;

  AuthBloc(this.imagePickerUtils) : super(AuthInitialState()) {
    on<SendOtpEvent>(sendOtp);
    on<VerifyOtpEvent>(verifyOtp);
    on<RegistrationEvent>(registration);
    // on<AuthGetUserProfileEvent>(getUserProfile);
    on<AuthGetVendorProfileEvent>(getVendorProfile);
    on<ProfileUpdateEvent>(profileUpdate);
    on<SignupEvent>(loginEmailPassword);
  }

  // send otp
  Future<void> sendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
          await authRepository.generateOtpApi(event.data);
      log("Otp generated successfully: $response");
      emit(AuthOtpSendSuccessState(response: response));
    } catch (e) {
      log("Error while generating OTP: $e");
      emit(AuthErrorState(error: e.toString()));
    }
  }

  // login with email and password
  Future<void> loginEmailPassword(
      SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
          await authRepository.loginEmail(event.data);
      log("login successfully: $response");
      emit(AuthLoginSuccessState(response: response));
    } catch (e) {
      log("Error while login: $e");
      emit(AuthErrorState(error: e.toString()));
    }
  }

  // verify otp
  Future<void> verifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
          await authRepository.verifyOtpApi(event.data);

      emit(AuthOtpVerifySuccessState(response: response));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  // registration otp
  Future<void> registration(
      RegistrationEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
          await authRepository.registrationApi(event.formData, event.files);

      emit(AuthRegistrationSuccessState(response: response));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  //patch Profile update
  Future<void> profileUpdate(
      ProfileUpdateEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    try {
      Map<String, dynamic> response =
          await authRepository.updateProfile(event.formData, event.files);

      emit(ProfileUpdateSuccessState(response: response));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

// get vendor profile details from the server
  Future<void> getVendorProfile(
      AuthGetVendorProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState(isLoading: true));
    await authRepository.getVendorProfile().then((value) {
      emit(AuthGetVendorSuccessState(response: value!));
    }).catchError((e) {
      emit(AuthErrorState(error: e));
    });
  }
}
