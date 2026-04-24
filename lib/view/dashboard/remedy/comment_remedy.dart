import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/pref_service.dart';
import '../../../repository/repository.dart';
import '../../../resources/resources.dart';
import '../../../routes/routes_name.dart';
import '../../../services/notification_service.dart';

class CommentRemedy extends StatefulWidget {
  const CommentRemedy({
    super.key,
    // required this.type,
    required this.fcmToken,
    required this.id,
    this.userId,
  });
  // final String? type;
  final String? fcmToken;
  final String? id;
  final String? userId;
  @override
  State<CommentRemedy> createState() => _CommentRemedyState();
}

class _CommentRemedyState extends State<CommentRemedy> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _isLoading.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("fcm token Comment ${widget.userId}");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Remedy',
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: TextFormField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter your comment',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, loading, child) {
              return ElevatedButton(
                onPressed: loading ? null : _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Resources.colors.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: Resources.styles.kTextStyle16B(
                          Resources.colors.whiteColor,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    _isLoading.value = true;
    var vendorId = PrefService().getRegId();
    var userId = widget.userId.toString();

    // First check if the text is empty
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a comment')));
      _isLoading.value = false;
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Send notification
      await NotificationService.sendNotification(
        widget.fcmToken ?? "",
         "",
        _controller.text.trim(),
        {"message": _controller.text.trim()},
      );

      // Only proceed with assignRemedy if message is not empty
      if (_controller.text.trim().isNotEmpty) {
        await Repository().assignRemedy({
          "userId": userId,
          "vendorId": "$vendorId",
          "type": "",
          "message": _controller.text.trim(),
        });

        await Repository().updateAssignRemedy(true, widget.id.toString());
      }

      // Navigate back
      GoRouter.of(
        context,
      ).pushReplacementNamed(RoutesName.navigationScreen, extra: 0);

      // Clear the input
      _controller.clear();
      log("fcm commennnntt ${widget.fcmToken}");
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit comment: $e')));
    } finally {
      _isLoading.value = false;
    }
  }
}
