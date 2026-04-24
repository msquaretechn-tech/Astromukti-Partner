import 'dart:async';
import 'dart:developer';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/chat_timer/chat_timer_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../model/get_vendor.dart';
import '../../model/vender_detail_model.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../../resources/string.dart';
import '../../utils/utils.dart';
import 'image_zoomer.dart';

class ChatHistory extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final String chatId;
  const ChatHistory(
      {super.key, required this.userDetails, required this.chatId});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
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
  @override
  void initState() {
    _initSDK();
    setState(() {
      _isLoading = true;
    });
    dob = widget.userDetails["dob"] ?? "";
    dobTime = widget.userDetails["dobTime"] ?? "";
    birthPlace = widget.userDetails["birthPlace"] ?? "";
    gender = widget.userDetails["gender"] ?? "";
    super.initState();
    Repository().updateProfile({
      "chatGroupId": widget.userDetails["_id"],
    }, []);
    print("ssssssssssss  Babu  ${widget.userDetails}");
    print("ssssssssssss  Babu  ${widget.chatId}");
    _fetchVendorDetails().then((v) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
      }
    });
  }

  // user details get
  Widget buildUserDetailsMessage() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '''DOB: $dob
Time: $dobTime
 Place: $birthPlace
 Gender: $gender
''',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
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
  // AGORA CHAT SDK
  String _localUserId = "";
  bool isConnected = false;
  String? _messageContent, _remoteChatId = "";
  final List<Map<String, dynamic>> _chatList = [];
  final bool _hasTimerStarted = false;
  void _initSDK() async {
    print("$myLog _initSDK");
    vendorDetailsModel = await Repository().getVendorDetail();
    ChatOptions options = ChatOptions(
      appKey: AgoraConfig.appKey,
      autoLogin: true,
    );

    await client.init(options);
    await client.startCallback();
    _localUserId = PrefService().getRegId();
    _remoteChatId = widget.userDetails["_id"];
    _fetchPreviousMessages();
  }

  Map<String, dynamic>? previousMessages;
  _fetchPreviousMessages() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
    if (_scrollController.hasClients) {
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  String get _timeString {
    return DateFormat.jm().format(DateTime.now());
  }

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    log("asdff ${widget.userDetails["avatar"]}");

    return Scaffold(
      appBar: AppBar(
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
                children: [
                  Text(
                    widget.userDetails["name"] ?? "",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Text(
                  //   _formatDuration(_remainingSeconds),
                  //   style: Resources.styles.kTextStyle12(Colors.black),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Resources.colors.themeColor,
            ))
          : Column(
              children: [
               // buildUserDetailsMessage(),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: _chatList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> e = entry.value;
                      // int index = _chatList.indexOf(e);

                      String content = e['content'].toString();

                      // Extract image URL
                      final imageMatch =
                          RegExp(r'https:\/\/[^\s]+').firstMatch(content);
                      final imageUrl = imageMatch?.group(0);

                      // Extract "Replied to:" text (if any)
                      final hasReplyText = content.contains("Replied to:");

                      // Extract the rest of the text after the image URL
                      final afterImageText = imageUrl != null
                          ? content.split(imageUrl).last.trim()
                          : content;
                      print("Chat Data $e");
                      if (e["content"].toString().contains(
                          "Hii, I am ${profile!.name} ${profile!.lastName} I welcome you to BookmyAstro. How Can I help you?")) {
                        return const SizedBox.shrink();
                      }

                      // Fix: Use a unique Key for each Slidable item, e.g., using index + content hashCode
                      return Slidable(
                        key: ValueKey('msg_${index}_${e["content"].hashCode}'),
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
                          color: Colors.transparent,
                          alignment:
                              e["sender"]["_id"] == PrefService().getRegId()
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  e["sender"]["_id"] == PrefService().getRegId()
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: e["sender"]["_id"] ==
                                        PrefService().getRegId()
                                    ? const Radius.circular(20)
                                    : const Radius.circular(0),
                                bottomRight: e["sender"]["_id"] ==
                                        PrefService().getRegId()
                                    ? const Radius.circular(0)
                                    : const Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                e['content'].toString().contains(
                                        "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles")
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Optional: Show "Replied to:"
                                          if (hasReplyText)
                                            const Text(
                                              "Replied to:",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            ),

                                          // Show the image if the URL exists
                                          if (imageUrl != null &&
                                              imageUrl.contains(
                                                  "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles"))
                                            SizedBox(
                                              height: 200,
                                              child: MyZoomImageWidget(
                                                  imgUrl: imageUrl),
                                            ),

                                          // Show the remaining message after the image
                                          if (afterImageText.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(afterImageText),
                                            ),
                                        ],
                                      )
                                    : Text(
                                        e["content"],
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                const SizedBox(height: 2),
                                Text(
                                  "${e["time"]}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Reply widget if replying to a message
                if (_replyingMessage != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        const Icon(Icons.reply, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _replyingMessage!['content'].toString().contains(
                                  "${AgoraConfig.orgName}/${AgoraConfig.appName}/chatfiles")
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: MyZoomImageWidget(
                                          imgUrl: RegExp(r'https:\/\/[^\s]+')
                                              .firstMatch(
                                                  _replyingMessage!['content'])!
                                              .group(0)!),
                                    ),
                                  ],
                                )
                              : Text(
                                  _replyingMessage!["content"],
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 20, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _replyingMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
