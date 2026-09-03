



import 'dart:developer';
import 'dart:async';
import 'package:astro_mukti/view/widgets/sensor_management.dart';

import '../main.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/call_timer/call_timer_bloc.dart';
import '../repository/repository.dart';
import '../resources/app_url.dart';
import '../resources/resources.dart';
import '../resources/string.dart';
import '../services/notification_service.dart';
import '../services/call_kit_incoming.dart';
import 'kundli/kundli.dart';

class Private121AudioCall extends StatefulWidget {
  final Map<String, dynamic> mData;

  static RtcEngine? staticAgoraEngine;
  static bool staticIsJoined = false;
  static Map<String, dynamic>? staticMData;
  static int? staticRemoteUid;
  static final ValueNotifier<Map<String, dynamic>?> activeCallNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);
  static bool staticIsMuted = false;
  static bool staticIsSpeakerEnabled = false;

  static const _channel = MethodChannel('com.bookmyastro.app.channel');

  static Future<void> startCallService() async {
    try {
      await _channel.invokeMethod('startCallService');
      print(" starting foreground service:");
    } catch (e) {
      print("Error starting foreground service: $e");
    }
  }

  static Future<void> stopCallService() async {
    try {
      await _channel.invokeMethod('stopCallService');
      print(" stop foreground service:");
    } catch (e) {
      print("Error stopping foreground service: $e");
    }
  }

  static void leave() {
    Private121AudioCall.staticIsJoined = false;
    Private121AudioCall.staticRemoteUid = null;
    Private121AudioCall.staticMData = null;
    Private121AudioCall.activeCallNotifier.value = null;
    Private121AudioCall.staticIsMuted = false;
    Private121AudioCall.staticIsSpeakerEnabled = false;

    Repository().updateProfile({
      "isChatAvailable": "true",
      "isVideoCallAvailable": "true",
      "isAudioCallAvailable": "true",
      "isNowAvailable": "true",
      "isOnline": "true",
    }, []);

    Private121AudioCall.staticAgoraEngine?.leaveChannel();
    // Private121AudioCall.staticAgoraEngine?.release();
    Private121AudioCall.staticAgoraEngine = null;
    stopCallService();
    NotificationService.dismissNotifications();
  }

  const Private121AudioCall({super.key, required this.mData});

  @override
  State<Private121AudioCall> createState() => _Private121AudioCallState();
}

class _Private121AudioCallState extends State<Private121AudioCall> {

  String channelName = "";
  bool _showOverlay = true;
  bool _isMuted = false;
  int uid = 0;
  late AudioPlayer _audioPlayer;
  bool _hasPlayed15SecAlert = false;

  bool isSpeakerEnabled = false;
  bool _callEnded = false;
  SensorManagement sensorManagement = SensorManagement();

