import 'dart:async';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../main.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../../utils/utils.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String otp;
  final String? countryCode;
  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.otp,
    this.countryCode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  late Timer _timer;
  int _remainingTime = 45;

  // function for start timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // function for resend otp
  void _resendOtp() {
    setState(() {
      _remainingTime = 45;
    });
    _startTimer();
    BlocProvider.of<AuthBloc>(context).add(SendOtpEvent(data: {
      'mobile': widget.mobileNumber.toString(),
      'userType': "VENDOR"
    }));
  }

  @override
  Widget build(BuildContext context) {
    log("phone : ${widget.mobileNumber}");
    const fillColor = Colors.white;
    const borderColor = Colors.black;

    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.07,
      textStyle: Resources.styles.kTextStyle18B(Resources.colors.blackColor),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
             Spacer(flex: 1,),
              SizedBox(
                height: 150,
                child: Image.asset(
                  Resources.images.appLogo,
                  height: 200,
                  width: 100,
                ),
              ),

              Text(
                "Verification Code",
                textAlign: TextAlign.center,
                style: Resources.styles.kTextStyle20B(Colors.black),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Enter the 6-digit OTP sent to your mobile number to complete your login.\n"
                  "XXXX ${widget.mobileNumber.toString().substring(widget.mobileNumber.toString().length - 4)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Pinput(
                controller: pinController,
                focusNode: focusNode,
                // androidSmsAutofillMethod:
                //     AndroidSmsAutofillMethod.smsUserConsentApi,
                // listenForMultipleSmsOnAndroid: true,
                defaultPinTheme: defaultPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 10),
                validator: (value) =>
                    value?.length == 4 ? null : 'Enter the full OTP',
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) => debugPrint('OTP Entered: $pin'),
                cursor: Container(
                  width: 2,
                  height: 30,
                  color: Resources.colors.themeColor,
                ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: borderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyBorderWith(
                  border: Border.all(color: borderColor),
                ),
              ),
              SizedBox(
                height: Resources.dimens.height(context) * 0.03,
              ),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  log("After verify otp State :  $state");
                  if (state.runtimeType == AuthOtpVerifySuccessState) {
                    var data = state as AuthOtpVerifySuccessState;

                    log("After verify otp response :  $data");
                    if (data.response["data"]?["vendor"]["_id"] == null) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      GoRouter.of(context).pushNamed(
                        RoutesName.navigationScreen,
                        // extra: {'mobile': widget.mobileNumber}
                      );
                      PrefService()
                          .setRegId(data.response['data']['vendor']['_id']);
                      PrefService()
                          .setToken(data.response['data']['accessToken']);
                      PrefService().setUserSession(true);
                      Utils.snackBar(" ${data.response['message']}", context);
                    } else {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      GoRouter.of(context)
                          .pushReplacementNamed(RoutesName.navigationScreen);
                      sendNotificationLive();

                      Utils.snackBar("Login Successful", context);
                    }
                  } else if (state is AuthErrorState) {
                    Fluttertoast.showToast(msg: "Invalid OTP");
                  }
                },
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case AuthLoadingState:
                      return Center(
                        child: CircularProgressIndicator(
                          color: Resources.colors.buttonColor,
                        ),
                      );

                    default:
                      return GestureDetector(
                        onTap: () {
                          log("Click on verify otp");

                          if (pinController.text.trim().length != 4) {
                            Utils.snackBar(
                                "Please enter 4 digit mobile number OTP",
                                context);
                          } else {
                            BlocProvider.of<AuthBloc>(context).add(
                                VerifyOtpEvent(data: {
                              "mobile": widget.mobileNumber,
                              "otp": pinController.text.toString()
                            }));
                          }
                        },
                        child:  Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40), // pill shape
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF9E076),
                                Color(0xFFD4AF37),
                                Color(0xFFF9E076),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.white70, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Otp',
                              style: Resources.styles.kTextStyle16B(Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                  }
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _remainingTime == 0 ? _resendOtp : null,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: _remainingTime == 0
                        ? "Didn't receive a otp? "
                        : "Resend  in $_remainingTime s",
                    style: Resources.styles
                        .kTextStyle16B(Resources.colors.blackColor),
                    children: [
                      if (_remainingTime == 0)
                        TextSpan(
                          text: ' Resend',
                          style: Resources.styles
                              .kTextStyle18UB(Resources.colors.buttonColor),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
