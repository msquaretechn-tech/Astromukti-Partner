import 'dart:async';
import 'dart:developer';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/utils/sound_recorder.dart';
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
import '../../utils/utils.dart';
import '../../utils/voice_message.dart';
import '../kundli/kundli.dart';
import 'image_zoomer.dart';

// final ChatRingTone ringtonePlayer = ChatRingTone();
class ChatPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final String chatId;
  const ChatPage({super.key, required this.userDetails, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
  late bool isNewUser;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    dob = widget.userDetails["dob"] ?? "";
    dobTime = widget.userDetails["dobTime"] ?? "";
    birthPlace = widget.userDetails["birthPlace"] ?? "";
    gender = widget.userDetails["gender"] ?? "";
    name =
        "${widget.userDetails["name"] ?? ""} ${widget.userDetails["lastName"] ?? ""}";
    var raw = widget.userDetails["isNewUser"];
    log("why coming : $raw");
    isNewUser = raw == true || raw == "true";

    Repository().updateProfile({
      "isChatAvailable": false,
      "chatGroupId": widget.userDetails["_id"],
      "isNowAvailable": false,
    }, []);

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Parallelize all initial fetches
    await Future.wait([
      _initSDK(),
      _fetchVendorDetails(),
      _fetchPreviousMessages(),
    ]);

    if (mounted) {
      context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
      setState(() {
        _isConnecting = false;
      });
      // Scroll to bottom after connections are established and messages loaded
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // instance of voice recorder
  final recorder = SoundRecorderManager();
  bool isRecording = false;

  // user details get
  Widget buildUserDetailsMessage() {
    return InkWell(
      onTap: () {
        userCallDetails();
      },
      child: Container(
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
      ),
    );
  }

  void userCallDetails() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        " Birth Details",
                        style: Resources.styles.kTextStyle26(Colors.black),
                      ),
                    ),
                    const SizedBox(width: 15),
                    CircleAvatar(
                      backgroundColor: Resources.colors.blackColor,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Name     : ",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      name,
                      style: Resources.styles.kTextStyle14B(Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Gender : ",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      gender,
                      style: Resources.styles.kTextStyle14B(Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Date of Birth : ",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      dob,
                      style: Resources.styles.kTextStyle14B(Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Time of Birth : ",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      dobTime,
                      style: Resources.styles.kTextStyle14B(Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Place of Birth :",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      " $birthPlace",
                      style: Resources.styles.kTextStyle14B(Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Cancel ",
                            style: Resources.styles.kTextStyle16B(Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    InkWell(
                      onTap: () async {
                        EasyLoading.show(
                          status: 'loading...',
                          dismissOnTap: false,
                          maskType: EasyLoadingMaskType.clear,
                        );
                        try {
                          // Fetch latitude and longitude from the city name (birthPlace)
                          List<Location> locations = await locationFromAddress(
                            birthPlace,
                          );
                          if (locations.isNotEmpty) {
                            double latitude = locations[0].latitude;
                            double longitude = locations[0].longitude;
                            log("Latitude: $latitude, Longitude: $longitude");
                            EasyLoading.dismiss();
                            // Navigate to the next screen with the latitude and longitude
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ZodiacSign(
                                    dob: dob,
                                    dot: dobTime,
                                    dop: birthPlace,
                                    name: name,
                                    gender: gender,
                                    latitude: latitude,
                                    longitude: longitude,
                                  ),
                                ),
                              );
                            }
                          } else {
                            EasyLoading.dismiss();
                            log("No locations found for the given address.");
                          }
                        } catch (e) {
                          EasyLoading.dismiss();
                          log("Error fetching location: $e");
                        }
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * .4,
                        decoration: BoxDecoration(
                          color: Resources.colors.greenColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Open Kundli",
                          style: Resources.styles.kTextStyle16B(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivate ${context.read<ChatTimerBloc>()}");
    super.deactivate();
  }

  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  // AGORA CHAT SDK
  String _localUserId = "";
  bool isConnected = false;
  String? _messageContent, _remoteChatId = "";
  final List<Map<String, dynamic>> _chatList = [];

  Future<void> _initSDK() async {
    print("$myLog _initSDK");
    ChatOptions options = ChatOptions(
      appKey: AgoraConfig.appKey,
      autoLogin: true,
    );

    await client.init(options);
    await client.startCallback();
    _localUserId = PrefService().getRegId();
    _remoteChatId = widget.userDetails["_id"];

    // Register listeners immediately after initialization
    _addChatListener();

    await _signIn();
  }

  Future<void> _signIn() async {
    print("_localUserId $_localUserId");
    print("_remoteChatId $_remoteChatId");

    try {
      // 1. Check connection and login state
      bool isLoggedIn = await client.isLoginBefore();
      
      // Get a fresh token
      var agoraToken = await Repository().generateChatToken(_localUserId);
      
      if (!isLoggedIn) {
        await client.loginWithToken(_localUserId, agoraToken['userToken']);
      } else {
        // Even if caught as "logged in", manually refreshing token session is safer
        try {
          await client.renewAgoraToken(agoraToken['userToken']);
        } catch (e) {
          log("Renew token failed, re-logging in: $e");
          await client.logout(true);
          await client.loginWithToken(_localUserId, agoraToken['userToken']);
        }
      }

      // 2. Refresh profile
      if (profile == null) {
        await _fetchVendorDetails();
      }

      // 3. Complete setup
      chatTimerSub = context.read<ChatTimerBloc>().stream.listen((state) {});
      await _fetchPreviousMessages();
      
      dob = "${widget.userDetails["dob"] ?? ""}";
      dobTime = "${widget.userDetails["dobTime"] ?? ""}";
      birthPlace = "${widget.userDetails["birthPlace"] ?? ""}";
      name = "${widget.userDetails["name"] ?? ""} ${widget.userDetails["lastName"] ?? ""}";
      gender = "${widget.userDetails["gender"] ?? ""}";

      // 4. Send welcome message if first time
      if (!_welcomeMessageSent && profile != null && mounted) {
        _messageContent = "Hii, I am ${profile!.name} ${profile!.lastName} welcome you to Astro Mukti. How Can I help you?";
        if (_messageContent!.isNotEmpty) {
          await _sendMessage();
          _controller.clear();
          setState(() {
            _welcomeMessageSent = true;
          });
          _startCountdownTimer();
        }
      }
    } catch (e) {
      print("Error in _signIn: $e");
      // If unauthorized, clear prefs and force login screen (handled by NetworkApiServices usually)
    }
  }

  void _signOut() async {
    try {
      await client.logout(true).then((value) {
        if (context.read<ChatTimerBloc>() != null) {
          // context.read<ChatTimerBloc>().add(ChatEndEvent());
        } else {
          print("ChatTimerBloc is not found in the context.");
        }
      });

      print("Sign-out succeeded.");
    } on ChatError catch (e) {
      print("Sign-out failed: code: ${e.code}, description: ${e.description}");
    } catch (e) {
      print("An unexpected error occurred during sign-out: $e");
      Utils.snackBar(
        "An unexpected error occurred during sign-out: $e",
        context,
      );
    }
  }

  Future<void> clearAllConversations() async {
    try {
      final conversations = await ChatClient.getInstance.chatManager
          .getConversationsFromServer();
      for (var convo in conversations) {
        await ChatClient.getInstance.chatManager.deleteConversation(convo.id);
      }
      print('All chats cleared!');
    } catch (e) {
      print('Error clearing all chats: $e');
    }
  }

  Map<String, dynamic>? previousMessages;
  Future<void> _fetchPreviousMessages() async {
    if (!mounted) return;
    vendorDetailsModel = await Repository().getVendorDetail();
    previousMessages = await Repository().getTotalMessages(widget.chatId);

    print("$myLog Previous messages : $previousMessages");

    previousMessages!["data"].reversed.forEach((element) {
      _chatList.add({
        "content": element["content"],
        "time": Utils.formatMongoTime(element['createdAt']),
        "sender": {"_id": element['sender']},
      });
    });
  }

  Future<void> _sendMessage() async {
    print("ccccccccccccccccccccccccccc");
    if (_remoteChatId == null || _messageContent == null) {
      print(
        "$myLog annot send message: Remote ID, content, or connection issue",
      );
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
      print("$myLog sendMessage : $msg");
      await client.chatManager.sendMessage(msg);

      // Clear reply state after sending
      setState(() {
        _replyingMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _addChatListener() {
    print("_addChatListener");
    client.chatManager.addEventHandler(
      Resources.strings.chatHandlerUniqueId,
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
    client.addConnectionEventHandler(
      Resources.strings.chatHandlerUniqueId,
      ConnectionEventHandler(
        onConnected: () {
          print("$myLog ConnectionEventHandler onConnected");
          if (mounted) {
            setState(() {
              isConnected = true;
            });
          }
        },
        onDisconnected: () {
          print("$myLog ConnectionEventHandler onDisconnected");
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        },
        onTokenWillExpire: () async {
          print("$myLog onTokenWillExpire - Refreshing token");
          var agoraToken = await Repository().generateChatToken(_localUserId);
          await client.renewAgoraToken(agoraToken['userToken']);
        },
      ),
    );

    client.chatManager.addMessageEvent(
      Resources.strings.chatHandlerUniqueId,
      ChatMessageEvent(
        onSuccess: (msgId, msg) async {
          print("$myLog send message onSuccess : $msg");

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

            print(
              "sendWelcomeMessage : ${body.content.contains("How Can I help you?")}",
            );
            if (body.content.contains('How Can I help you?')) {
              log(" this chat work or not");
              return;
            }
            // send chat ended message when chat ended
            if (body.content == "Chat ended.") {
              return;
            }

            await Repository().addNewMessage(widget.chatId, {
              "content": body.content,
            });
          }
        },
        onError: (msgId, msg, error) {
          print("$myLog send message onError - Message ID: $msgId");
          print("$myLog Failed message: ${msg.toString()}");
          print("$myLog Error details: $error");

          if (error is PlatformException) {
            print(
              "$myLog PlatformException details: ${error.code}, ${error.description}",
            );
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
      print("$myLog onMessagesReceived : $msg");
      if (mounted) {
        setState(() {
          isConnected = true;
        });
      }
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;

            if (msg.to == PrefService().getRegId()) {
              if (msg.from == widget.userDetails["_id"]) {
                _addToChatList({
                  "content": body.content,
                  "time": _timeString,
                  "sender": widget.userDetails,
                });
              }
              if (body.content.contains("Chat ended")) {
                log("bodyyy:$body");
                Navigator.pop(context);
                return;
              }
            } else {
              print("Nothing ");
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
        default:
          break;
      }
    }
  }

  void _addToChatList(Map<String, dynamic> mData) {
    print("$myLog _addToChatList : $mData");

    _chatList.add(mData);
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  String get _timeString {
    return DateFormat.jm().format(DateTime.now());
  }

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _startCountdownTimer() {
    final dynamic rawWallet = widget.userDetails["walletAmount"];
    final dynamic rawRate = profile!.chatRate;

    double wallet = 0;
    double rate = 1;

    // Parse walletAmount
    if (rawWallet is num) {
      wallet = rawWallet.toDouble();
    } else if (rawWallet is String) {
      wallet = double.tryParse(rawWallet) ?? 0;
    }

    // Parse chatRate
    if (rawRate is num) {
      rate = rawRate.toDouble();
    } else if (rawRate is String) {
      rate = double.tryParse(rawRate) ?? 1;
    }

    if (rate <= 0) rate = 1;

    double talkMinutes = wallet / rate;
    print("Talk time allowed: $talkMinutes minutes");

    _remainingSeconds = (talkMinutes * 60).round();

    if (_remainingSeconds <= 0) {
      print("Countdown not started: insufficient balance.");
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        print("Time over. Ending session.");
        _signOut();
        context.read<NotificationBloc>().add(
          NotificationResetEvent("${widget.userDetails["_id"]}"),
        );

        //Navigator.pop(context);
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
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching vendor details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to bottom whenever the keyboard height changes
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    print(" coming : $isNewUser");
    return Scaffold(
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
                  Text(
                    _formatDuration(_remainingSeconds),
                    style: Resources.styles.kTextStyle12(Colors.black),
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
                    Resources.images.openKundliImage,
                    height: 25,
                    width: 25,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: InkWell(
          //     onTap: () {
          //       GoRouter.of(context).pushNamed(RoutesName.matching);
          //     },
          //     child: CircleAvatar(
          //       backgroundColor: Resources.colors.greyColor.withOpacity(.2),
          //       child: Container(
          //         width: 30,
          //         height: 30,
          //         decoration: const BoxDecoration(shape: BoxShape.circle),
          //         child: Center(
          //           child: Image.asset(
          //             Resources.images.matchMakingImage,
          //             height: 25,
          //             width: 25,
          //             color: Colors.red,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: InkWell(
          //     onTap: () {
          //       GoRouter.of(context).pushNamed(
          //         RoutesName.numerology,
          //         extra: {"name": name.toString(), "dob": dob.toString()},
          //       );
          //     },
          //     child: CircleAvatar(
          //       backgroundColor: Resources.colors.greyColor.withOpacity(.2),
          //       child: Container(
          //         width: 30,
          //         height: 30,
          //         decoration: const BoxDecoration(shape: BoxShape.circle),
          //         child: Center(
          //           child: Image.asset(
          //             Resources.images.numerologyImage,
          //             height: 25,
          //             width: 25,
          //             color: Colors.red,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          InkWell(
            onTap: () async {
              EasyLoading.show(
                status: 'Disconnecting...',
                dismissOnTap: false,
                maskType: EasyLoadingMaskType.clear,
              );

              try {
                // 1️⃣ Send last message
                _messageContent = 'Chat ended.';
                await _sendMessage();
                _messageContent = '';

                // 2️⃣ Send notification FIRST
                await NotificationService.sendNotification(
                  widget.userDetails["fcmToken"],
                  "Chat Ended",
                  "Chat Ended",
                  {'userId': _localUserId},
                );

                // 3️⃣ Update profile status
                await Repository().updateProfile({
                  "isChatAvailable": true,
                  "isAudioCallAvailable": true,
                  "isVideoCallAvailable": true,
                  "isNowAvailable": true,
                  "isOnline": true,
                }, []);

                // 4️⃣ Cancel timers & blocs
                _countdownTimer?.cancel();
                _countdownTimer = null;

                context.read<CountDownTimerBloc>().add(StopTimer());
                context.read<NotificationBloc>().add(
                  NotificationResetEvent("${widget.userDetails["_id"]}"),
                );

                // 5️⃣ Sign out
                _signOut();

                // 6️⃣ Close screen
                Navigator.pop(context, true);
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
      body: WillPopScope(
        onWillPop: () async {
          if (_replyingMessage != null) {
            setState(() {
              _replyingMessage = null;
            });
            return false;
          }

          final shouldEnd = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "End Chat",
                style: Resources.styles.kTextStyle16B(Colors.black),
              ),
              content: Text(
                "Are you sure you want to end this chat?",
                style: Resources.styles.kTextStyle14B(Colors.black),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "No",
                    style: Resources.styles.kTextStyle16B(Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    "Yes",
                    style: Resources.styles.kTextStyle16B(Colors.white),
                  ),
                ),
              ],
            ),
          );

          if (shouldEnd == true) {
            EasyLoading.show(
              status: 'Disconnecting...',
              dismissOnTap: false,
              maskType: EasyLoadingMaskType.clear,
            );

            try {
              // 1. Send notification
              await NotificationService.sendNotification(
                widget.userDetails["fcmToken"],
                "Chat Ended",
                'Chat Ended',
                {'userId': _localUserId},
              );

              // 2. Send "Chat ended." message
              _messageContent = 'Chat ended.';
              await _sendMessage();
              _messageContent = '';

              // 3. Update profile status (VERY IMPORTANT: Await this)
              await Repository().updateProfile({
                "isChatAvailable": true,
                "isAudioCallAvailable": true,
                "isVideoCallAvailable": true,
                "isNowAvailable": true,
                "isOnline": true,
              }, []);

              // 4. Cleanup and pop
              _countdownTimer?.cancel();
              _countdownTimer = null;
              context.read<CountDownTimerBloc>().add(StopTimer());
              context.read<NotificationBloc>().add(
                NotificationResetEvent("${widget.userDetails["_id"]}"),
              );
              _signOut();
              
              if (mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              log("Error ending chat via back: $e");
            } finally {
              EasyLoading.dismiss();
            }
            return false;
          }

          return false;
        },
        child: _isLoading || _isConnecting
            ? Center(
                child: CircularProgressIndicator(
                  color: Resources.colors.themeColor,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
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

                          return e["sender"]["_id"] == PrefService().getRegId()
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
                                        borderRadius: BorderRadius.circular(10),
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
                                        color: e["sender"]["_id"] ==
                                                PrefService().getRegId()
                                            ? Colors.green[100]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(15),
                                          topRight: const Radius.circular(15),
                                          bottomLeft: e["sender"]["_id"] ==
                                                  PrefService().getRegId()
                                              ? const Radius.circular(15)
                                              : const Radius.circular(0),
                                          bottomRight: e["sender"]["_id"] ==
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (hasReplyText)
                                                      const Text(
                                                        "Replied to:",
                                                        style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    if (imageUrl != null &&
                                                        imageUrl.contains(
                                                          "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                        ))
                                                      SizedBox(
                                                        height: 200,
                                                        child: MyZoomImageWidget(
                                                          imgUrl: imageUrl,
                                                        ),
                                                      ),
                                                    if (afterImageText
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                            afterImageText),
                                                      ),
                                                  ],
                                                )
                                              : audioUrl.isNotEmpty
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (textBefore
                                                            .isNotEmpty)
                                                          Text(textBefore),
                                                        if (audioUrl.isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 6),
                                                            child:
                                                                AttachmentAudioWidget(
                                                              url: audioUrl,
                                                            ),
                                                          ),
                                                        if (textAfter
                                                            .isNotEmpty)
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
                                                          ? const SizedBox
                                                              .shrink()
                                                          : Text(
                                                              e["content"]
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: e["sender"]
                                                                            [
                                                                            "_id"] ==
                                                                        PrefService()
                                                                            .getRegId()
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .black87,
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
                                        borderRadius: BorderRadius.circular(10),
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
                                        color: e["sender"]["_id"] ==
                                                PrefService().getRegId()
                                            ? Colors.green[100]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(15),
                                          topRight: const Radius.circular(15),
                                          bottomLeft: e["sender"]["_id"] ==
                                                  PrefService().getRegId()
                                              ? const Radius.circular(15)
                                              : const Radius.circular(0),
                                          bottomRight: e["sender"]["_id"] ==
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (hasReplyText)
                                                      const Text(
                                                        "Replied to:",
                                                        style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    if (imageUrl != null &&
                                                        imageUrl.contains(
                                                          "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles",
                                                        ))
                                                      SizedBox(
                                                        height: 200,
                                                        child: MyZoomImageWidget(
                                                          imgUrl: imageUrl,
                                                        ),
                                                      ),
                                                    if (afterImageText
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                            afterImageText),
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
                                                        color: e["sender"]
                                                                    ["_id"] ==
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
                                color: Resources.colors.blackColor,
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
                                        // suffixIcon: GestureDetector(
                                        //   onTap: () async {
                                        //     if (!isRecording) {
                                        //       await recorder.start();
                                        //       isRecording = true;
                                        //       setState(() {});
                                        //     } else {
                                        //       final result = await recorder
                                        //           .stop();
                                        //       isRecording = false;
                                        //       setState(() {});
                                        //
                                        //       if (result != null) {
                                        //         print('isRecording $result');
                                        //
                                        //         http.MultipartFile?
                                        //         attachments =
                                        //             await http
                                        //                 .MultipartFile.fromPath(
                                        //               "attachments",
                                        //               result!.file.path
                                        //                   .toString(),
                                        //             );
                                        //
                                        //         _repository
                                        //             .addNewMessageWithAttachment(
                                        //               widget.chatId,
                                        //               {},
                                        //               [attachments],
                                        //             )
                                        //             .then((v) {
                                        //               print("$v");
                                        //
                                        //               _messageContent =
                                        //                   v['data']['attachments'][0]['url'];
                                        //               _sendMessage().then((
                                        //                 value,
                                        //               ) {
                                        //                 _controller.clear();
                                        //               });
                                        //             });
                                        //       }
                                        //     }
                                        //   },
                                        //   child: Icon(
                                        //     isRecording
                                        //         ? Icons.stop_circle
                                        //         : Icons.mic,
                                        //     color: isRecording
                                        //         ? Colors.red
                                        //         : Colors.black,
                                        //     size: 26,
                                        //   ),
                                        // ),
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
                              backgroundColor: Resources.colors.themeColor,
                              child: Icon(
                                Icons.send,
                                color: Colors.black,
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