  // for kundli , match making user details storage
  var dob;
  var name;
  var gender;
  var dot;
  var dop;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Private121AudioCall.staticMData = widget.mData;
      Private121AudioCall.activeCallNotifier.value = widget.mData;
    });


    _isMuted = Private121AudioCall.staticIsMuted;
    isSpeakerEnabled = Private121AudioCall.staticIsSpeakerEnabled;

    channelName =
    "${widget.mData["extra"]["vendorMobile"] ?? ''}${widget.mData["extra"]["userMobile"] ?? ''}";

    if (Private121AudioCall.staticAgoraEngine != null && Private121AudioCall.staticIsJoined) {
      log("Resuming existing call session");
    } else {
      setupVoiceSDKEngine().then((value) => join());
    }

    // Update astrologer's profile status to busy
    BlocProvider.of<AuthBloc>(context).add(
      ProfileUpdateEvent(
        formData: const {
          "isAudioCallAvailable": "false",
          "isNowAvailable": "false",
        },
        files: const [],
      ),
    );
    _audioPlayer = AudioPlayer();
    sensorManagement.startListening();
    KeepScreenOn.turnOn(withAllowLockWhileScreenOn: true);
    NotificationService.dismissNotifications();
  }


  Future<void> setupVoiceSDKEngine() async {
    await [Permission.microphone].request();

    Private121AudioCall.staticAgoraEngine = createAgoraRtcEngine();
    await Private121AudioCall.staticAgoraEngine!.initialize(
      RtcEngineContext(
        appId: AgoraConfig.appId,
        areaCode: AreaCode.areaCodeGlob.value(),
      ),
    );
    // Enable audio processing and background mode
    await Private121AudioCall.staticAgoraEngine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    // Set audio scenario for background audio
    await Private121AudioCall.staticAgoraEngine!.setAudioScenario(
      AudioScenarioType.audioScenarioGameStreaming,
    );

    // Enable audio in background
    await Private121AudioCall.staticAgoraEngine!.setParameters(
      '{"che.audio.keep.audiosession": true}',
    );
    await Private121AudioCall.staticAgoraEngine!.setParameters('{"che.audio.enable.agc": true}');
    await Private121AudioCall.staticAgoraEngine!.setParameters('{"che.audio.enable.ns": true}');

    Private121AudioCall.staticAgoraEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          log("Local user uid:${connection.localUid} joined the channel");
          await Future.delayed(const Duration(milliseconds: 300));

          await Private121AudioCall.staticAgoraEngine!.setEnableSpeakerphone(false);

          setState(() {
            isSpeakerEnabled = false;
            Private121AudioCall.staticIsSpeakerEnabled = false;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("Remote user uid:$remoteUid joined the channel");
          Private121AudioCall.staticRemoteUid = remoteUid;
          Private121AudioCall.staticIsJoined = true;

          final dynamic rawValue = widget.mData["extra"]["totalRemainingMinute"];
          double minutes = 0;
          if (rawValue is num) {
            minutes = rawValue.toDouble();
          } else if (rawValue is String) {
            minutes = double.tryParse(rawValue) ?? 0;
          }
          int totalSeconds = (minutes * 60).round();

          context.read<CallTimerBloc>().add(CallStartEvent(totalSeconds: totalSeconds));

          // _startCountdownTimer();
          Private121AudioCall.startCallService();
        },
        onUserOffline:
            (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
            ) async {
          log("Remote user uid:$remoteUid left the channel");
          Private121AudioCall.staticRemoteUid = null;
          Private121AudioCall.staticIsJoined = false;

          _endCallSession(fromRemote: true);
        },
        onError: (ErrorCodeType err, String msg) {
          log("Agora Audio Error: $err, Msg: $msg");
        },
      ),
    );
    // Set audio profile after initialization and scenario
    await Private121AudioCall.staticAgoraEngine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    await Private121AudioCall.staticAgoraEngine!.setAudioScenario(
      AudioScenarioType.audioScenarioGameStreaming,
    );
    await Private121AudioCall.staticAgoraEngine!.setParameters(
      '{"che.audio.keep.audiosession": true}',
    );
    await Private121AudioCall.staticAgoraEngine!.setParameters('{"che.audio.enable.agc": true}');
    await Private121AudioCall.staticAgoraEngine!.setParameters('{"che.audio.enable.ns": true}');
  }

  Future<void> join() async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    var token = await Repository().generateRTCToken(
      channelName,
      'publisher',
      uid.toString(),
    );

    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(msg: "Service not available");
      return;
    }

    await Private121AudioCall.staticAgoraEngine!.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );

    debugPrint("Joining channel: $channelName");

    if (widget.mData["extra"]["msg"] != null) {
      List<String> parts = widget.mData["extra"]["msg"].toString().split(",");
      if (parts.length > 5) {
        dob = parts[1];
        dot = parts[2];
        dop = parts[3];
        name = parts[4];
        gender = parts[5];
      }
      log("persnol data $dob ,$dot ,$dop ,$name, $gender");
      log("persnol data pankaj ${widget.mData["extra"]["msg"].toString}");
    }
  }




  @override
  void dispose() {
    // Covers the case where this screen is disposed without ever going
    // through one of the trigger sites above (e.g. the astrologer swipes
    // away the incoming-call notification, or navigates elsewhere before
    // answering) - without this, the native in-call notification (started
    // by CallKitService on accept) never gets cleared.
    if (!Private121AudioCall.staticIsJoined && !_callEnded) {
      _endCallSession(fromRemote: true);
    }
    _audioPlayer.stop();
    _audioPlayer.dispose();
    KeepScreenOn.turnOn(withAllowLockWhileScreenOn: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Private121AudioCall.staticIsJoined) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('call_data');
      }
    });
    sensorManagement.stopListening();
    super.dispose();
  }

  // Shared teardown for every end-of-call trigger (remote hangup, the local
  // "End Call" dialog, and disposal without ever connecting) - previously
  // each site duplicated its own mix of availability-PATCH / call_data-clear
  // / "Call Declined"-push logic, and none of them cleared the native
  // in-call notification CallKitService starts on accept (found via a real
  // end-to-end test: the astrologer's phone kept showing a live "Hang Up"
  // notification after the call had actually ended). Dispatching
  // CallEndEvent lets the existing CallTimerBloc listener in build() do its
  // own cleanup (prefs, notification, Private121AudioCall.leave(), pop) when
  // this screen is still mounted; call leave() directly here only when it
  // isn't, since nothing else would.
  void _endCallSession({bool fromRemote = false}) {
    if (_callEnded) return;
    _callEnded = true;
    log("Ending audio call session, fromRemote: $fromRemote");

    CallKitService.endAllCalls();

    if (navigationKey.currentContext != null) {
      try {
        navigationKey.currentContext!.read<CallTimerBloc>().add(CallEndEvent());
      } catch (e) {
        log("Error dispatching CallEndEvent from navigationKey: $e");
      }
    } else if (mounted) {
      try {
        context.read<CallTimerBloc>().add(CallEndEvent());
      } catch (e) {
        log("Error dispatching CallEndEvent from widget context: $e");
      }
    }

    if (!mounted) {
      Private121AudioCall.leave();
    }
  }

  void toggleSpeaker() async {
    // using sensor management
    isSpeakerEnabled = !isSpeakerEnabled;
    Private121AudioCall.staticIsSpeakerEnabled = isSpeakerEnabled;
    await Private121AudioCall.staticAgoraEngine!.setEnableSpeakerphone(isSpeakerEnabled);
    if (isSpeakerEnabled) {
      sensorManagement.stopListening();
    } else {
      await sensorManagement.startListening();
    }

    setState(() {}); // Update UI
  }



  void _showEndCallConfirmationDialog() async {
    final shouldEndCall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "End Call",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
        content: Text(
          "Are you sure you want to end the call?",
          style: Resources.styles.kTextStyle14B(Colors.black),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Resources.colors.themeColor,
            ),
            child: Text(
              "Cancel",
              style: Resources.styles.kTextStyle16B(Colors.white),
            ),
          ),
          ElevatedButton(
            // Previously this duplicated the profile-reset/prefs-clear/
            // notification logic the CallTimerBloc listener below already
            // does on CallEndState (with slightly different wording, and
            // the profile reset happening twice) - Navigator.pop(true) here
            // just closes the dialog; dispatching CallEndEvent below is
            // what actually ends the call and runs that cleanup once.
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              "End",
              style: Resources.styles.kTextStyle16B(Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldEndCall == true) {
      _endCallSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) return;
        // The call continues because leave() is NOT called in dispose()
        log("Navigated back, call continues in background");
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              CircleAvatar(
                radius: 50,
                backgroundImage:
                widget.mData["extra"]["userAvatar"] != null &&
                    widget.mData["extra"]["userAvatar"].isNotEmpty
                    ? NetworkImage(
                  "${AppUrl.baseUrl}/images/${widget.mData["extra"]["userAvatar"]}",
                )
                    : AssetImage(Resources.images.noImage) as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                "${widget.mData["nameCaller"]}",
                style: Resources.styles.kTextStyle16B(Colors.black),
              ),
              widget.mData["extra"]["isNewUser"].toString() == "true"
                  ? Text(
                "New User",
                style: Resources.styles.kTextStyle16B(Colors.black),
              )
                  : const SizedBox.shrink(),
              BlocConsumer<CallTimerBloc, CallTimerState>(
                listener: (context, state) async {
                  if (state is CallEndState) {
                    log("statess:$state");
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('call_data');
                    try {
                      NotificationService.sendNotification(
                        "${widget.mData["extra"]["userFcmToken"]}",
                        "Call Declined",
                        "Call Declined ",
                        <String, dynamic>{},
                      );
                    } catch (e) {
                      log("Error sending notification: $e");
                    }

                    // _countdownTimer?.cancel();
                    Private121AudioCall.leave(); // Call leave here when timer ends
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) Navigator.pop(context);
                    });
                  }
                },
                builder: (context, state) {
                  if (state is CallStartState) {
                    return Column(
                      children: [
                        Text(
                          state.remainingTime ?? "00:00",
                          style: Resources.styles.kTextStyle14(Colors.black),
                        ),
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Private121AudioCall.staticIsJoined
                                ? Text(
                              "Connected",
                              style: Resources.styles.kTextStyle14B(
                                Colors.grey,
                              ),
                            )
                                : Text(
                              "Not Connected",
                              style: Resources.styles.kTextStyle14B(
                                Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: Resources.dimens.width(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _showEndCallConfirmationDialog,
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.call, color: Colors.white, size: 21),
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleSpeaker,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(.3),
                          radius: 25,
                          child: Icon(
                            isSpeakerEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _isMuted = !_isMuted;
                          Private121AudioCall.staticIsMuted = _isMuted;
                          Private121AudioCall.staticAgoraEngine!.muteLocalAudioStream(_isMuted);
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.withOpacity(.3),
                          child: Icon(
                            _isMuted ? Icons.mic_off : Icons.mic,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
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
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(.3),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                Resources.images.kundliImage,
                                height: 25,
                                width: 25,

                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //   child: InkWell(
                      //     onTap: () {
                      //       GoRouter.of(context).pushNamed(RoutesName.matching);
                      //     },
                      //     child: CircleAvatar(
                      //       backgroundColor: Colors.grey.withOpacity(.3),
                      //       child: Container(
                      //         width: 35,
                      //         height: 35,
                      //         decoration: const BoxDecoration(
                      //           shape: BoxShape.circle,
                      //         ),
                      //         child: Center(
                      //           child: Image.asset(
                      //             Resources.images.matchMakingImage,
                      //             height: 25,
                      //             width: 25,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //   child: InkWell(
                      //     onTap: () {
                      //       GoRouter.of(context).pushNamed(
                      //         RoutesName.numerology,
                      //         extra: {
                      //           'name': name.toString(),
                      //           'dob': dob.toString(),
                      //         },
                      //       );
                      //     },
                      //     child: CircleAvatar(
                      //       backgroundColor: Colors.grey.withOpacity(.3),
                      //       child: Container(
                      //         width: 35,
                      //         height: 35,
                      //         decoration: const BoxDecoration(
                      //           shape: BoxShape.circle,
                      //         ),
                      //         child: Center(
                      //           child: Image.asset(
                      //             Resources.images.numerologyImage,
                      //             height: 30,
                      //             width: 30,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                    ],
                  ),
                ),
              ),

              // for astro match making and open kundli
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
