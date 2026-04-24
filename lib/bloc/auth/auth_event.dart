part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

// initial event
class AuthInitialEvent extends AuthEvent {}

// send otp event
class SendOtpEvent extends AuthEvent {
  final Map<String, dynamic> data;

  SendOtpEvent({required this.data});
}
// send otp event
class SignupEvent extends AuthEvent {
  final Map<String, dynamic> data;

  SignupEvent({required this.data});
}

// verify otp event
class VerifyOtpEvent extends AuthEvent {
  final dynamic data;

  VerifyOtpEvent({required this.data});
}

// registration event
class RegistrationEvent extends AuthEvent {
  final Map<String, dynamic> formData;
  final List<MultipartFile> files;

  RegistrationEvent({
    required this.formData,
    required this.files,
  });
}


// registration event
class ProfileUpdateEvent extends AuthEvent {
  final Map<String, dynamic> formData;
  final List<MultipartFile> files;

  ProfileUpdateEvent({
    required this.formData,
    required this.files,
  });


}

// get user profile
class AuthGetUserProfileEvent extends AuthEvent {}
// get vendor profile
class AuthGetVendorProfileEvent extends AuthEvent {}