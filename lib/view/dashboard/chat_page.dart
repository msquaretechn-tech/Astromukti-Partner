
import 'dart:async';
import 'dart:developer';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:astro_mukti/repository/chat_log_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/chat_timer/chat_timer_bloc.dart';
import '../../bloc/count_down_timer.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../data/local/pref_service.dart';

import '../../main.dart';
import '../../model/get_vendor.dart';
import '../../model/vender_detail_model.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../../resources/string.dart';
import '../../routes/routes_name.dart';
import '../../services/notification_service.dart';
import '../../utils/global_player.dart';
import '../../utils/sound_recorder.dart';
import '../../utils/utils.dart';
import '../../utils/voice_message.dart';
import '../kundli/kundli.dart';
import '../widgets/chat_ringtone.dart';
import 'image_zoomer.dart';

// final ChatRingTone ringtonePlayer = ChatRingTone();
class ChatPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final String chatId;
  const ChatPage({super.key, required this.userDetails, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  String _currentAppState = "foreground";
  String myLog = "Private121Chat myLog : ";
  ChatClient client = ChatClient.getInstance;
  final TextEditingController _controller = TextEditingController();
  VendorDetailsModel? vendorDetailsModel;

  // New fields for reply feature
  Map<String, dynamic>? _replyingMessage;
  bool _welcomeMessageSent = false;
  late String dob;
  late String dobTime;
  late String birthPlace;
  late String gender;
  late String name;
  late String walletAmountme;
  late bool isNewUser;
  bool _isConnecting = true;
  StreamSubscription? _chatTimerSub;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ChatLoggerRepo().init();
    PrefService.setBool('chat_ringing', false);
    ChatRingTone().stopRingtone();
    NotificationService.dismissNotifications();
    dob = widget.userDetails["dob"] ?? "";
    walletAmountme = widget.userDetails["walletAmount"].toString();
    dobTime = widget.userDetails["dobTime"] ?? "";
    birthPlace = widget.userDetails["birthPlace"] ?? "";
    gender = widget.userDetails["gender"] ?? "";
    var raw = widget.userDetails["isNewUser"];
    log("why coming : $walletAmountme");
    isNewUser = raw == true || raw == "true";

    // ✅ Listen for ChatEndState immediately — before any async sign-in completes.
    // This ensures we don't miss FCM-triggered ChatEndState on second chat sessions.
    _chatTimerSub = context.read<ChatTimerBloc>().stream.listen((state) {
      if (state is ChatEndState) {
        if (state.userId == widget.userDetails["_id"]) {
          log("[ChatPage] ChatEndState received for current user: ${state.userId} — exiting.");
          _cleanupAndExit();
        }
      }
    });

    // 🚀 NEW: Log that chat was picked/opened
    _logChatEvent(
      eventType: "CHAT_PICKED",
      message: "Chat joined/picked from notification or tab",
    );

    _initializeChat();
  }

  // it clean everything
  // void _cleanupAndExit() {
  //   if (_isExiting) return;
  //   _isExiting = true;
  //   _countdownTimer?.cancel();
  //   _countdownTimer = null;
  //   if (mounted) {
  //     context.read<CountDownTimerBloc>().add(StopTimer());
  //     log(" Resetting notifications for user: ${widget.userDetails["_id"]}");
  //
  //     context.read<NotificationBloc>().add(
  //       NotificationResetEvent("${widget.userDetails["_id"]}"),
  //     );
  //     _signOut();
  //     (navigationKey.currentContext ?? context).goNamed(
  //       RoutesName.navigationScreen,
  //       extra: 0,
  //     );
  //     log(" Step what happen : ");
  //     Fluttertoast.showToast(
  //       msg: "Chat session ended.",
  //       backgroundColor: Colors.red,
  //     );
  //     NotificationService.dismissNotifications();
  //     log(" Step->2 what happen : ");
  //   } else {
  //     log("Widget not mounted, cleanup skipped");
  //   }
  // }
  void _cleanupAndExit() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted) {
      context.read<CountDownTimerBloc>().add(StopTimer());
      log(" Resetting notifications for user: ${widget.userDetails["_id"]}");

      context.read<NotificationBloc>().add(
        NotificationResetEvent("${widget.userDetails["_id"]}"),
      );
      _signOut();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      (navigationKey.currentContext ?? context).goNamed(RoutesName.navigationScreen, extra: 0);

      Fluttertoast.showToast(
        msg: "Chat session ended.",
        backgroundColor: Colors.red,
      );
      NotificationService.dismissNotifications();
    } else {
      log("Widget not mounted, cleanup skipped");
    }
  }
  void _sendEndChatCMD() async {

    try {
      // 1. Send invisible CMD signal via Agora
      var cmdMsg = ChatMessage.createCmdSendMessage(
        targetId: _remoteChatId!,
        action: "END_CHAT_SESSION",
      );

      await client.chatManager.sendMessage(cmdMsg);
    } catch (e) {
      log(" Failed to send CMD message: $e");
    }

    try {
      log(" Calling backend endChatSession API for chatId: ${widget.chatId}");

      // 2. Notify backend to mark session closed
      await _repository.endChatSession(widget.chatId);

    } catch (e) {
      log("❌ endChatSession API failed: $e");
    }

    _logChatEvent(
      eventType: "CHAT_ENDED_BY_ASTROLOGER",
      message: "Astrologer manually ended the chat session",
    );

    try {


      // 3. Backup push notification
      await NotificationService.sendNotification(
        widget.userDetails["fcmToken"],
        "Chat Ended",
        "Astrologer has ended the chat",
        {'userId': _localUserId},
      );

      if (kDebugMode) {
        print("Fallback notification sent");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Notification send failed: $e");
      }
    }
  }

  void _startChatCMD() async {

    try {
      // 1. Send invisible CMD signal via Agora
      var cmdMsg = ChatMessage.createCmdSendMessage(
        targetId: _remoteChatId!,
        action: "START_CHAT_SESSION",
      );

      await client.chatManager.sendMessage(cmdMsg);
    } catch (e) {
      log(" Failed to send CMD message: $e");
    }


    log(" Calling backend endChatSession API for chatId: ${widget.chatId}");

    // // 2. Notify backend to mark session closed
    // await _repository.endChatSession(widget.chatId)

  }
  // void _sendEndChatCMD() async {
  //   try {
  //     // 1. Send invisible CMD signal via Agora
  //     var cmdMsg = ChatMessage.createCmdSendMessage(
  //       targetId: _remoteChatId!,
  //       action: "END_CHAT_SESSION",
  //     );
  //
  //     await client.chatManager.sendMessage(cmdMsg);
  //   } catch (e) {
  //     log(" Failed to send CMD message: $e");
  //   }
  //
  //   try {
  //     log(" Calling backend endChatSession API for chatId: ${widget.chatId}");
  //
  //     // 2. Notify backend to mark session closed
  //     await _repository.endChatSession(widget.chatId);
  //   } catch (e) {
  //     log("❌ endChatSession API failed: $e");
  //   }
  //
  //   _logChatEvent(
  //     eventType: "CHAT_ENDED_BY_ASTROLOGER",
  //     message: "Astrologer manually ended the chat session",
  //   );
  //
  //   try {
  //     // 3. Backup push notification
  //     await NotificationService.sendNotification(
  //       widget.userDetails["fcmToken"],
  //       "Chat Ended",
  //       "Astrologer has ended the chat",
  //       {'userId': _localUserId},
  //     );
  //
  //     log("✅ Fallback notification sent");
  //   } catch (e) {
  //     log("❌ Notification send failed: $e");
  //   }
  // }
  //
  // void _startChatCMD() async {
  //   try {
  //     // 1. Send invisible CMD signal via Agora
  //     var cmdMsg = ChatMessage.createCmdSendMessage(
  //       targetId: _remoteChatId!,
  //       action: "START_CHAT_SESSION",
  //     );
  //
  //     await client.chatManager.sendMessage(cmdMsg);
  //   } catch (e) {
  //     log(" Failed to send CMD message: $e");
  //   }
  //
  //   log(" Calling backend endChatSession API for chatId: ${widget.chatId}");
  //
  //   // // 2. Notify backend to mark session closed
  //   // await _repository.endChatSession(widget.chatId)
  // }

  void _checkAndSendWelcomeMessage() async {
    // 1. Double check all conditions to prevent duplicates
    if (_welcomeMessageSent) return;
    if (profile == null) return;
    if (!mounted) return;

    bool wasSentPersistent =
        PrefService.getBool('welcome_sent_${widget.chatId}') ?? false;
    if (wasSentPersistent) {
      setState(() {
        _welcomeMessageSent = true;
      });
      return;
    }

    // 2. Mark as sent IMMEDIATELY to block other concurrent triggers
    setState(() {
      _welcomeMessageSent = true;
    });
    PrefService.setBool('welcome_sent_${widget.chatId}', true);

    // 3. Send the message
    _messageContent =
        "Hii, I am ${profile!.name} ${profile!.lastName} welcome you to Astro Mukti. How Can I help you?";
    _startChatCMD();
    if (_messageContent!.isNotEmpty) {
      await _sendMessage();
      if (mounted) {
        _controller.clear();
      }
    }
  }

  Future<void> _initializeChat() async {

    await Repository().updateProfile({
      "isChatAvailable": false,
      "chatGroupId": widget.userDetails["_id"],
      "isNowAvailable": false,
    }, []);

    // 2. Fetch necessary data sequentially to ensure state is ready before listeners fire
    await Future.wait([_fetchVendorDetails(), _fetchPreviousMessages()]);

    // 3. Add listeners
    _addChatListener();

    // 4. Parallelize remaining initial fetches
    await Future.wait([_initSDK(), _fetchCustomerDetails()]);

    if (mounted) {
      context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
      setState(() {
        _isConnecting = false;
      });
    }
  }

  // instance of voice recorder
  final recorder = SoundRecorderManager();
  bool isRecording = false;

  // user details get
  Widget buildUserDetailsMessage() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(''' DOB: $dob
Time: $dobTime
 Place: $birthPlace
 Gender: $gender
''', style: const TextStyle(fontSize: 16, height: 1.5)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _currentAppState = "background";
      _logChatEvent(eventType: "BACKGROUND", message: "User minimized the app");
    } else if (state == AppLifecycleState.resumed) {
      _currentAppState = "foreground";
      _logChatEvent(eventType: "FOREGROUND", message: "User returned to app");
      if (!isConnected) {
        _signIn();
      }
    }
  }

  Future<void> _logChatEvent({
    required String eventType,
    required String message,
    int retryCount = 0,
  }) async {
    ChatLoggerRepo().logEvent(
      userId: _localUserId.isNotEmpty ? _localUserId : PrefService().getRegId(),
      vendorId: widget.userDetails["_id"] ?? "unknown",
      sessionId: widget.chatId,
      eventType: eventType,
      message: message,
      appState: _currentAppState,
      isConnected: isConnected,
      retryCount: retryCount,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    client.chatManager.removeEventHandler(
      Resources.strings.chatHandlerUniqueId,
    );
    client.removeConnectionEventHandler(Resources.strings.chatHandlerUniqueId);
    client.chatManager.removeMessageEvent(
      Resources.strings.chatHandlerUniqueId,
    );
    _countdownTimer?.cancel();
    _chatTimerSub?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    if (kDebugMode) {
      print("deactivate ${context.read<ChatTimerBloc>()}");
    }
    super.deactivate();
  }

  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  // AGORA CHAT SDK
  String _localUserId = "";
  bool isConnected = false;
  String? _messageContent, _remoteChatId = "";
  final List<Map<String, dynamic>> _chatList = [];
  Map<String, dynamic>? _customerDetailsFromApi;
  bool _isSigningIn = false;
  final int _sessionStartTime = DateTime.now().millisecondsSinceEpoch;

  Future<void> _initSDK() async {
    if (kDebugMode) {
      print("$myLog _initSDK");
    }
    ChatOptions options = ChatOptions(
      appKey: AgoraConfig.appKey,
      autoLogin: true,
    );

    await client.init(options);
    await client.startCallback();

    // Check connection safely after initialization
    try {
      bool alreadyConnected = await client.isConnected();
      if (alreadyConnected && mounted) {
        setState(() {
          isConnected = true;
        });
      }
    } catch (e) {
      _logChatEvent(
        eventType: "SDK_ERROR",
        message: "Error checking initial connection: $e",
      );
      if (kDebugMode) {
        print("Error checking initial connection: $e");
      }
    }

    _localUserId = PrefService().getRegId();
    _remoteChatId = widget.userDetails["_id"];

    await _signIn();
  }

  Future<void> _signIn() async {
    if (_isSigningIn) return;
    _isSigningIn = true;

    if (kDebugMode) {
      print("_localUserId $_localUserId");
    }
    if (kDebugMode) {
      print("_remoteChatId $_remoteChatId");
    }

    try {
      bool isLoggedIn = await client.isLoginBefore();
      bool loginSuccess = isLoggedIn;

      if (!isLoggedIn) {
        var agoraToken = await Repository().generateChatToken(_localUserId);
        if (kDebugMode) {
          print("agoraToken:$agoraToken");
        }

        int retryCount = 0;

        while (retryCount < 3) {
          try {
            await client.loginWithToken(_localUserId, agoraToken['userToken']);

            if (kDebugMode) {
              print("$myLog login succeed, userId: $_localUserId");
            }
            loginSuccess = true;
            break;
          } on ChatError catch (e) {
            if (kDebugMode) {
              print(
                "$myLog login failed (attempt ${retryCount + 1}), code: ${e.code}",
              );
            }

            if (e.code == 204) {
              retryCount++;

              _logChatEvent(
                eventType: "LOGIN_RETRY",
                message:
                    "Agora user not found (204), retrying in 3s... (Attempt $retryCount)",
                retryCount: retryCount,
              );

              //  refresh token before last attempt
              if (retryCount == 2) {
                agoraToken = await Repository().generateChatToken(_localUserId);
                if (kDebugMode) {
                  print("$myLog Token refreshed");
                }
              }

              await Future.delayed(const Duration(seconds: 3));
            } else if (e.code == 200) {
              // ✅ already logged in (IMPORTANT FIX)
              if (kDebugMode) {
                print("$myLog Already logged in");
              }
              loginSuccess = true;
              break;
            } else {
              rethrow;
            }
          }
        }

        // ❌ stop if login failed
        if (!loginSuccess) {
          _logChatEvent(
            eventType: "LOGIN_FAILED",
            message: "Login failed after retries",
          );
          throw Exception("Agora login failed after retries");
        }
      }

      // ✅ ensure login success before continuing
      if (!loginSuccess) return;

      // 2. Fetch profile
      if (profile == null) {
        await _fetchVendorDetails();
      }

      // 3. Setup listeners (chatTimerSub already set in initState)
      if (!mounted) return;

      dob = "${widget.userDetails["dob"]}";
      dobTime = "${widget.userDetails["dobTime"]}";
      birthPlace = "${widget.userDetails["birthPlace"]}";
      name = "${widget.userDetails["name"]} ${widget.userDetails["lastName"]}";
      gender = "${widget.userDetails["gender"]}";

      log(
        "Kundli Data: dob=$dob, dobTime=$dobTime, birthPlace=$birthPlace, name=$name, gender=$gender",
      );

      // 4. Welcome message
      _checkAndSendWelcomeMessage();

      _logChatEvent(
        eventType: "LOGIN_SUCCESS",
        message: "Token fetched and logged in to Agora",
      );
    } on ChatError catch (e) {
      //  only handle real errors here now
      if (e.code == 200) {
        if (kDebugMode) {
          print("$myLog Already logged in (outer catch)");
        }

        if (mounted) {
          setState(() {
            isConnected = true;
          });
        }
        return;
      }

      _logChatEvent(
        eventType: "LOGIN_FAILED",
        message: "ChatError: ${e.description}",
      );

      if (kDebugMode) {
        print("Error in _signIn: $e");
      }

      if (mounted) {
        Utils.snackBar("Error in _signIn: $e", context);
      }
    } catch (e) {
      _logChatEvent(eventType: "LOGIN_FAILED", message: e.toString());

      if (kDebugMode) {
        print("Error in _signIn: $e");
      }

      if (mounted) {
        Utils.snackBar("Error in _signIn: $e", context);
      }
    } finally {
      _isSigningIn = false;
    }
  }
  Future<void> _signOut() async {
    try {
      // 1. Update profile status first
      await Repository().updateProfile({
        "isChatAvailable": true,
        "isAudioCallAvailable": true,
        "isVideoCallAvailable": true,
        "isNowAvailable": true,
        "isOnline": true,
      }, []);

      // Refresh local profile status
      if (mounted) {
        context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
      }

      // 2. Attempt Agora logout
      try {
        // unbindToken: true ensures push notifications stop for this device
        await client.logout(true);
        if (kDebugMode) {
          print("Sign-out from Agora succeeded.");
        }
      } on ChatError catch (e) {
        if (kDebugMode) {
          print(
            "Sign-out from Agora failed: code: ${e.code}, description: ${e.description}",
          );
        }

      }

      // 3. Reset Local State & Blocs

      final targetContext = navigationKey.currentContext ?? context;
      if (targetContext.mounted) {
        targetContext.read<NotificationBloc>().add(
          NotificationResetEvent("${widget.userDetails["_id"]}"),
        );
        targetContext.read<ChatTimerBloc>().add(
          ChatEndEvent(userId: widget.userDetails["_id"]),
        );
        PrefService.remove('welcome_sent_${widget.chatId}');
      }

      if (kDebugMode) {
        print("Sign-out process completed.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("An unexpected error occurred during sign-out: $e");
      }
      if (mounted) {
        Utils.snackBar("Sign-out error: $e", context);
      }
    } finally {
      _logChatEvent(
        eventType: "CHAT_ENDED",
        message: "Chat session ended and user signed out",
      );
      NotificationService.dismissNotifications();
    }
  }
  // Future<void> _signOut() async {
  //   try {
  //     // 1. Update profile status first
  //     await Repository().updateProfile({
  //       "isChatAvailable": true,
  //       "isAudioCallAvailable": true,
  //       "isVideoCallAvailable": true,
  //       "isNowAvailable": true,
  //       "isOnline": true,
  //     }, []);
  //
  //     // Refresh local profile status
  //     if (mounted) {
  //       context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
  //     }
  //
  //     // 2. Attempt Agora logout
  //     try {
  //       // unbindToken: true ensures push notifications stop for this device
  //       await client.logout(true);
  //       if (kDebugMode) {
  //         print("Sign-out from Agora succeeded.");
  //       }
  //     } on ChatError catch (e) {
  //       if (kDebugMode) {
  //         print(
  //           "Sign-out from Agora failed: code: ${e.code}, description: ${e.description}",
  //         );
  //       }
  //       // Proceeding with local cleanup anyway
  //     }
  //
  //     // 3. Reset Local State & Blocs
  //     // Use navigationKey context if local context might be unmounted (e.g. after Navigator.pop)
  //     final targetContext = navigationKey.currentContext ?? context;
  //     if (targetContext.mounted) {
  //       targetContext.read<NotificationBloc>().add(
  //         NotificationResetEvent("${widget.userDetails["_id"]}"),
  //       );
  //       targetContext.read<ChatTimerBloc>().add(
  //         ChatEndEvent(userId: widget.userDetails["_id"]),
  //       );
  //       PrefService.remove('welcome_sent_${widget.chatId}');
  //     }
  //
  //     if (kDebugMode) {
  //       print("Sign-out process completed.");
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("An unexpected error occurred during sign-out: $e");
  //     }
  //     if (mounted) {
  //       Utils.snackBar("Sign-out error: $e", context);
  //     }
  //   } finally {
  //     _logChatEvent(
  //       eventType: "CHAT_ENDED",
  //       message: "Chat session ended and user signed out",
  //     );
  //     NotificationService.dismissNotifications();
  //   }
  // }

  Future<void> clearAllConversations() async {
    try {
      final conversations = await ChatClient.getInstance.chatManager
          .getConversationsFromServer();
      for (var convo in conversations) {
        await ChatClient.getInstance.chatManager.deleteConversation(convo.id);
      }
      if (kDebugMode) {
        print('All chats cleared!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all chats: $e');
      }
    }
  }

  Map<String, dynamic>? previousMessages;
  Future<void> _fetchPreviousMessages() async {
    if (!mounted) return;
    vendorDetailsModel = await Repository().getVendorDetail();
    previousMessages = await Repository().getTotalMessages(widget.chatId);

    if (kDebugMode) {
      print("$myLog Previous messages : $previousMessages");
    }

    // Clear list to avoid duplicates when returning to page
    _chatList.clear();

    // Check if welcome message was already sent for this chatId
    bool wasSent =
        PrefService.getBool('welcome_sent_${widget.chatId}') ?? false;
    if (wasSent) {
      _welcomeMessageSent = true;
    }

    previousMessages!["data"].reversed.forEach((element) {
      _chatList.add({
        "content": element["content"],
        "time": Utils.formatMongoTime(element['createdAt']),
        "sender": {"_id": element['sender']},
      });
    });
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      final String? userId = widget.userDetails["_id"];
      if (userId != null) {
        final profileData = await Repository().getUserProfile(userId);
        if (mounted) {
          setState(() {
            _customerDetailsFromApi = profileData.toJson();
          });
          if (kDebugMode) {
            print(
              "$myLog Customer details fetched from API: $_customerDetailsFromApi",
            );
          }

          // If we are already connected, try to start the timer with this new data
          if (isConnected &&
              profile != null &&
              (_countdownTimer == null || !_countdownTimer!.isActive)) {
            _startCountdownTimer();
          }
        }
      }
    } catch (e) {
      log("Error fetching customer details: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (kDebugMode) {
      print("ccccccccccccccccccccccccccc");
    }
    if (_remoteChatId == null || _messageContent == null) {
      _logChatEvent(
        eventType: "SYNC_FAILED",
        message: "Cannot send message: Remote ID or content missing",
      );
      if (kDebugMode) {
        print(
          "$myLog annot send message: Remote ID, content, or connection issue",
        );
      }
      return;
    }
    // setState(() {
    //   _isLoading = true;
    // });

    try {
      String finalMessage = _messageContent!;
      // If replying, prepend the reply info
      if (_replyingMessage != null &&
          !_replyingMessage!['content'].toString().contains("Replied to: ")) {
        finalMessage =
            "Replied to: ${_replyingMessage!['content']}\n$finalMessage";
      } else if (_replyingMessage != null) {
        finalMessage = _replyingMessage!['content'] + "\n$finalMessage";
      }

      var msg = ChatMessage.createTxtSendMessage(
        targetId: _remoteChatId!,
        content: finalMessage,
      );
      if (kDebugMode) {
        print("$myLog sendMessage : $msg");
      }
      await client.chatManager.sendMessage(msg);

      // Clear reply state after sending
      if (mounted) {
        setState(() {
          _replyingMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logChatEvent(
        eventType: "SYNC_FAILED",
        message: "Local Exception sending message: $e",
      );
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
  }

  void _addChatListener() {
    if (kDebugMode) {
      print("_addChatListener");
    }
    client.chatManager.addEventHandler(
      Resources.strings.chatHandlerUniqueId,
      ChatEventHandler(
        onMessagesReceived: onMessagesReceived,
        onCmdMessagesReceived: onMessagesReceived,
      ),
    );

    client.addConnectionEventHandler(
      Resources.strings.chatHandlerUniqueId,
      ConnectionEventHandler(
        onConnected: () {
          if (kDebugMode) {
            print("$myLog ConnectionEventHandler onConnected");
          }
          _logChatEvent(
            eventType: "CONNECTED",
            message: "Socket connected successfully",
          );
          if (mounted) {
            setState(() {
              isConnected = true;
            });

            // Start timer when connected
            if (profile != null &&
                (_countdownTimer == null || !_countdownTimer!.isActive)) {
              _startCountdownTimer();
            }

            // Send welcome message if needed when connected
            _checkAndSendWelcomeMessage();
          }
        },
        onDisconnected: () {
          if (kDebugMode) {
            print("$myLog ConnectionEventHandler onDisconnected : ");
          }
          _logChatEvent(
            eventType: "DISCONNECTED",
            message: "Agora connection dropped",
          );
          if (mounted) {
            context.read<ChatTimerBloc>().add(
              ChatEndEvent(userId: widget.userDetails["_id"]),
            );
            setState(() {
              isConnected = false;
            });
          }
        },
      ),
    );

    client.chatManager.addMessageEvent(
      Resources.strings.chatHandlerUniqueId,
      ChatMessageEvent(
        onSuccess: (msgId, msg) async {
          if (kDebugMode) {
            print("$myLog send message onSuccess : $msg");
          }
          _logChatEvent(
            eventType: "SYNC_SUCCESS",
            message: "Message sent successfully: $msgId",
          );
          if (!mounted) return;

          if (msg.body is ChatImageMessageBody) {
            ChatImageMessageBody body = msg.body as ChatImageMessageBody;
            context.read<ChatTimerBloc>().add(ChatStartEvent());
            _addToChatList({
              "content": body.remotePath,
              "time": _timeString,
              "sender": vendorDetailsModel!.toJson(),
            });

            await Repository().addNewMessage(widget.chatId, {
              "content": body.remotePath,
            });
          } else if (msg.body is ChatTextMessageBody) {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            context.read<ChatTimerBloc>().add(ChatStartEvent());
            _addToChatList({
              "content": body.content,
              "time": _timeString,
              "sender": vendorDetailsModel!.toJson(),
            });

            if (kDebugMode) {
              print(
                "sendWelcomeMessage : ${body.content.contains("How Can I help you?")}",
              );
            }
            if (body.content.contains('How Can I help you?')) {
              log("Welcome message detected, saving to history...");
              // Don't return here, allow it to be saved to Repository().addNewMessage
            }
            // send chat ended message when chat ended
            // if (body.content == "Chat ended.") {
            //   return;
            // }

            await Repository().addNewMessage(widget.chatId, {
              "content": body.content,
            });
          }
        },
        onError: (msgId, msg, error) {
          _logChatEvent(
            eventType: "SYNC_FAILED",
            message: "Message $msgId failed: $error",
          );
          if (kDebugMode) {
            print("$myLog send message onError - Message ID: $msgId");
          }
          if (kDebugMode) {
            print("$myLog Failed message: ${msg.toString()}");
          }
          if (kDebugMode) {
            print("$myLog Error details: $error");
          }

          if (error is PlatformException) {
            if (kDebugMode) {
              print(
                "$myLog PlatformException details: ${error.code}, ${error.description}",
              );
            }
          }

          // Retry logic (if needed)
          if (msg.body is ChatTextMessageBody &&
              (msg.body as ChatTextMessageBody).content.contains(
                "How Can I help you?",
              )) {
            Future.delayed(const Duration(seconds: 2), () {
              _sendMessage();
            });
          }
        },
      ),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      if (kDebugMode) {
        print("$myLog onMessagesReceived : $msg");
      }
      if (mounted) {
        setState(() {
          isConnected = true;
        });
      }
      if (msg.serverTime < _sessionStartTime) {
        if (kDebugMode) {
          print(
            "$myLog Ignoring old message: ${msg.msgId} (sent at ${msg.serverTime}, session started at $_sessionStartTime)",
          );
        }
        continue;
      }

      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;

            if (msg.to == PrefService().getRegId()) {
              // Extract remaining minutes if this is a "Joined" message
              if (body.content.contains("CHAT_JOINED_BY")) {
                if (kDebugMode) {
                  print("$myLog Found Join message, parsing minutes...");
                }
                try {
                  final RegExp regExp = RegExp(
                    r"totalRemainingMinute:\s*(\d+\.?\d*)",
                  );
                  final match = regExp.firstMatch(body.content);
                  if (match != null) {
                    final String? minStr = match.group(1);
                    if (minStr != null) {
                      final double minutes = double.tryParse(minStr) ?? 0;
                      if (kDebugMode) {
                        print(
                          "$myLog Extracted minutes from message: $minutes",
                        );
                      }
                      if (minutes > 0) {
                        _startCountdownTimer(externalMinutes: minutes);
                      }
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("$myLog Error parsing minutes from message: $e");
                  }
                }
              }

              if (msg.from == widget.userDetails["_id"]) {
                _addToChatList({
                  "content": body.content,
                  "time": _timeString,
                  "sender": widget.userDetails,
                });
              }
              // if (body.content.contains("Chat ended")) {
              //   log("bodyyy:$body");
              //   _signOut(); // Ensure status is updated to available
              //   if (mounted) {
              //     context.read<NotificationBloc>().add(
              //       NotificationResetEvent("${widget.userDetails["_id"]}"),
              //     );
              //     Navigator.pop(context);
              //   }
              //   return;
              // }
            } else {
              if (kDebugMode) {
                print("Nothing ");
              }
            }
          }
        case MessageType.IMAGE:
          {
            ChatImageMessageBody body = msg.body as ChatImageMessageBody;
            if (msg.to == PrefService().getRegId()) {
              if (msg.from == widget.userDetails["_id"]) {
                _addToChatList({
                  "content": body.remotePath,
                  "time": _timeString,
                  "sender": widget.userDetails,
                });
              }
            }
          }

          break;
        case MessageType.CMD:
          {
            ChatCmdMessageBody body = msg.body as ChatCmdMessageBody;
            log("ffff :$body");
            if (body.action == "END_CHAT_SESSION") {
              _cleanupAndExit();
              if (kDebugMode) {
                print("Message Endedddd ");
              }
            }
          }

          if (kDebugMode) {
            print("Message Ended or not");
          }
          break;
        default:
          break;
      }
    }
  }

  void _addToChatList(Map<String, dynamic> mData) {
    if (kDebugMode) {
      print("$myLog _addToChatList : $mData");
    }

    if (mounted) {
      setState(() {
        _chatList.add(mData);
      });

      // Use postFrameCallback to scroll after the list is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String get _timeString {
    return DateFormat.jm().format(DateTime.now());
  }

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _startCountdownTimer({double? externalMinutes}) {
    // 1. Check if the CountDownTimerBloc is already running (e.g. from a previous visit to this screen)
    final timerState = context.read<CountDownTimerBloc>().state;

    if (timerState.isRunning &&
        timerState.duration > 0 &&
        externalMinutes == null) {
      if (mounted) {
        setState(() {
          _remainingSeconds = timerState.duration;
        });
      }
      if (kDebugMode) {
        print(
          "Restoring timer from CountDownTimerBloc: $_remainingSeconds seconds",
        );
      }
    } else {
      double talkMinutes = 0;
      double wallet = 0;
      double rate = 1;

      if (externalMinutes != null) {
        talkMinutes = externalMinutes;
        if (kDebugMode) {
          print("Using minutes from joined message: $talkMinutes minutes");
        }
      } else if (widget.userDetails.containsKey("totalRemainingMinute") &&
          widget.userDetails["totalRemainingMinute"] != null) {
        talkMinutes =
            double.tryParse(
              widget.userDetails["totalRemainingMinute"].toString(),
            ) ??
            0;
        if (kDebugMode) {
          print(
            "Using totalRemainingMinute from notification: $talkMinutes minutes",
          );
        }
      } else {
        // Use API data if available, otherwise fallback to widget data
        final Map<String, dynamic> details =
            _customerDetailsFromApi ?? widget.userDetails;
        final dynamic walletData = details["walletAmount"];
        final dynamic rawRate = profile?.chatRate;

        // Parse walletAmount
        if (walletData is num) {
          wallet = walletData.toDouble();
        } else if (walletData is String) {
          wallet = double.tryParse(walletData) ?? 0;
        }

        // Parse chatRate
        if (rawRate is num) {
          rate = rawRate.toDouble();
        } else if (rawRate is String) {
          rate = double.tryParse(rawRate) ?? 1;
        }

        if (rate <= 0) rate = 1;
        talkMinutes = wallet / rate;
        if (kDebugMode) {
          print(
            "Talk time allowed (calculated from wallet): $talkMinutes minutes",
          );
        }
      }

      if (mounted) {
        setState(() {
          _remainingSeconds = (talkMinutes * 60).round();
        });
      }

      // Start the Bloc timer for persistence
      context.read<CountDownTimerBloc>().add(StartTimer(_remainingSeconds));
    }

    if (_remainingSeconds <= 0) {
      if (kDebugMode) {
        print("Countdown not started: insufficient balance.");
      }
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (kDebugMode) {
          print("Time over. Ending session.");
        }
        _cleanupAndExit();
        if (mounted) {
          context.read<NotificationBloc>().add(
            NotificationResetEvent("${widget.userDetails["_id"]}"),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  VendorProfileModel? profile;
  late final Repository _repository = Repository();

  Future<void> _fetchVendorDetails() async {
    try {
      profile = await _repository.getVendorProfile();
      if (mounted) {
        setState(() {});

        // If we are already connected, try to start the timer with this new data
        if (isConnected &&
            (_countdownTimer == null || !_countdownTimer!.isActive)) {
          if (kDebugMode) {
            print("$myLog Starting timer now that vendor profile is fetched.");
          }
          _startCountdownTimer();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching vendor details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _isLoading) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    if (kDebugMode) {
      print(" TimingProblem : ${_formatDuration(_remainingSeconds)}");
    }

    return BlocListener<CountDownTimerBloc, CountDownTimerState>(
      listener: (context, state) {
        if (state.isRunning && mounted) {
          setState(() {
            _remainingSeconds = state.duration;
          });

          if (state.duration <= 0) {
            if (kDebugMode) {
              print("Time over from Bloc. Ending session.");
            }
            _signOut();
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    widget.userDetails["avatar"] != null &&
                            widget.userDetails["avatar"].toString().isNotEmpty
                        ? "${AppUrl.baseUrl}/images/${widget.userDetails["avatar"]}"
                        : "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.userDetails["name"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 5),
                          isNewUser
                              ? Text(
                                  "New User",
                                  style: Resources.styles.kTextStyle14(
                                    Colors.black,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      _remainingSeconds > 0
                          ? Text(
                              _formatDuration(_remainingSeconds),
                              style: Resources.styles.kTextStyle12(Colors.black),
                            )
                          : Row(
                              children: [
                                const SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Connecting...",
                                  style: Resources.styles.kTextStyle10(
                                    Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
        
            actions: [
              InkWell(
                onTap: () async {
                  EasyLoading.show(
                    status: 'loading...',
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.clear,
                  );
                  try {
                    // Fetch latitude and longitude from the city name (dop)
                    List<Location> locations = await locationFromAddress(
                      birthPlace,
                    );
                    if (locations.isNotEmpty) {
                      double latitude = locations[0].latitude;
                      double longitude = locations[0].longitude;
                      log("Latitude: $latitude, Longitude: $longitude");
                      EasyLoading.dismiss();
                      // Navigate to the next screen with the latitude and longitude
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ZodiacSign(
                            dob: dob,
                            dot: dobTime,
                            dop: birthPlace,
                            name: name.toString(),
                            gender: gender,
                            latitude: latitude,
                            longitude: longitude,
                          ),
                        ),
                      );
                    } else {
                      EasyLoading.dismiss();
                      log("No locations found for the given address.");
                    }
                  } catch (e) {
                    EasyLoading.dismiss();
                    log("Error fetching location: $e");
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Resources.colors.greyColor.withOpacity(.2),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        Resources.images.kundliImage,
                        height: 25,
                        width: 25,
                        // color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
        
              const SizedBox(width: 5),
              InkWell(
                onTap: () async {
                  EasyLoading.show(
                    status: 'Disconnecting...',
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.clear,
                  );
        
                  try {
                    // 1. Send CMD and Notify Backend
                    _sendEndChatCMD();
                    _cleanupAndExit();
                  } catch (e) {
                    debugPrint("End chat error: $e");
                  } finally {
                    EasyLoading.dismiss();
                  }
                },
        
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
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
                  child: Text(
                    "End",
                    style: Resources.styles.kTextStyle12B(Colors.black),
                  ),
                ),
              ),
            ],
          ),
        
          body: _isLoading || _isConnecting
              ? Center(
                  child: CircularProgressIndicator(
                    color: Resources.colors.themeColor,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            buildUserDetailsMessage(),
                            ..._chatList.map((e) {
                              int index = _chatList.indexOf(e);
                              String content = e['content'].toString();
        
                              // match audio
                              final audioMatch = RegExp(
                                r'https?:\/\/\S+\.(aac|mp3|wav|m4a)',
                              ).firstMatch(content);
        
                              String audioUrl = "";
                              String textBefore = "";
                              String textAfter = "";
                              if (audioMatch != null) {
                                audioUrl = audioMatch.group(0)!;
        
                                textBefore = content
                                    .substring(0, audioMatch.start)
                                    .trim();
                                textAfter = content
                                    .substring(audioMatch.end)
                                    .trim();
                              } else {
                                textBefore = content.trim();
                              }
                              // Extract image URL
                              final imageMatch = RegExp(
                                r'https:\/\/[^\s]+',
                              ).firstMatch(content);
                              final imageUrl = imageMatch?.group(0);
        
                              // Extract "Replied to:" text (if any)
                              final hasReplyText = content.contains(
                                "Replied to:",
                              );
        
                              // Extract the rest of the text after the image URL
                              final afterImageText = imageUrl != null
                                  ? content.split(imageUrl).last.trim()
                                  : content;

                              return e["sender"]["_id"] ==
                                      PrefService().getRegId()
                                  ? Slidable(
                                      key: ValueKey(
                                        'msg_${index}_${e["content"].hashCode}',
                                      ),
                                      direction: Axis.horizontal,
                                      startActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.25,
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              setState(() {
                                                _replyingMessage = e;
                                              });
                                            },
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            icon: Icons.reply,
                                            label: 'Reply',
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                e["sender"]["_id"] ==
                                                    PrefService().getRegId()
                                                ? Colors.green[100]
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(15),
                                              topRight: const Radius.circular(15),
                                              bottomLeft:
                                                  e["sender"]["_id"] ==
                                                      PrefService().getRegId()
                                                  ? const Radius.circular(15)
                                                  : const Radius.circular(0),
                                              bottomRight:
                                                  e["sender"]["_id"] ==
                                                      PrefService().getRegId()
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(15),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // Text("data ${e['content'].toString().contains('https://a61.easemob.com/')}\n",),
                                              e['content'].toString().contains(
                                                    "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                  )
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Optional: Show "Replied to:"
                                                        if (hasReplyText)
                                                          const Text(
                                                            "Replied to:",
                                                            style: TextStyle(
                                                              fontStyle: FontStyle
                                                                  .italic,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
        
                                                        // Show the image if the URL exists
                                                        if (imageUrl != null &&
                                                            imageUrl.contains(
                                                              "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                            ))
                                                          SizedBox(
                                                            height: 200,
                                                            child:
                                                                MyZoomImageWidget(
                                                                  imgUrl:
                                                                      imageUrl,
                                                                ),
                                                          ),
        
                                                        // Show the remaining message after the image
                                                        if (afterImageText
                                                            .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 8.0,
                                                                ),
                                                            child: Text(
                                                              afterImageText,
                                                            ),
                                                          ),
                                                      ],
                                                    )
                                                  : audioUrl.isNotEmpty
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (textBefore.isNotEmpty)
                                                          Text(textBefore),
        
                                                        if (audioUrl.isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 6,
                                                                ),
                                                            child:
                                                                AttachmentAudioWidget(
                                                                  url: audioUrl,
                                                                ),
                                                          ),
        
                                                        if (textAfter.isNotEmpty)
                                                          Text(textAfter),
                                                      ],
                                                    )
                                                  : e['content']
                                                        .toString()
                                                        .endsWith(".aac")
                                                  ? AttachmentAudioWidget(
                                                      url: e["content"],
                                                    )
                                                  : e["content"]
                                                        .toString()
                                                        .contains(
                                                          "How Can I help you?",
                                                        )
                                                  ? const SizedBox.shrink()
                                                  : Text(
                                                      e["content"].toString(),
                                                      style: TextStyle(
                                                        color:
                                                            e["sender"]["_id"] ==
                                                                PrefService()
                                                                    .getRegId()
                                                            ? Colors.black
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "${e["time"]}",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Slidable(
                                      key: ValueKey(
                                        'msg_${index}_${e["content"].hashCode}',
                                      ),
                                      direction: Axis.horizontal,
                                      startActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.25,
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              setState(() {
                                                _replyingMessage = e;
                                              });
                                            },
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            icon: Icons.reply,
                                            label: 'Reply',
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                e["sender"]["_id"] ==
                                                    PrefService().getRegId()
                                                ? Colors.green[100]
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(15),
                                              topRight: const Radius.circular(15),
                                              bottomLeft:
                                                  e["sender"]["_id"] ==
                                                      PrefService().getRegId()
                                                  ? const Radius.circular(15)
                                                  : const Radius.circular(0),
                                              bottomRight:
                                                  e["sender"]["_id"] ==
                                                      PrefService().getRegId()
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(15),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              e['content'].toString().contains(
                                                    "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                  )
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Optional: Show "Replied to:"
                                                        if (hasReplyText)
                                                          const Text(
                                                            "Replied to:",
                                                            style: TextStyle(
                                                              fontStyle: FontStyle
                                                                  .italic,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
        
                                                        // Show the image if the URL exists
                                                        if (imageUrl != null &&
                                                            imageUrl.contains(
                                                              "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                            ))
                                                          SizedBox(
                                                            height: 200,
                                                            child:
                                                                MyZoomImageWidget(
                                                                  imgUrl:
                                                                      imageUrl,
                                                                ),
                                                          ),
        
                                                        // Show the remaining message after the image
                                                        if (afterImageText
                                                            .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 8.0,
                                                                ),
                                                            child: Text(
                                                              afterImageText,
                                                            ),
                                                          ),
                                                      ],
                                                    )
                                                  : e['content']
                                                        .toString()
                                                        .endsWith(".aac")
                                                  ? AttachmentAudioWidget(
                                                      url: e["content"],
                                                    )
                                                  : Text(
                                                      e["content"].toString(),
                                                      style: TextStyle(
                                                        color:
                                                            e["sender"]["_id"] ==
                                                                PrefService()
                                                                    .getRegId()
                                                            ? Colors.black
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "${e["time"]}",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
        
                    if (_replyingMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border(
                            left: BorderSide(
                              color: Colors.green.withOpacity(0.6),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.reply,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child:
                                  _replyingMessage!['content'].toString().contains(
                                    "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                  )
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: MyZoomImageWidget(
                                            imgUrl: RegExp(r'https:\/\/[^\s]+')
                                                .firstMatch(
                                                  _replyingMessage!['content'],
                                                )!
                                                .group(0)!,
                                          ),
                                        ),
                                      ],
                                    )
                                  : _replyingMessage!['content']
                                        .toString()
                                        .endsWith(".aac")
                                  ? AttachmentAudioWidget(
                                      url: _replyingMessage!["content"],
                                    )
                                  : _replyingMessage!['content']
                                        .toString()
                                        .contains(".aac")
                                  ? AttachmentAudioWidget(
                                      url:
                                          RegExp(
                                                r'https?:\/\/\S+\.(aac|mp3|m4a|wav)',
                                              )
                                              .firstMatch(
                                                _replyingMessage!["content"],
                                              )
                                              .toString(),
                                    )
                                  : Text(
                                      _replyingMessage!["content"],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _replyingMessage = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            //  Camera / Image Picker
                            GestureDetector(
                              onTap: () =>
                                  showImagePickerDialog(context, _remoteChatId!),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey.withOpacity(0.4),
                                child: Icon(
                                  Icons.photo_camera_back_outlined,
                                  color: Resources.colors.themeColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
        
                            // Text Field
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _controller,
                                        style: Resources.styles.kTextStyle14B5(
                                          Resources.colors.blackColor,
                                        ),
                                        cursorColor: Resources.colors.blackColor,
                                        decoration: InputDecoration(
                                          hintText: 'Say Hi...',
                                          hintStyle: Resources.styles
                                              .kTextStyle14B5(
                                                Resources.colors.blackColor,
                                              ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                          suffixIcon: GestureDetector(
                                            onTap: () async {
                                              if (!isRecording) {
                                                await recorder.start();
                                                isRecording = true;
                                                setState(() {});
                                              } else {
                                                final result = await recorder
                                                    .stop();
                                                isRecording = false;
                                                setState(() {});
        
                                                if (result != null) {
                                                  if (kDebugMode) {
                                                    print(
                                                      'isRecording ${result.duration}',
                                                    );
                                                  }
        
                                                  http.MultipartFile?
                                                  attachments =
                                                      await http
                                                          .MultipartFile.fromPath(
                                                        "attachments",
                                                        result!.file.path
                                                            .toString(),
                                                      );
        
                                                  _repository
                                                      .addNewMessageWithAttachment(
                                                        widget.chatId,
                                                        {},
                                                        [attachments],
                                                      )
                                                      .then((v) {
                                                        if (kDebugMode) {
                                                          print("$v");
                                                        }
        
                                                        _messageContent =
                                                            v['data']['attachments'][0]['url'];
                                                        _sendMessage().then((
                                                          value,
                                                        ) {
                                                          _controller.clear();
                                                        });
                                                      });
                                                }
                                              }
                                            },
                                            child: Icon(
                                              isRecording
                                                  ? Icons.stop_circle
                                                  : Icons.mic,
                                              color: isRecording
                                                  ? Colors.red
                                                  : Colors.black,
                                              size: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
        
                            // Send Button
                            GestureDetector(
                              onTap: () {
                                if (_controller.text.trim().isNotEmpty) {
                                  _messageContent = _controller.text.trim();
                                  _sendMessage().then((_) => _controller.clear());
                                }
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Resources.colors.blackColor,
                                child: Icon(
                                  Icons.send,
                                  color:Resources.colors.themeColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> showImagePickerDialog(
    BuildContext context,
    String toUserId,
  ) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await sendImageMessage(toUserId, pickedFile.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await sendImageMessage(toUserId, pickedFile.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // send image message
  Future<void> sendImageMessage(String toUserId, String imagePath) async {
    var message = ChatMessage.createImageSendMessage(
      targetId: toUserId,
      filePath: imagePath,
      chatType: ChatType.Chat,
    );

    await ChatClient.getInstance.chatManager.sendMessage(message);
  }
}

// for voice message

class AttachmentAudioWidget extends StatefulWidget {
  final String url;
  const AttachmentAudioWidget({super.key, required this.url});

  @override
  State<AttachmentAudioWidget> createState() => _AttachmentAudioWidgetState();
}

class _AttachmentAudioWidgetState extends State<AttachmentAudioWidget> {
  late AudioPlayerController audioController;

  @override
  void initState() {
    super.initState();
    audioController = GlobalAudioPlayer().controller;

    /// Reset when completed
    audioController.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioController.stop();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioController.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;
        final isThisAudioPlaying =
            isPlaying && audioController.currentUrl == widget.url;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isThisAudioPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 34,
                  color: Colors.blueAccent,
                ),
                onPressed: () async {
                  if (isPlaying && !isThisAudioPlaying) {
                    /// Another audio is playing → stop it
                    await audioController.stop();
                  }

                  if (isThisAudioPlaying) {
                    await audioController.pause();
                  } else {
                    await audioController.play(widget.url);
                  }

                  setState(() {});
                },
              ),

              const SizedBox(width: 10),

              const Text(
                "Voice message",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(width: 10),

              if (isThisAudioPlaying)
                const Icon(Icons.graphic_eq, size: 22, color: Colors.green),
            ],
          ),
        );
      },
    );
  }
}
