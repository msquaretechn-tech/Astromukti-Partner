part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

// initial
class AuthInitialState extends AuthState {}

// loading
class AuthLoadingState extends AuthState {
  final bool isLoading;

  AuthLoadingState({required this.isLoading});
}

// error state
class AuthErrorState extends AuthState {
  final dynamic error;

  AuthErrorState({required this.error});
}

// OtpSend success state
class AuthOtpSendSuccessState extends AuthState {
  final dynamic response;

  AuthOtpSendSuccessState({required this.response});
}

// OtpVerify success state
class AuthOtpVerifySuccessState extends AuthState {
  final dynamic response;

  AuthOtpVerifySuccessState({required this.response});
}

// registration state
class AuthRegistrationSuccessState extends AuthState {
  final dynamic response;

  AuthRegistrationSuccessState({required this.response});
}

// login email and password state
class AuthLoginSuccessState extends AuthState {
  final dynamic response;
  AuthLoginSuccessState({required this.response});
}

// profile Update state
class ProfileUpdateSuccessState extends AuthState {
  final dynamic response;

  ProfileUpdateSuccessState({required this.response});
}
// profile get state
class AuthGetVendorSuccessState extends AuthState {
  final VendorProfileModel response;
  AuthGetVendorSuccessState({required this.response});
}
