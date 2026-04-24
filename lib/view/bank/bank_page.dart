import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthBloc _authData;

  @override
  void initState() {
    super.initState();
    _authData = context.read<AuthBloc>();
    _authData.add(AuthGetVendorProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions for responsiveness
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Add Bank Details",
          style: Resources.styles.kTextStyle16B(Resources.colors.blackColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter your bank details",
                  style: Resources.styles
                      .kTextStyle18B(Resources.colors.blackColor),
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextField(
                  controller: _accountHolderNameController,
                  hintText: 'Account Holder Name',
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                _buildTextField(
                  controller: _bankNameController,
                  hintText: 'Bank Name',
                  icon: Icons.account_balance,
                  keyboardType: TextInputType.text,
                ),
                _buildTextField(
                  controller: _accountNumberController,
                  hintText: 'Account Number',
                  icon: Icons.account_box,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _ifscCodeController,
                  hintText: 'IFSC Code',
                  icon: Icons.code,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.04),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    log("State My : $state");

                    if (state is AuthGetVendorSuccessState) {
                      final vendor = state.response;
                      _accountHolderNameController.text =
                          vendor.accountHolderName ?? '';
                      _bankNameController.text = vendor.bankName ?? '';
                      _accountNumberController.text =
                          vendor.accountNumber.toString();
                      _ifscCodeController.text = vendor.ifscCode ?? '';
                    }
                    if (state is ProfileUpdateSuccessState) {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
                      Utils.snackBar(" ${state.response['message']}", context);
                    }
                  },
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          BlocProvider.of<AuthBloc>(context)
                              .add(ProfileUpdateEvent(
                            formData: {
                              "accountHolderName":
                                  _accountHolderNameController.text,
                              "bankName": _bankNameController.text,
                              "accountNumber": _accountNumberController.text,
                              "ifscCode": _ifscCodeController.text.trim(),
                            },
                            files: [],
                          ));
                        } else {
                          Utils.snackBar(" all field are required}", context);
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
                            'Add Bank',
                            style: Resources.styles.kTextStyle16B(Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          fillColor: Colors.white12,
          prefixIcon: Icon(icon, color: Resources.colors.blackColor),
          filled: true,
          hintText: hintText,
          hintStyle: Resources.styles.kTextStyle14B5(Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Resources.colors.blackColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Resources.colors.blackColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
