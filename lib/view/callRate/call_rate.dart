import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';

class CallAndChatRate extends StatefulWidget {
  const CallAndChatRate({super.key});

  @override
  State<CallAndChatRate> createState() => _CallAndChatRateState();
}

class _CallAndChatRateState extends State<CallAndChatRate> {
  final _callRateController = TextEditingController();
  final _chatRateController = TextEditingController();
  final _videoCallRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetVendorDetailEvent());
  }

  @override
  void dispose() {
    _callRateController.dispose();
    _chatRateController.dispose();
    _videoCallRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Set Your Rates",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 15),

            /// 🔹 Input Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildField(
                    controller: _callRateController,
                    label: "Audio Call Rate",
                    icon: Icons.call,
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    controller: _chatRateController,
                    label: "Chat Rate",
                    icon: Icons.chat,
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    controller: _videoCallRateController,
                    label: "Video Call Rate",
                    icon: Icons.videocam,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Submit Button
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is ProfileUpdateSuccessState) {
                  Utils.snackBar("Updated Successfully", context);

                  /// Refresh latest data
                  context.read<HomeBloc>().add(GetVendorDetailEvent());
                }
              },
              builder: (context, state) {
                if (state is AuthLoadingState) {
                  return  Center(child: CircularProgressIndicator(
                    color: Resources.colors.themeColor,
                  ));
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _submit,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Resources.colors.themeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            /// 🔹 Current Rates
            const Text(
              "Current Rates",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VendorDetailSuccessState) {
                  final data = state.vendorDetail;

                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _rateRow("Audio Call", data.callRate),
                        const Divider(),
                        _rateRow("Chat", data.chatRate),
                        const Divider(),
                        _rateRow("Video Call", data.videoCallRate),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _callRateController.text =
                              "${data.callRate ?? ""}";
                              _chatRateController.text =
                              "${data.chatRate ?? ""}";
                              _videoCallRateController.text =
                              "${data.videoCallRate ?? ""}";
                            },
                          ),
                        )
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Input Field
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 10),
            Text("₹", style: TextStyle(fontSize: 16)),
            SizedBox(width: 5),
          ],
        ),
        suffixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 🔹 Rate Row
  Widget _rateRow(String title, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          "₹${value ?? 0}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  /// 🔹 Submit Logic
  void _submit() {
    if (_callRateController.text.isEmpty ||
        _chatRateController.text.isEmpty ||
        _videoCallRateController.text.isEmpty) {
      Utils.snackBar("Please enter all rates", context);
      return;
    }

    FirebaseMessaging.instance.getToken().then((token) {
      context.read<AuthBloc>().add(
        ProfileUpdateEvent(
          formData: {
            "callRate": _callRateController.text,
            "chatRate": _chatRateController.text,
            "videoCallRate": _videoCallRateController.text,
            "fcmToken": token
          },
          files: const [],
        ),
      );
    });
  }
}