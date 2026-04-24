
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../repository/repository.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> with CodeAutoFill {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool showOtpField = false;
  bool showPasswordFields = false;
  bool otpVerified = false;
  String countryCode = "+91";

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void codeUpdated() {
    setState(() {
      _otpController.text = code ?? "";
    });
  }

  void sendOtp() {
    Repository().generateOtpApi({
      "mobile": countryCode + _phoneNumberController.text,
      'userType': "VENDOR"
    }).then((data) {
      if (data['success'] == true) {
        Repository().sendSMS(
          countryCode + _phoneNumberController.text.trim(),
          data['data']['otp'].toString(),
        );
        Fluttertoast.showToast(
            msg: "OTP is ${data['data']['otp']}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        Utils.snackBar("${data['message']}", context);

        setState(() {
          showOtpField = true;
        });
      } else {
        Utils.snackBar("Failed to send OTP", context);
      }
    }).catchError((error) {
      Utils.snackBar("Error sending OTP", context);
    });
  }

  void resetPassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      Utils.snackBar("Passwords do not match", context);
      return;
    }

    Repository().forgetPassword({
      "mobile": countryCode + _phoneNumberController.text,
      "otp": _otpController.text,
      "password": _newPasswordController.text,
    }).then((data) {
      if (data['success'] == true) {
        Utils.snackBar("Password Reset Successfully", context);
        Navigator.pop(context);
      } else {
        Utils.snackBar("Failed to Reset Password", context);
      }
    }).catchError((error) {
      Utils.snackBar("Error resetting password", context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Resources.colors.themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Forget Password',
          style: Resources.styles.kTextStyle16B(Resources.colors.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your registered Mobile No.',
                style:
                    Resources.styles.kTextStyle18B(Resources.colors.blackColor),
              ),
              const SizedBox(height: 10),
              IntlPhoneField(
                keyboardType: TextInputType.number,
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                initialCountryCode: 'IN',
                showDropdownIcon: false,
                onChanged: (phone) {
                  setState(() {
                    countryCode = phone.countryCode;
                  });
                },
                onCountryChanged: (country) {
                  setState(() {
                    countryCode = "+${country.dialCode}";
                  });
                },
              ),
              Center(
                child: ElevatedButton(
                  onPressed: sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Resources.colors.themeColor,
                  ),
                  child: Text(
                    'Send OTP',
                    style: Resources.styles.kTextStyle14B5(Colors.white),
                  ),
                ),
              ),
              if (showOtpField) ...[
                const SizedBox(height: 10),
                Center(
                  child: Pinput(
                    controller: _otpController,
                    length: 4,
                    keyboardType: TextInputType.number,
                    onCompleted: (pin) {
                      debugPrint('OTP Entered: $pin');
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Resources.colors.themeColor,
                  ),
                  child: Text(
                    'Reset Password',
                    style: Resources.styles.kTextStyle14B5(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
