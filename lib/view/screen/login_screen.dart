import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/view/screen/registration_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../main.dart';
import '../../repository/repository.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../../utils/utils.dart';
import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = false;
  final _signupEmail = TextEditingController();
  final _signupPassword = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final focusNode = FocusNode();
  bool _isPasswordVisible = false;
  String countryCode = "+91";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .05),

            // App Logo + Title
            Container(
              margin: EdgeInsets.all(10),
              height: 150,
              child: Image.asset(
                Resources.images.appLogo,
                height: 200,
                width: 100,
              ),
            ),
            Text(
              "ASTRO MUKTI",
              textAlign: TextAlign.center,
              style: Resources.styles.kTextStyle26(Colors.black),
            ),
            Text(
              "Online Astrology",
              textAlign: TextAlign.center,
              style: Resources.styles.kTextStyle14B(Colors.black),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.05,
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(children: [buildLoginMobile()]),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.runtimeType == AuthOtpSendSuccessState) {
                      var data = state as AuthOtpSendSuccessState;
                      // log("after send otp response :${data.response}");
                      GoRouter.of(context).pushNamed(
                        RoutesName.otpScreen,
                        extra: {
                          'mobileNumber': countryCode + _phoneNumberController.text
                              .trim()
                              .toString(),
                          'otp': data.response['data']['otp'],

                        },
                      );
                      Repository().sendSMS(
                        countryCode + _phoneNumberController.text.trim().toString(),
                        data.response['data']['otp'].toString(),
                      );

                      Utils.snackBar("${data.response['message']}", context);
                      PrefService().setRegId(
                        data.response['data']['vendor']['_id'],
                      );
                      PrefService().setToken(
                        data.response['data']['accessToken'],
                      );
                      PrefService().setUserSession(true);
                      sendNotificationLive();
                    } else if (state.runtimeType == AuthErrorState) {
                      var data = state as AuthErrorState;
                      if (data.error is List) {
                        if (data.error.isNotEmpty && data.error[0] is Map) {
                          Utils.snackBar(
                            data.error[0]["message"].toString(),
                            context,
                          );
                        } else {
                          Utils.snackBar("Unknown error occurred", context);
                        }
                      } else if (data.error is Map) {
                        Utils.snackBar(
                          data.error["message"].toString(),
                          context,
                        );
                      } else {
                        // Utils.snackBar(
                        //   data.error["message"].toString(),
                        //   context,
                        // );
                      }
                    }

                    log("State listen : $state");
                  },
                  builder: (context, state) {
                    log("State : $state");
                    switch (state.runtimeType) {
                      case AuthLoadingState _:
                        return Center(
                          child: CircularProgressIndicator(
                            color: Resources.colors.buttonColor,
                          ),
                        );

                      default:
                        return GestureDetector(
                          onTap: ()

                            {
                              log("Click on send otp");
                              BlocProvider.of<AuthBloc>(context).add(
                                SendOtpEvent(
                                  data: {
                                    'mobile': countryCode +
                                        _phoneNumberController.text.toString(),
                                    'userType': "VENDOR",
                                  },
                                ),
                              );
                            },

                          child: _buildSocialButton(text: 'Continue'),
                        );
                    }
                  },
                ),

                // : BlocConsumer<AuthBloc, AuthState>(
                //     listener: (context, state) {
                //       log("state:$state");
                //       if (state is AuthLoginSuccessState) {
                //         var data = state;
                //         log("ggggg:$data");
                //         log("Login Successful, Response: ${data.response}");
                //         log(
                //           "Login Successful, Response: ${data.response["data"]["vendor"]}",
                //         );
                //
                //         Navigator.popUntil(
                //           context,
                //           (route) => route.isFirst,
                //         );
                //         GoRouter.of(
                //           context,
                //         ).pushNamed(RoutesName.navigationScreen);
                //         PrefService().setRegId(
                //           data.response['data']['vendor']['_id'],
                //         );
                //         PrefService().setToken(
                //           data.response['data']['accessToken'],
                //         );
                //         PrefService().setUserSession(true);
                //         Utils.snackBar(
                //           "${data.response['message']}",
                //           context,
                //         );
                //         // send notification
                //         sendNotificationLive();
                //       } else if (state is AuthErrorState) {
                //         Utils.snackBar(
                //           "Invalid email or password. Please try again.",
                //           context,
                //         );
                //       }
                //     },
                //     builder: (context, state) {
                //       switch (state.runtimeType) {
                //         case AuthLoadingState:
                //           return Center(
                //             child: CircularProgressIndicator(
                //               color: Resources.colors.buttonColor,
                //             ),
                //           );
                //         default:
                //           return GestureDetector(
                //             onTap: () async {
                //               if (_signupEmail.text.isEmpty ||
                //                   _signupPassword.text.isEmpty) {
                //                 Utils.snackBar(
                //                   "Email and password must not be empty",
                //                   context,
                //                 );
                //                 return;
                //               }
                //               BlocProvider.of<AuthBloc>(context).add(
                //                 SignupEvent(
                //                   data: {
                //                     "email": _signupEmail.text.trim(),
                //                     "password": _signupPassword.text.trim(),
                //                   },
                //                 ),
                //               );
                //             },
                //             child: _buildSocialButton(text: 'Login'),
                //           );
                //       }
                //     },
                //   ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Resources.styles.kTextStyle16(Colors.grey),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        " Signup",
                        style: TextStyle(
                          color: Resources.colors.blackColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String text,
    bool isActive,
    bool loginTab,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogin = loginTab;
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width * 0.41,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isActive ? Colors.black : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildLoginMobile() {
    return Column(
      children: [
        IntlPhoneField(
          keyboardType: TextInputType.number,
          controller: _phoneNumberController,
          focusNode: focusNode,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Phone Number',
            hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          initialCountryCode: 'IN',
          showDropdownIcon: false,
          onChanged: (phone) {
            setState(() {
              countryCode = phone.countryCode;
            });
            if (kDebugMode) {
              print(phone.completeNumber);
            }
          },
          onCountryChanged: (country) {
            setState(() {
              countryCode = "+${country.dialCode}";
            });
          },
        ),
      ],
    );
  }

  Widget buildLoginEmail() {
    return Column(
      children: [
        _buildTextField(
          controller: _signupEmail,
          hintText: 'Login Id',
          icon: Icons.email,
        ),
        _buildTextField(
          controller: _signupPassword,
          hintText: 'Password',
          icon: Icons.lock,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: TextFormField(
        obscureText: isPassword && !_isPasswordVisible,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          fillColor: Colors.white,
          prefixIcon: Icon(icon),
          filled: true,
          hintText: hintText,
          hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String text}) {
    return Container(
      alignment: AlignmentGeometry.center,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40), // pill shape
        gradient: LinearGradient(
          colors: [Color(0xFFF9E076), Color(0xFFD4AF37), Color(0xFFF9E076)],
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

      child: Text(text, style: Resources.styles.kTextStyle18B(Colors.black)),
    );
  }
}
