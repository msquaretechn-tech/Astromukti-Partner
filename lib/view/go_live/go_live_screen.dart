import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/call_timer/call_timer_bloc.dart';
import '../../bloc/waitlist_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../model/vender_detail_model.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../../resources/string.dart';
import '../../routes/routes_name.dart';
import '../../services/notification_service.dart';
import '../kundli/kundli.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen>
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        WidgetsBindingObserver {
  final String _streamLog = 'Stream log';
  late AnimationController _controller;

  final Repository repository = Repository();

  Map<String, ValueNotifier<bool>> callAvailabilityNotifiers = {
    "isAnonymousCallAvailable": ValueNotifier(false),
    "isPrivateCallAvailable": ValueNotifier(false),
    "isAudioCallAvailable": ValueNotifier(false),
    "isVideoCallAvailable": ValueNotifier(false),
  };

  // Function to update call availability based on key
  Future<void> updateCallAvailability(String key) async {
    final currentNotifier = callAvailabilityNotifiers[key];
    if (currentNotifier == null) return;

    // Toggle the current value
    final newValue = !currentNotifier.value;

    try {
      // Update profile on the server
      await repository.updateProfile({key: newValue}, []);

      // Update the ValueNotifier locally
      currentNotifier.value = newValue;
    } catch (error) {
      print("Error updating profile for $key: $error");
    }
  }

  bool isLocalZoomed = false;
  bool _isStopCamera = false;
  var dob;
  var name;
  var gender;
  var dot;
  var dop;
  int? _remoteUid;
  late String _appToken;
  int? _localUid;
  List<int> remoteUIds = [];

  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isSpeaking = false;
  bool _isListening = false;
  Timer? _timer;
  double totalCallDuration = 0;
  String channelId = '';

  String groupDesc = "";

  String streamType = "live"; // live,video,audio,anonymous,private

  final Repository _repository = Repository();

  VendorDetailsModel? vendorDetails;

  // get all created groups

  Future<void> changeStreamType(String type) async {
    print("_localUid : $_localUid");
    print("remoteUIds : $remoteUIds");
    // Reset settings before applying new mode configurations
    // await _resetStreamSettings();
    // Get total users in stream
    _repository.getTotalUserInStream(channelId).then((value) {
      print("Total Users  In Steam $value");
    });

    // UPDATE IN DATABASE
    _repository.updateProfile({
      "broadcastId": _localUid,
      "channelId": channelId,
      "streamType": type,
    }, []);

    // CHANGE ROLE ACCORDING TO CALL TYPE
    // live,video,audio,anonymous,anonymous
    if (type == "live") {
      // Show Video with audio to all Users If Astrologer Not Mute
      for (var element in remoteUIds) {
        await _engine.muteRemoteAudioStream(uid: element, mute: true);
      }

      _engine.muteAllRemoteAudioStreams(false);
      _engine.muteAllRemoteVideoStreams(false);
      // _engine.setDefaultMuteAllRemoteAudioStreams(false);
      // _engine.setDefaultMuteAllRemoteVideoStreams(false);
      Repository().getTotalUserInStream(channelId).then((value) {
        print("Total Users  In Steam $value");
        // Ensure both broadcasters are unmuted
        value["data"]["broadcasters"].forEach((element) {
          print("Mute Remote User : $element");
          _engine.muteRemoteAudioStream(uid: element, mute: false);
          /* _engine.adjustUserPlaybackSignalVolume(
              uid: element, volume: 100); // Set to 100% volume*/
        });

        // Ensure the audience can hear both broadcasters
        value["data"]["audience"].forEach((element) {
          _engine.muteRemoteAudioStream(
            uid: element,
            mute: false,
          ); // Ensure audience receives both audio streams
        });
      });
      await _engine.muteLocalAudioStream(false);
      await _engine.muteAllRemoteAudioStreams(false);
      if (kDebugMode) {
        print("_engine.muteAllRemoteAudioStreams(false);");
      }
      _isMuted = false;

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    } else if (type == "video") {
      // Both Consultant and you in video call
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      setState(() {});
      Repository().getTotalUserInStream(channelId).then((value) {
        print("Total Users  In Steam $value");
        // Ensure both broadcasters are unmuted
        value["data"]["broadcasters"].forEach((element) {
          print("Mute Remote User : $element");
          _engine.muteRemoteAudioStream(uid: element, mute: false);
          _engine.adjustUserPlaybackSignalVolume(
            uid: element,
            volume: 100,
          ); // Set to 100% volume
        });

        // Ensure the audience can hear both broadcasters
        value["data"]["audience"].forEach((element) {
          _engine.muteRemoteAudioStream(
            uid: element,
            mute: false,
          ); // Ensure audience receives both audio streams
        });
      });
    } else if (type == "audio") {
      // Consultant on Video and you in audio call
    } else if (type == "anonymous") {
      // Consultant on Video and you on in audio. No one can hear you.Consultant is audible.
    } else if (type == "private") {
      // Consultant on Video and you on audio. No one else hear your conversation.
      for (var element in remoteUIds) {
        // if (element.toString() != latestUid) {
        //   await _engine.muteRemoteAudioStream(uid: element, mute: true);
        // }
      }
    }
    if (mounted) {
      setState(() {
        streamType = type;
      });
    }
  }

  // Function to reset audio and video settings to default
  Future<void> _resetStreamSettings() async {
    for (var element in remoteUIds) {
      await _engine.muteRemoteAudioStream(uid: element, mute: false);
    }
    await _engine.muteLocalAudioStream(true);
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
  }

  // disconnect call
  Future<void> disconnectCall() async {
    // Step1 -> Change live stream
    changeStreamType("live");
    dob = null;
    dop = null;
    dot = null;
    name = null;
    gender = null;
    // Step 2 -> Send Notification
    String url =
        "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/messages/chatrooms";
    debugPrint('groupId==========>>>>>${groupId}');
    Map<String, dynamic> mData = {
      "from": _localUserId,
      "to": [(groupId!)],
      "type": "txt",
      "body": {"msg": "CALL_DISCONNECTED_BY:${_localUserId}"},
    };

    context.read<WaitlistBloc>().add(WaitlistGetEvent());
    await http
        .post(
      Uri.parse(url),
      headers: {'Authorization': "Bearer ${agoraToken["appToken"]}"},
      body: jsonEncode(mData),
    )
        .then((value) {
      print("Pankaj onMessageReceived : After Call Disconnected : $value");

      Fluttertoast.showToast(msg: "Disconnected");
    });
  }

  // <------------------------- START ANIMATION -------------------------->
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..stop();
  late final Animation<double> _animation = Tween<double>(begin: 0, end: 400)
      .animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ),
  );

  bool _showGift = false;

  String _giftUrl = "";
  String _giftSenderName = "";

  void _startAnimation(String giftUrl) {
    _animationController.reset();
    _animationController.forward().then((value) {
      setState(() {
        _showGift = false;
        _giftUrl = giftUrl;
      });
    });
  }

  // <------------------------- END ANIMATION -------------------------->

  // <------------------------- RTM START -------------------------->

  // AgoraRtmClient? _client;
  // AgoraRtmChannel? _channel;
  //
  // // Initialize RTM Client
  // Future<void> initialize() async {
  //   _client = await AgoraRtmClient.createInstance(AgoraConfig.appId);
  //
  //   // Set up client listeners
  //   _client?.onConnectionStateChanged = (int state, int reason) {
  //     print('Connection state changed: $state, reason: $reason');
  //   };
  //
  //   _client?.onMessageReceived = (RtmMessage message, String peerId) {
  //     print('Private message from $peerId: ${message.text}');
  //   };
  // }
  //
  // // Login to RTM
  // Future<void> login(String userId) async {
  //   try {
  //     final agoraChatToken = await Repository().generateChatToken(userId);
  //     log("onValue : $agoraChatToken");
  //     final appToken = agoraChatToken["appToken"];
  //     final rtmToken = agoraChatToken["rtmToken"];
  //     log("appToken : $appToken");
  //     log("rtmToken : $rtmToken");
  //     await _client?.login(rtmToken, userId);
  //     print('Login success: $userId');
  //     print('Login success: $userId');
  //   } catch (e) {
  //     print('Login failed: $e hhhhh');
  //     if (e is AgoraRtmClientException) {
  //       print("Login failed : ${e.code} , Reason : ${e.reason}");
  //     }
  //     rethrow;
  //   }
  // }

  // // Join a channel
  // Future<void> joinChannel(String channelName) async {
  //   try {
  //     // _channel = await _client?.createChannel(channelName);
  //     // if (_channel == null) {
  //     //   print("Failed to create channel.");
  //     //   return;
  //     // }
  //
  //     // await _channel?.join();
  //     print("Successfully joined channel: $channelName");
  //
  //     // Set up listeners
  //     print("Setting up channel listeners...");
  //     // _channel?.onMessageReceived =
  //     //     (RtmMessage message, RtmChannelMember member) {
  //     //   print('Channel message from ${member.userId}: ${message.text}');
  //     //
  //     //   setState(() {});
  //     //   log("_gifts :$_giftUrl");
  //     //   log("_giftSenderName :$_giftSenderName");
  //     //   _giftSenderName = message.text.split(",")[0];
  //     //   _giftUrl = message.text.split(",")[1];
  //     //   _showGift = true;
  //     //   _startAnimation(message.text.split(",")[1]);
  //     // };
  //
  //     // _channel?.onMemberJoined = (RtmChannelMember member) {
  //     //   print('Member joined: ${member.userId}');
  //     // };
  //     //
  //     // _channel?.onMemberLeft = (RtmChannelMember member) {
  //     //   print('Member left: ${member.userId}');
  //     // };
  //   } catch (e) {
  //     print('Join channel failed: $e');
  //     rethrow;
  //   }
  // }
  //
  // // Send channel message
  // Future<void> sendChannelMessage(String message) async {
  //   try {
  //     // await _channel?.sendMessage2(RtmMessage.fromText(message));
  //     print('Channel message sent: $message');
  //   } catch (e) {
  //     print('Send channel message failed: $e');
  //     rethrow;
  //   }
  // }
  //
  // // Send peer-to-peer message
  // Future<void> sendPeerMessage(String peerId, String message) async {
  //   try {
  //     // await _client?.sendMessageToPeer2(peerId, RtmMessage.fromText(message));
  //     print('Peer message sent to $peerId: $message');
  //   } catch (e) {
  //     print('Send peer message failed: $e');
  //     rethrow;
  //   }
  // }

  // Leave channel
  Future<void> leaveChannel() async {
    try {
      // await _channel?.leave();
      //  await deleteAllGroups();
      print('Left channel');
    } catch (e) {
      print('Leave channel failed: $e');
      rethrow;
    }
  }

  // Logout and release resources
  Future<void> logout() async {
    try {
      // await _client?.logout();
      print('Logout success');
    } catch (e) {
      print('Logout failed: $e');
      rethrow;
    }
  }

  // Initialize RTM
  Future<void> _initializeRTM() async {
    // await initialize();

    var userId = await PrefService().getRegId();

    // await login(userId);
    log("jjjjjjj:$channelId");
    // await joinChannel(channelId);
  }

  // <------------------------- RTM END -------------------------->
  AppLifecycleState state = AppLifecycleState.resumed;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) async {
      await _initAgoraLive();
    });

    context.read<WaitlistBloc>().add(WaitlistGetEvent());

    BlocProvider.of<AuthBloc>(context).add(
      ProfileUpdateEvent(
        formData: const {
          "isLive": true,
          "callerName": "",
          "isMuted": false,
          "isPaused": false,
          "isNowAvailable": false,
          // "isVideoCallAvailable": false
        },
        files: const [],
      ),
    );
    _repository.getVendorDetail().then((value) {
      print("vendorDetails$value ");
      vendorDetails = value;
      _initChatSdk();
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    log("sssssssss:$state");
    state = appLifecycleState;
    if (state == AppLifecycleState.resumed) {
      Repository().updateProfile({"isLive": true}, []).then((value) {
        log("value:$value");
      });
    }
  }

  void _rotateAvatar() {
    _controller.forward(from: 0);
  }

  Future<void> _initAgoraLive() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    vendorDetails = await Repository().getVendorDetail();

    callAvailabilityNotifiers = {
      "isAnonymousCallAvailable": ValueNotifier(
        vendorDetails!.isAnonymousCallAvailable as bool,
      ),
      "isPrivateCallAvailable": ValueNotifier(
        vendorDetails!.isPrivateCallAvailable as bool,
      ),
      "isAudioCallAvailable": ValueNotifier(
        vendorDetails!.isAudioCallAvailable as bool,
      ),
      "isVideoCallAvailable": ValueNotifier(
        vendorDetails!.isVideoCallAvailable as bool,
      ),
    };

    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();

    try {
      await _engine.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
      print("$_streamLog Step 2: $_engine");
    } catch (e) {
      print(e);
      print("$_streamLog Step 2 Error : $e");
    }
    print("$_streamLog Step 1 : $_engine");

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType errorCode, String errorMsg) {
          print("$_streamLog Step 3: onError: $errorCode:$errorMsg");
          debugPrint("$_streamLog Step 3: onError: $errorCode:$errorMsg");
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log('helo joines--------------------------11');
          debugPrint("local user ${connection.localUid} joined");
          print("$_streamLog Step 3: local user ${connection.localUid} joined");
          setState(() {
            _localUid = connection.localUid;
            _localUserJoined = true;
          });
          _repository.updateProfile({
            "broadcastId": _localUid,
            "channelId": channelId,
            "streamType": 'live',
          }, []);
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          log('helo joines--------------------------');
          debugPrint("remote user $remoteUid joined");
          print("$_streamLog Step 3: remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
          remoteUIds.add(remoteUid);
          debugPrint('remoteUIds==========>>>>>$remoteUIds');
        },
        onUserMuteAudio: (connection, remoteUid, muted) {
          debugPrint('remoteUid==========>>>>>$remoteUid');
          debugPrint('muted==========>>>>>$muted');
          Repository()
              .updateProfile({"isMuted": _isMuted ? true : false}, [])
              .then((value) {
            log("value:$value");
          });
        },
        onRemoteVideoStats: (connection, stats) {
          debugPrint('stats==========>>>>>${stats}');
        },
        onUserOffline:
            (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) {
          debugPrint("remote user $remoteUid left channel");
          print("$_streamLog Step 3: remote user $remoteUid left channel");
          remoteUIds.remove(remoteUid);
          setState(() {
            _remoteUid = null;
          });
        },
        onRejoinChannelSuccess: (connection, elapsed) {
          debugPrint('connection==========>>>>>${connection}');
        },
        onRemoteAudioStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          debugPrint('remoteUid==========>>>>>$remoteUid');
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          print(
            "$_streamLog Step 3: [onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token",
          );
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
        onAudioVolumeIndication:
            (
            RtcConnection connection,
            List<AudioVolumeInfo> speakers,
            int speakerNumber,
            int totalVolume,
            ) {
          print(
            "onAudioVolumeIndication : $speakers : $speakerNumber : $totalVolume ",
          );
          bool isListening = false;
          bool isSpeaking = false;

          for (var speaker in speakers) {
            print("speeeeeaaakerrrr:${speaker.uid}");
            if (speaker.volume! > 5 && speaker.uid == 0) {
              print(
                "onAudioVolumeIndication : ${speaker.uid} : ${speaker.volume}",
              );
              debugPrint(
                "onAudioVolumeIndication : ${speaker.uid} : ${speaker.volume} : _isSpeaking : $_isSpeaking",
              );
              isSpeaking = true;
            }
            if (speaker.volume! > 5 && speaker.uid != 0) {
              // Ensure you're not detecting your own audio
              print(
                "Listening to user: ${speaker.uid}, volume: ${speaker.volume}",
              );
              isListening = true;
            }
          }
          // Update listening state based on the check
          if (isListening) {
            if (mounted) {
              setState(() {
                _isListening = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
          if (isSpeaking) {
            if (mounted) {
              setState(() {
                _isSpeaking = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isSpeaking = false;
              });
            }
          }
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    // await _engine.enableLocalVideo(true);
    await _engine.startPreview();
    await _engine.enableAudio();

    // Enables the audioVolumeIndication
    await _engine.enableAudioVolumeIndication(
      interval: 250,
      smooth: 3,
      reportVad: true,
    );

    if (mounted) {
      setState(() {});
    }
    //await _engine.setParameters("{\"che.video.hardware_encoding\":false}");
    await _engine.setLogFilter(LogFilterType.logFilterDebug);

    // await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
    //   dimensions: VideoDimensions(width: 640, height: 360),
    //   frameRate: 15,
    //   bitrate: 800,
    //   orientationMode: OrientationMode.orientationModeAdaptive,
    // ));

    channelId = vendorDetails!.mobile.toString();
    // channelId = data.mobile.toString();

    groupDesc = vendorDetails!.mobile.toString();

    int uid = math.Random().nextInt(1000000000);

    var token = await Repository().generateRTCToken(
      channelId,
      'publisher',
      '$uid',
    );

    await _engine.leaveChannel().then((value) async {
      await _engine.joinChannel(
        token: token,
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(),
      );
      print("$_streamLog Step 3 : $token");
    });

    _initializeRTM();
  }

  @override
  void didUpdateWidget(covariant GoLiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    BlocProvider.of<AuthBloc>(context).add(
      ProfileUpdateEvent(formData: const {"isLive": "true"}, files: const []),
    );
    // _initAgoraLive();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageContent = "${vendorDetails?.name ?? ""} closed live stream.";
    _sendMessage();
    _dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    await Repository().updateProfile({
      "isLive": false,
      "isNowAvailable": true,
    }, []);
  }

  // CHAT
  final ScrollController _scrollController = ScrollController();
  final _msgController = TextEditingController();
  final List<Map<String, dynamic>> _logText = [];

  void _initChatSdk() async {
    _messageContent = "${vendorDetails?.name ?? ""}   live stream started.";
    ChatOptions options = ChatOptions(
      appKey: AgoraConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
    ChatClient.getInstance.isLoginBefore().then((value) async {
      if (value) {
        await ChatClient.getInstance.logout(true);
      }
      print("Live : _initChatSdk -> Step 1 ");
      _signIn();
    });
  }

  String _localUserId = "";
  String? _messageContent, _remoteChatId = "";
  var agoraToken;

  Future<void> _signIn() async {
    _localUserId = PrefService().getRegId();

    _remoteChatId = '';

    print("_localUserId $_localUserId");
    print("_remoteChatId $_remoteChatId");
    agoraToken = await Repository().generateChatToken(_localUserId);
    ChatClient.getInstance
        .isLoginBefore()
        .then((value) async {
      print("Live: _signIn login -> Step 3 : $value");
      // Check if the user is already logged in
      if (value == false) {
        try {
          await ChatClient.getInstance.loginWithAgoraToken(
            _localUserId,
            agoraToken!["userToken"],
          );
          print("Live: _signIn login -> Step 3");
        } catch (e) {
          print("Error: $e");
        }
      } else {
        print("User is already logged in");
      }

      _createGroup();
      _addChatListener();
    })
        .catchError((e) {
      print('Error : _signIn $e');
    });
  }

  String? groupId;

  _createGroup() async {
    await Repository().getVendorDetail().then((value) async {
      if (value.chatGroupId == null ||
          value.chatGroupId == "" ||
          value.chatGroupId == "null") {
        ChatGroupOptions groupOptions = ChatGroupOptions(
          style: ChatGroupStyle.PublicOpenJoin,
        );
        try {
          final groupName = value.mobile.toString();
          ChatGroup groupDetails = await ChatClient.getInstance.groupManager
              .createGroup(
            groupName: groupName,
            desc: groupDesc,
            options: groupOptions,
          );
          groupId = groupDetails.groupId;
          await Repository().updateProfile({
            "chatGroupId": groupDetails.groupId,
          }, []);
          // Join the group after creation
          await ChatClient.getInstance.groupManager.joinPublicGroup(
            groupDetails.groupId,
          );
        } on ChatError catch (e) {
          print("ChatError : $e");
        }
      } else {
        groupId = value.chatGroupId;
        List<ChatGroup> joinedGroups = await ChatClient.getInstance.groupManager
            .getJoinedGroups();

        bool isGroupPresent = joinedGroups.any(
              (group) => group.groupId == groupId,
        );

        if (!isGroupPresent) {
          await ChatClient.getInstance.groupManager.joinPublicGroup(groupId!);
        }
      }
      _sendMessage();
    });
  }

  void _addLogToConsole(Map<String, dynamic> log) {
    _logText.add(log);
    if (mounted) {
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  Future<void> _sendMessage() async {
    String url =
        "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/messages/chatrooms";
    debugPrint('groupId==========>>>>>${groupId}');
    Map<String, dynamic> mData = {
      "from": _localUserId,
      "to": [(groupId!)],
      "type": "txt",
      "body": {
        "msg": jsonEncode({
          "text": "$_messageContent",
          "avatar": vendorDetails?.avatar,
        }),
      },
    };

    print("_sendMessage : $mData");
    await http.post(
      Uri.parse(url),
      headers: {'Authorization': "Bearer ${agoraToken["appToken"]}"},
      body: jsonEncode(mData),
    );
  }

  void _addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      'GROUP_CALL_HANDLER_ID',
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );

    ChatClient.getInstance.chatManager.addMessageEvent(
      'GROUP_CALL_HANDLER_ID',
      ChatMessageEvent(
        onSuccess: (msgId, msg) async {
          debugPrint('body msg ==========>>>>>$msg');
          ChatTextMessageBody body = msg.body as ChatTextMessageBody;
          debugPrint('body==========>>>>>${body}');
          debugPrint(
            'bodyLogBlocked==========>>>>>${body.content.toString().contains("Blocked")}',
          );
          print('bodyLogBlocked${body.content.toString().contains("Blocked")}');

          if (body.content.contains("CALL_ACCEPT_ANONYMOUS") ||
              body.content.contains("CALL_ACCEPT_PRIVATE") ||
              body.content.contains("CALL_ACCEPT_VIDEO") ||
              body.content.contains("CALL_ACCEPT_AUDIO")) {
            print('CALL_ACCEPT ');
          } else if (body.content.toString().contains("Blocked")) {
            print(
              "My Blocked ${jsonDecode(body.content)["text"].split(":")[1]}",
            );
            var ids = jsonDecode(body.content)["text"].split(":")[1];
            print("CALL_BLOCKED_OF : $ids");
            print("CALL_BLOCKED_OF : local  $_localUserId");
          } else {
            _addLogToConsole({
              "content": body.content,
              "sender": {"_id": PrefService().getRegId()},
            });
          }
        },
        onError: (msgId, msg, error) {
          print('Error : $error');
        },
      ),
    );
  }

  Future<void> onMessagesReceived(List<ChatMessage> messages) async {
    for (var msg in messages) {
      print("Pankaj onMessageReceived :  $msg");
      switch (msg.body.type) {
        case MessageType.TXT:
          print("onMessagesReceived : $msg");

          Repository().getTotalUserInStream(channelId).then((value) {
            print("Total Users  In Steam $value");
          });
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            debugPrint('msg.body==========>>>>>${body}');
            debugPrint('msg.from.toString()${msg.from.toString()}');

            if (body.content.contains("MYCALLanonymous") ||
                body.content.contains("MYCALLprivate") //||
            // body.content.contains("CALL_REQUEST_VIDEO") ||
            // body.content.contains("CALL_REQUEST_AUDIO")
            ) {
              context.read<WaitlistBloc>().add(WaitlistGetEvent());
              var data = jsonDecode(body.content);
            } else if (body.content.contains("ANONYMOUS_CALL_JOINED_BY")) {
              log("bodyContent : ${body.content}");
              dob = body.content.split(",")[1];
              dot = body.content.split(",")[2];
              dop = body.content.split(",")[3];
              name = body.content.split(",")[4];
              gender = body.content.split(",")[5];
              log("dob : $dob");
              log("dot : $dot");
              log("dop : $dop");
              userCallDetails();
              context.read<CallTimerBloc>().add(CallStartEvent());
              if (mounted) {
                setState(() {
                  streamType = "anonymous";
                });
              }
              changeStreamType("anonymous");
              _addLogToConsole({
                "content": "Anonymous call joined.....",
                "sender": {"_id": "${msg.from}"},
              });
            } else if (body.content.contains("PRIVATE_CALL_JOINED_BY")) {
              dob = body.content.split(",")[1];
              dot = body.content.split(",")[2];
              dop = body.content.split(",")[3];
              name = body.content.split(",")[4];
              gender = body.content.split(",")[5];
              log("dot : $dot");

              userCallDetails();
              context.read<CallTimerBloc>().add(CallStartEvent());
              if (mounted) {
                setState(() {
                  streamType = "private";
                });
              }
              changeStreamType("private");
              _addLogToConsole({
                "content": "Private call joined.....",
                "sender": {"_id": "${msg.from}"},
              });
            } else if (body.content.contains("CALL_REQUEST_AUDIO") ||
                body.content.contains("CALL_REQUEST_VIDEO")) {
              context.read<WaitlistBloc>().add(WaitlistGetEvent());
            } else if (body.content.contains("EXIT_WAITING_CALL")) {
              context.read<WaitlistBloc>().add(WaitlistGetEvent());
            } else if (body.content.contains("AUDIO_CALL_JOINED_BY")) {
              dob = body.content.split(",")[1];
              dot = body.content.split(",")[2];
              dop = body.content.split(",")[3];
              name = body.content.split(",")[4];
              gender = body.content.split(",")[5];

              Repository().updateProfile({"callerName": name}, []);
              // join Call user details
              userCallDetails();
              context.read<CallTimerBloc>().add(CallStartEvent());
              changeStreamType("audio");
              _addLogToConsole({
                "content": "Audio call joined.....",
                "sender": {"_id": "${msg.from}"},
              });
            } else if (body.content.contains("VIDEO_CALL_JOINED_BY")) {
              dob = body.content.split(",")[1];
              dot = body.content.split(",")[2];
              dop = body.content.split(",")[3];
              name = body.content.split(",")[4];
              gender = body.content.split(",")[5];

              Repository().updateProfile({"callerName": name}, []);
              userCallDetails();
              changeStreamType("video");
              context.read<CallTimerBloc>().add(CallStartEvent());
              _addLogToConsole({
                "content": "Video call joined.....",
                "sender": {"_id": "${msg.from}"},
              });
            } else if (body.content.contains("CALL_ACCEPT_VIDEO")) {
              var ids = body.content.split(":")[1];
              if (ids != _localUserId) {
                await _engine.muteAllRemoteAudioStreams(true);
                await _engine.muteRemoteAudioStream(
                  uid: _remoteUid!,
                  mute: false,
                );
                setState(() {});
              }
            } else if (body.content.contains("CALL_DISCONNECTED_BY")) {
              dob = null;
              dop = null;
              dot = null;
              name = null;
              gender = null;
              changeStreamType("live");
              context.read<CallTimerBloc>().add(CallEndEvent());
            } else if (body.content.toString().contains("Blocked")) {
              print(
                "My Blocked ${jsonDecode(body.content)["text"].split(":")[1]}",
              );
              var ids = jsonDecode(body.content)["text"].split(":")[1];
              print("CALL_BLOCKED_OF : $ids");
              print("CALL_BLOCKED_OF : local  $_localUserId");
            } else {
              _addLogToConsole({
                "content": body.content,
                "sender": {"_id": "${msg.from}"},
              });
            }
          }
          break;
        default:
          break;
      }
    }
  }

  bool _isMuted = false;

  @override
  bool get wantKeepAlive => false;

  @override
  void updateKeepAlive() {
    print("updateKeepAlive");
    // _initAgoraLive();
    super.updateKeepAlive();
  }

  Future<void> deleteAllGroups() async {
    try {
      // Step 1: Get list of all groups you have joined
      List<ChatGroup> groups = await ChatClient.getInstance.groupManager
          .getJoinedGroups();

      for (var group in groups) {
        // Step 2: Check if you are the owner of the group
        if (group.owner == ChatClient.getInstance.currentUserId) {
          try {
            // Step 3: Delete the group
            await ChatClient.getInstance.groupManager.destroyGroup(
              group.groupId,
            );
            print("Deleted group: ${group.name}");
          } catch (e) {
            print("Failed to delete group ${group.groupId}: $e");
          }
        }
      }
    } catch (e) {
      print("Error fetching joined groups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("channelId : $channelId");
    print("streamType : $streamType");
    print("remoteUIds : $remoteUIds");
    print("groupId : $groupId");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // _initAgoraLive();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    return Scaffold(
      bottomNavigationBar: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Confirm Stop',
                  style: Resources.styles.kTextStyle16B(
                    Resources.colors.blackColor,
                  ),
                ),
                content: Text(
                  'Are you sure you want to stop the live stream?',
                  style: Resources.styles.kTextStyle14B(
                    Resources.colors.blackColor,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'No',
                      style: Resources.styles.kTextStyle16B(
                        Resources.colors.blackColor,
                      ),
                    ),
                  ),
                  TextButton(
                    // onPressed: () async {
                    //   if (streamType != "live") {
                    //     await disconnectCall();
                    //   }
                    //   changeStreamType("live");
                    //   BlocProvider.of<AuthBloc>(context)
                    //       .add(ProfileUpdateEvent(formData: const {
                    //     "isLive": 'false',
                    //   }, files: const []));
                    //   if (groupId != null && groupId!.isNotEmpty) {
                    //     deleteSingleGroup(groupId.toString());
                    //   }
                    //   // delete group Id
                    //   _repository.getVendorDetail().then((value) {
                    //     vendorDetails = value;
                    //     _repository.deleteGroupId(value.mobile.toString());
                    //   });
                    //   Navigator.of(context).pop();
                    //   Navigator.of(context).pop();
                    // },
                    onPressed: () async {
                      Navigator.of(
                        context,
                      ).pop(); // Close the dialog immediately

                      await Future.delayed(const Duration(milliseconds: 100));

                      if (streamType != "live") {
                        await disconnectCall(); // Leave channel cleanly
                        await Future.delayed(const Duration(milliseconds: 200));
                      }

                      changeStreamType("live");

                      BlocProvider.of<AuthBloc>(context).add(
                        ProfileUpdateEvent(
                          formData: const {"isLive": 'false'},
                          files: const [],
                        ),
                      );

                      if (groupId != null && groupId!.isNotEmpty) {
                        deleteSingleGroup(groupId.toString());
                      }

                      _repository.getVendorDetail().then((value) {
                        vendorDetails = value;
                        _repository.deleteGroupId(value.mobile.toString());
                      });

                      // Only pop the screen after safe cleanup
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },

                    child: Text(
                      'Yes',
                      style: Resources.styles.kTextStyle16B(
                        Resources.colors.buttonColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          alignment: Alignment.center,
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Resources.colors.buttonColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Stop Live",
            style: Resources.styles.kTextStyle16B(Colors.white),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool shouldPop = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Confirm Stop',
                  style: Resources.styles.kTextStyle16B(
                    Resources.colors.blackColor,
                  ),
                ),
                content: Text(
                  'Are you sure you want to stop the live stream?',
                  style: Resources.styles.kTextStyle14B(
                    Resources.colors.blackColor,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      'No',
                      style: Resources.styles.kTextStyle16B(
                        Resources.colors.blackColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      changeStreamType("live");
                      BlocProvider.of<AuthBloc>(context).add(
                        ProfileUpdateEvent(
                          formData: const {"isLive": 'false'},
                          files: const [],
                        ),
                      );
                      // delete group Id
                      _repository.getVendorDetail().then((value) {
                        vendorDetails = value;
                        _repository.deleteGroupId(value.mobile.toString());
                      });
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Yes',
                      style: Resources.styles.kTextStyle16B(
                        Resources.colors.buttonColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return shouldPop ?? false;
        },
        child: SafeArea(
          child: Stack(
            children: [
              // CASE I
              streamType !=
                  "video" // Can be -> live,audio,anonymous,private
                  ? _localUserJoined // LOCAL USER
                  ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                  useFlutterTexture: true,
                  // useAndroidSurfaceView: true,
                ),
              )
                  : Center(
                child: CircularProgressIndicator(
                  color: Resources.colors.buttonColor,
                ),
              )
                  :
              // CASE II
              streamType == "video"
                  ? Stack(
                children: [
                  // REMOTE USER
                  Visibility(
                    visible: true,
                    child: Center(child: _remoteVideo()),
                  ),
                  _localUserJoined // LOCAL USER
                      ? Container(
                    height: Resources.dimens.height(context) * 0.2,
                    width: 100,
                    color: Colors.red,
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                        useFlutterTexture: true,
                        // useAndroidSurfaceView: true,
                      ),
                    ),
                  )
                      : const CircularProgressIndicator(),
                ],
              )
                  : const SizedBox(),

              // show gift that is send by
              _showGift
                  ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        left: 70,
                        bottom: _animation.value,
                        child: Transform.scale(
                          scale: 1 + (_animation.value / 800),
                          child: child!,
                        ),
                      ),
                    ],
                  );
                },
                child: Column(
                  children: [
                    Text(
                      _giftSenderName,
                      style: Resources.styles.kTextStyle12B(Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(_giftUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Container(),
              // timer Clock
              Positioned(
                top: 20,
                right: 20,
                child: BlocConsumer<CallTimerBloc, CallTimerState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    String time = '00:00';
                    if (state is CallStartState) {
                      time = state.time.toString();
                      return Chip(
                        backgroundColor: Colors.black45,
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //love
                            streamType == 'audio'
                                ? Text(
                              '$name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                                : streamType == 'video'
                                ? Text(
                              '$name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                                : streamType == 'anonymous'
                                ? const Text(
                              'Anonymous Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                                : streamType == 'private'
                                ? const Text(
                              'Private Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                                : const SizedBox.shrink(),
                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // LIVE CHAT
              Positioned(
                bottom: Resources.dimens.height(context) * 0.055,
                left: Resources.dimens.width(context) * 0.03,
                child: Container(
                  padding: const EdgeInsets.only(left: 5, bottom: 10),
                  height: Resources.dimens.height(context) * 0.35,
                  width: Resources.dimens.width(context) * 0.89,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    // reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _logText.map((e) {
                        var regId = PrefService().getRegId();
                        var senderId = e["sender"]["_id"];
                        return e["content"].toString().contains("avatar")
                            ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (regId != senderId) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape:
                                        const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        title: Center(
                                          child: Text(
                                            "Block User",
                                            textAlign: TextAlign.center,
                                            style: Resources.styles
                                                .kTextStyle16B(
                                              Colors.black,
                                            )
                                                .copyWith(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        content: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            "Are you sure you want to block this user?",
                                            style: Resources.styles
                                                .kTextStyle14B5(
                                              Colors.black,
                                            )
                                                .copyWith(
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        actions: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                              bottom: 8,
                                              right: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                    backgroundColor:
                                                    Colors.grey[200],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "No",
                                                    style: Resources
                                                        .styles
                                                        .kTextStyle16B(
                                                      Resources
                                                          .colors
                                                          .themeColor,
                                                    )
                                                        .copyWith(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey[800],
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Repository().userBlock(senderId).then((
                                                        value,
                                                        ) {
                                                      _messageContent =
                                                      "Blocked:$senderId";
                                                      log(
                                                        " Anamika : $_messageContent",
                                                      );
                                                      _sendMessage();
                                                      Navigator.pop(
                                                        context,
                                                      );
                                                      Fluttertoast.showToast(
                                                        msg:
                                                        "${value["message"]}",
                                                        backgroundColor:
                                                        Resources
                                                            .colors
                                                            .buttonColor,
                                                      );

                                                      _messageContent =
                                                      "Blocked:$senderId";
                                                      log(
                                                        " Anika : $_messageContent",
                                                      );
                                                      _sendMessage();
                                                      //e["content"].toString().contains("name");
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                    backgroundColor:
                                                    Resources
                                                        .colors
                                                        .buttonColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Yes",
                                                    style: Resources
                                                        .styles
                                                        .kTextStyle16B(
                                                      Colors.white,
                                                    )
                                                        .copyWith(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                  jsonDecode(
                                    e["content"],
                                  )["avatar"].toString() !=
                                      ""
                                      ? NetworkImage(
                                    "${AppUrl.baseUrl}/images/${jsonDecode(e["content"])["avatar"]}",
                                  )
                                      : const NetworkImage(
                                    "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),

                            // user chat
                            Container(
                              width:
                              MediaQuery.of(context).size.width * .75,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                      "${jsonDecode(e["content"])["text"].toString().split(' ')[0]}\n",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      "${jsonDecode(e["content"])["text"].toString().split(' ').sublist(1).join(' ')}\n",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                            : const SizedBox.shrink();
                      }).toList(),
                    ),
                  ),
                ),
              ),

              BlocConsumer<WaitlistBloc, WaitlistState>(
                listener: (context, state) {
                  log('userCallResponse State  : $state');

                  if (state is UserCallResponseState) {
                    print("userCallResponse New Res : ${state.isJoined}");
                    print("userCallResponse New Res : ${state.userId}");
                    print("userCallResponse New Res : ${state.streamType}");
                    if (state.isJoined == 'true') {
                      changeStreamType(state.streamType);
                    } else {
                      changeStreamType('live');
                    }
                  }
                },
                builder: (context, state) {
                  if (state.runtimeType == WaitlistGetSuccessState) {
                    var data = state as WaitlistGetSuccessState;

                    print("Data : ${data.waitlist}");
                    return data.waitlist.isNotEmpty
                        ? Positioned(
                      bottom: Resources.dimens.height(context) * 0.23,
                      right: Resources.dimens.width(context) * 0.01,
                      child: GestureDetector(
                        onTap: () {
                          // GoRouter.of(context).pushNamed(RoutesName.videoCallPage);
                          showWaitingListModel();
                        },
                        child: SizedBox(
                          height: Resources.dimens.height(context) * 0.1,
                          child: CircleAvatar(
                            backgroundColor: Resources.colors.themeColor
                                .withOpacity(0.4),
                            child: Badge(
                              label: Text("${data.waitlist.length}"),
                              child: Icon(
                                Icons.timer,
                                size: 31,
                                color: Resources.colors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        : const SizedBox();
                  }
                  return const SizedBox();
                },
              ),

              // open Kundli
              Positioned(
                bottom: Resources.dimens.height(context) * 0.185,
                right: Resources.dimens.width(context) * 0.01,
                child: InkWell(
                  onTap: () async {
                    EasyLoading.show(
                      status: 'loading...',
                      dismissOnTap: false,
                      maskType: EasyLoadingMaskType.clear,
                    );
                    try {
                      List<Location> locations = await locationFromAddress(dop);
                      if (locations.isNotEmpty) {
                        double latitude = locations[0].latitude;
                        double longitude = locations[0].longitude;
                        log("Latitude: $latitude, Longitude: $longitude");
                        EasyLoading.dismiss();
                        print("tap tap-------------->tap atp");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ZodiacSign(
                              dob: dob,
                              dot: dot,
                              dop: dop,
                              name: name,
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
                      // MaterialPageRoute(
                      //     builder: (context) => const ZodiacSign(
                      //       dob: "",
                      //       dot: "",
                      //       dop: "",
                      //       name: "",
                      //       gender: "",
                      //       latitude: 0,
                      //       longitude:0 ,
                      //     ) );

                      GoRouter.of(
                        context,
                      ).pushNamed(RoutesName.zodiacPage, extra: "Kundli");
                      EasyLoading.dismiss();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Resources.colors.themeColor.withOpacity(
                      0.4,
                    ),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: Image.asset(
                          Resources.images.openKundliImage,
                          height: 25,
                          width: 25,
                          color: Resources.colors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // open match making
              Positioned(
                bottom: Resources.dimens.height(context) * 0.12,
                right: Resources.dimens.width(context) * 0.01,
                child: InkWell(
                  onTap: () {
                    GoRouter.of(context).pushNamed(RoutesName.matching);
                  },
                  child: CircleAvatar(
                    backgroundColor: Resources.colors.themeColor.withOpacity(
                      0.4,
                    ),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: Image.asset(
                          Resources.images.matchMakingImage,
                          height: 25,
                          width: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // EXIT ALL CALL
              Positioned(
                bottom: Resources.dimens.height(context) * 0.03,
                right: Resources.dimens.width(context) * 0.01,
                child: streamType == "live"
                    ? const SizedBox.shrink()
                    : GestureDetector(
                  onTap: () async {
                    await disconnectCall();
                  },
                  child: SizedBox(
                    height: Resources.dimens.height(context) * 0.1,
                    child: CircleAvatar(
                      backgroundColor: Resources.colors.themeColor
                          .withOpacity(0.4),
                      child: Icon(
                        Icons.call_end,
                        size: 24,
                        color: Resources.colors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),

              // SEND MESSAGE WIDGET
              Positioned(
                bottom: Resources.dimens.height(context) * 0.01,
                left: Resources.dimens.width(context) * 0.03,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _isMuted = !_isMuted;

                        _engine.muteLocalAudioStream(_isMuted);
                        log('_isMuted : $_isMuted');
                        Repository()
                            .updateProfile({
                          "isMuted": _isMuted ? true : false,
                        }, [])
                            .then((value) {
                          log("value:$value");
                        });

                        if (mounted) {
                          _isSpeaking = !_isMuted;
                          setState(() {});
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: _isSpeaking
                            ? Colors
                            .primaries[math.Random().nextInt(
                          Colors.primaries.length,
                        )]
                            .withOpacity(0.1)
                            : Resources.colors.themeColor.withOpacity(0.4),
                        radius: 20,
                        child: Icon(
                          size: 21,
                          _isMuted ? Icons.mic_off : Icons.mic,
                          color: Resources.colors.whiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _engine.switchCamera();
                      },
                      child: CircleAvatar(
                        backgroundColor: Resources.colors.themeColor
                            .withOpacity(0.4),
                        radius: 20,
                        child: Icon(
                          size: 21,
                          Icons.cameraswitch_outlined,
                          color: Resources.colors.whiteColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
                    // stop the camera
                    GestureDetector(
                      onTap: () {
                        if (_isStopCamera) {
                          _engine.enableVideo();
                          _engine.enableLocalVideo(true);
                        } else {
                          _engine.disableVideo();
                          _engine.enableLocalVideo(false);
                        }
                        Repository()
                            .updateProfile({
                          "isPaused": _isStopCamera ? false : true,
                        }, [])
                            .then((value) {
                          log("valuesssss:$value");
                        });

                        if (mounted) {
                          _isStopCamera = !_isStopCamera;
                          setState(() {});
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Resources.colors.themeColor
                            .withOpacity(0.4),
                        radius: 20,
                        child: Icon(
                          size: 21,
                          _isStopCamera
                              ? Icons.pause_circle_outlined
                              : Icons.videocam,
                          color: Resources.colors.whiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showCallModelSheet();
                      },
                      child: CircleAvatar(
                        backgroundColor: Resources.colors.themeColor
                            .withOpacity(0.4),
                        radius: 20,
                        child: Icon(
                          size: 21,
                          Icons.disabled_visible,
                          color: Resources.colors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    print("$_streamLog : $_remoteUid");
    if (_remoteUid != null) {
      return Container(
        height: Resources.dimens.height(context),
        decoration: BoxDecoration(border: Border.all(color: Colors.green)),
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelId),
          ),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  // Show Waiting List Model
  showWaitingListModel() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: Resources.dimens.width(context),
              decoration: BoxDecoration(
                color: Resources.colors.whiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(00.0),
                  topRight: Radius.circular(00.0),
                ),
              ),
              child: BlocConsumer<WaitlistBloc, WaitlistState>(
                listener: (context, state) {
                  log('userCallResponse State  : $state');
                },
                builder: (context, state) {
                  if (state.runtimeType == WaitlistGetSuccessState) {
                    var data = state as WaitlistGetSuccessState;
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Waitlist "),
                        ),
                        SizedBox(
                          height: Resources.dimens.height(context) * 0.45,
                          child: ListView.builder(
                            itemCount: data.waitlist.length,
                            itemBuilder: (c, i) {
                              print(
                                "Waitlist : ${data.waitlist[i]["waitType"]}",
                              );
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: RichText(
                                  text: TextSpan(
                                    text:
                                    '${data.waitlist[i]["name"]} ${data.waitlist[i]["lastName"]}',
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                        '[ ${data.waitlist[i]["waitType"]} ]',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: Resources.dimens.width(context) * 0.17,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // STEP 1- > REMOVE USER FROM WAITING LIST
                                          // STEP 2 -> NOTIFY TO USER

                                          _repository
                                              .removeWaitingCall(
                                            userId:
                                            data.waitlist[i]['userId'],
                                            waitType: data
                                                .waitlist[i]["waitType"],
                                            status: "cancelled",
                                          )
                                              .then((value) async {
                                            // Step 2 -> Send Notification
                                            String url =
                                                "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/messages/chatrooms";
                                            debugPrint(
                                              'groupId==========>>>>>${groupId}',
                                            );
                                            Map<String, dynamic> mData = {
                                              "from": _localUserId,
                                              "to": [(groupId!)],
                                              "type": "txt",
                                              "body": {
                                                "msg":
                                                "CALL_REJECTED_OF:${data.waitlist[i]['userId']}",
                                              },
                                            };

                                            context
                                                .read<WaitlistBloc>()
                                                .add(WaitlistGetEvent());
                                            await http
                                                .post(
                                              Uri.parse(url),
                                              headers: {
                                                'Authorization':
                                                "Bearer ${agoraToken["appToken"]}",
                                              },
                                              body: jsonEncode(mData),
                                            )
                                                .then((value) {
                                              print(
                                                "Pankaj onMessageReceived : After Call Disconnected : $value",
                                              );
                                              context
                                                  .read<WaitlistBloc>()
                                                  .add(
                                                WaitlistGetEvent(),
                                              );
                                              Navigator.pop(context);

                                              Fluttertoast.showToast(
                                                msg:
                                                "Cancel Successful",
                                              );
                                            });
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 21,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          // context.read<SessionNotifyBloc>().add(SessionGetNotifyEvent());
                                          // SEND NOTIFICATION TO USER
                                          // DISCONNECT PREVIOUS CALL IF ANY CALL IS RUNNING
                                          EasyLoading.show(
                                            status: 'loading...',
                                            dismissOnTap: false,
                                            maskType: EasyLoadingMaskType.clear,
                                          );
                                          if (streamType != "live") {
                                            // SEND NOTIFICATION TO OLD USER
                                            await disconnectCall();
                                          }

                                          print(
                                            "User Details : ${data.waitlist[i]}",
                                          );
                                          print("streamType : ${streamType}");

                                          debugPrint(
                                            '_localUid==========>>>>>${_localUid}',
                                          );
                                          debugPrint(
                                            'data.waitlist[i]wait==========>>>>>${data.waitlist[i]['waitType']}',
                                          );
                                          debugPrint(
                                            'groupId==========>>>>>${groupId}',
                                          );

                                          String url =
                                              "https://a61.chat.agora.io/${AgoraConfig.orgName}/${AgoraConfig.appName}/messages/chatrooms";
                                          debugPrint(
                                            'groupId==========>>>>>${groupId}',
                                          );

                                          var m = ChatMessage.createTxtSendMessage(
                                            targetId: data.waitlist[i]['userId']
                                                .toString(),
                                            content:
                                            data.waitlist[i]['waitType'] ==
                                                "anonymous"
                                                ? "CALL_ACCEPT_ANONYMOUS:${data.waitlist[i]['userId']}"
                                                : data.waitlist[i]['waitType'] ==
                                                "private"
                                                ? "CALL_ACCEPT_PRIVATE:${data.waitlist[i]['userId']}"
                                                : data.waitlist[i]['waitType'] ==
                                                "audio"
                                                ? "CALL_ACCEPT_AUDIO:${data.waitlist[i]['userId']}"
                                                : data.waitlist[i]['waitType'] ==
                                                "video"
                                                ? "CALL_ACCEPT_VIDEO:${data.waitlist[i]['userId']}"
                                                : "CALL_ACCEPT:${data.waitlist[i]['userId']}",
                                          );

                                          await ChatClient
                                              .getInstance
                                              .chatManager
                                              .sendMessage(m)
                                              .then((value) {
                                            print(
                                              "Pankaj onMessageReceived : After send response : $value",
                                            );
                                          });

                                          // var res = await http.post(
                                          //     Uri.parse(url),
                                          //     headers: {
                                          //       'Authorization':
                                          //           "Bearer ${agoraToken["appToken"]}"
                                          //     },
                                          //     body: jsonEncode(mData));
                                          // debugPrint(
                                          // 'res==========>>>>>${res}');

                                          // var m = ChatMessage.createSendMessage(body: ChatTextMessageBody(content:"CALL_ACCEPT_ANONYMOUS:${data.waitlist[i]['userId']}", ),chatType: ChatType.Chat);

                                          FirebaseMessaging.instance.getToken().then((
                                              value,
                                              ) {
                                            print("FCM Token : $value");
                                            NotificationService.sendNotification(
                                              data.waitlist[i]["fcmToken"],
                                              data.waitlist[i]['waitType'],
                                              data.waitlist[i]["astrologerName"],
                                              {
                                                "fcmToken": value,
                                                "waitType": data
                                                    .waitlist[i]['waitType'],
                                                "userId":
                                                data.waitlist[i]['userId'],
                                                "vendorId": data
                                                    .waitlist[i]['vendorId'],
                                              },
                                            );
                                            Repository()
                                                .removeWaitingCall(
                                              userId: data
                                                  .waitlist[i]['userId'],
                                              waitType: data
                                                  .waitlist[i]["waitType"],
                                              status: 'confirm',
                                            )
                                                .then((value) {
                                              EasyLoading.dismiss();
                                              context
                                                  .read<WaitlistBloc>()
                                                  .add(WaitlistGetEvent());
                                              Navigator.pop(context);
                                            });
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color:
                                              Resources.colors.greenColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.done,
                                            size: 21,
                                            color: Resources.colors.greenColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          },
        );
      },
    );
  }

  void userCallDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    " Birth Details",
                    style: Resources.styles.kTextStyle26(Colors.black),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Name    : ",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    Text(
                      "$name",
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
                      "$gender",
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
                      "$dob",
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
                      "$dot",
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
                      " $dop",
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
                            style: Resources.styles.kTextStyle16B(Colors.white),
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
                          // Fetch latitude and longitude from the city name (dop)
                          List<Location> locations = await locationFromAddress(
                            dop,
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
                                  dot: dot,
                                  dop: dop,
                                  name: name,
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

  void showCallModelSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: Resources.dimens.width(context),
          decoration: BoxDecoration(
            color: Resources.colors.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable:
                  callAvailabilityNotifiers["isVideoCallAvailable"]!,
                  builder: (context, isEnabled, child) {
                    return ListTile(
                      onTap: () {
                        updateCallAvailability("isVideoCallAvailable");
                      },
                      leading: CircleAvatar(
                        backgroundColor: Resources.colors.buttonColor,
                        child: const Icon(
                          Icons.video_call_outlined,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Video Call',
                        style: Resources.styles.kTextStyle12B(Colors.black),
                      ),
                      subtitle: Text(
                        'Both Consultant and you in video call',
                        style: Resources.styles.kTextStyle14(Colors.grey),
                      ),
                      trailing: Container(
                        height: Resources.dimens.height(context) * 0.05,
                        width: Resources.dimens.width(context) * 0.2,
                        decoration: Resources.styles.kBoxDecoration(
                          isEnabled
                              ? Resources.colors.buttonColor
                              : Colors.grey,
                        ),
                        child: Center(
                          child: Text(
                            isEnabled ? 'Enable' : 'Disable',
                            textAlign: TextAlign.center,
                            style: Resources.styles.kTextStyle14B5(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Audio Call ListTile
                ValueListenableBuilder<bool>(
                  valueListenable:
                  callAvailabilityNotifiers["isAudioCallAvailable"]!,
                  builder: (context, isEnabled, child) {
                    return ListTile(
                      onTap: () {
                        updateCallAvailability("isAudioCallAvailable");
                      },
                      leading: CircleAvatar(
                        backgroundColor: Resources.colors.buttonColor,
                        child: const Icon(Icons.call, color: Colors.white),
                      ),
                      title: Text(
                        'Audio Call',
                        style: Resources.styles.kTextStyle12B(Colors.black),
                      ),
                      subtitle: Text(
                        'Consultant on Video and you in audio call',
                        style: Resources.styles.kTextStyle14(Colors.grey),
                      ),
                      trailing: Container(
                        height: Resources.dimens.height(context) * 0.05,
                        width: Resources.dimens.width(context) * 0.2,
                        decoration: Resources.styles.kBoxDecoration(
                          isEnabled
                              ? Resources.colors.buttonColor
                              : Colors.grey,
                        ),
                        child: Center(
                          child: Text(
                            isEnabled ? 'Enable' : 'Disable',
                            textAlign: TextAlign.center,
                            style: Resources.styles.kTextStyle14B5(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // // Repeat similarly for Anonymous Call and Private Call
                // ValueListenableBuilder<bool>(
                //   valueListenable:
                //       callAvailabilityNotifiers["isAnonymousCallAvailable"]!,
                //   builder: (context, isEnabled, child) {
                //     return ListTile(
                //       onTap: () {
                //         updateCallAvailability("isAnonymousCallAvailable");
                //       },
                //       leading: CircleAvatar(
                //         backgroundColor: Resources.colors.buttonColor,
                //         child: const Icon(
                //           Icons.privacy_tip_outlined,
                //           color: Colors.white,
                //         ),
                //       ),
                //       title: Text(
                //         'Anonymous Call',
                //         style: Resources.styles.kTextStyle12B(Colors.black),
                //       ),
                //       subtitle: Text(
                //         'Consultant on Video and you in audio. No one can hear you.',
                //         style: Resources.styles.kTextStyle14(Colors.grey),
                //       ),
                //       trailing: Container(
                //         height: Resources.dimens.height(context) * 0.05,
                //         width: Resources.dimens.width(context) * 0.2,
                //         decoration: Resources.styles.kBoxDecoration(
                //           isEnabled
                //               ? Resources.colors.buttonColor
                //               : Colors.grey,
                //         ),
                //         child: Center(
                //           child: Text(
                //             isEnabled ? 'Enable' : 'Disable',
                //             textAlign: TextAlign.center,
                //             style: Resources.styles.kTextStyle14B5(
                //               Colors.white,
                //             ),
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                // const SizedBox(height: 10),
                //
                // // Private Call ListTile
                // ValueListenableBuilder<bool>(
                //   valueListenable:
                //       callAvailabilityNotifiers["isPrivateCallAvailable"]!,
                //   builder: (context, isEnabled, child) {
                //     return ListTile(
                //       onTap: () {
                //         log("isEnable:$isEnabled");
                //         updateCallAvailability("isPrivateCallAvailable");
                //       },
                //       leading: CircleAvatar(
                //         backgroundColor: Resources.colors.buttonColor,
                //         child: const Icon(
                //           Icons.wifi_calling,
                //           color: Colors.white,
                //         ),
                //       ),
                //       title: Text(
                //         'Private Call',
                //         style: Resources.styles.kTextStyle12B(Colors.black),
                //       ),
                //       subtitle: Text(
                //         'Consultant on Video and you on audio. No one else can hear.',
                //         style: Resources.styles.kTextStyle14(Colors.grey),
                //       ),
                //       trailing: Container(
                //         height: Resources.dimens.height(context) * 0.05,
                //         width: Resources.dimens.width(context) * 0.2,
                //         decoration: Resources.styles.kBoxDecoration(
                //           isEnabled
                //               ? Resources.colors.buttonColor
                //               : Colors.grey,
                //         ),
                //         child: Center(
                //           child: Text(
                //             isEnabled ? 'Enable' : 'Disable',
                //             textAlign: TextAlign.center,
                //             style: Resources.styles.kTextStyle14B5(
                //               Colors.white,
                //             ),
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  // method for delete single group
  Future<void> deleteSingleGroup(String groupId) async {
    try {
      await ChatClient.getInstance.groupManager.destroyGroup(groupId);
      print("Group $groupId deleted successfully");
    } on ChatError catch (e) {
      print("Failed to delete group $groupId: ${e.code} - ${e.description}");
    }
  }
}
