import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../repository/repository.dart';
import '../../resources/resources.dart';

class WithdrawRequest extends StatefulWidget {
  const WithdrawRequest({super.key});

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  final amountController = TextEditingController();
  Set<String> points = {};
  Set<String> pointsData = {
    '5000',
    '10000',
    '20000',
    '50000',
    '80000',
    '100000',
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Withdraw Request",
          style: Resources.styles.kTextStyle16B(Resources.colors.blackColor),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          String amountText = amountController.text.trim();
          int? amount = int.tryParse(amountText);

          if (amount == null || amount < 5000) {
            Fluttertoast.showToast(
                msg: "Minimum withdrawal amount is 5000 Rs.",
                backgroundColor: Resources.colors.buttonColor);
          } else {
            Repository().getVendorProfile().then((value) {
              log("value:${value!.walletAmount.toString()}");
              if (value.walletAmount >= amount) {
                Repository()
                    .withdrawAmount(
                  amountText,
                )
                    .then((value) {
                  amountController.clear();
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                      msg: "${value["message"]}",
                      backgroundColor: Resources.colors.buttonColor);
                  context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
                }).catchError((e) {
                  Fluttertoast.showToast(msg: "$e");
                });
              } else {
                Fluttertoast.showToast(
                    msg: "Insufficient Balance in Your Account.",
                    backgroundColor: Resources.colors.buttonColor);
              }
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Resources.colors.buttonColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Submit",
            style: Resources.styles.kTextStyle16B(Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Resources.dimens.height(context) * 0.25,
              child: GridView.builder(
                itemCount: pointsData.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 0.2,
                    childAspectRatio: 1.2),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      points.add(pointsData.elementAt(index));
                      setState(() {});
                      amountController.text = pointsData.elementAt(index);
                    },
                    child: Container(
                      height: Resources.dimens.height(context) * 0.06,
                      width: Resources.dimens.width(context) * 0.28,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: Resources.styles
                          .kBoxDecoration(Resources.colors.buttonColor),
                      child: Center(
                        child: Text(
                          pointsData.elementAt(index),
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Enter Amount",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
