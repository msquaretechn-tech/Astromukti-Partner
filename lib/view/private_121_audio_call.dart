



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
import 'kundli/kundli.dart';

class Private121AudioCall extends StatefulWidget {
  final Map<String, dynamic> mData;
  // Present only when the customer's app called /api/call/start - an
  // un-updated customer app still rings the old way with none of these, and
  // join()/leave() below fall back to the legacy channel/token scheme.
  final String? channelId;
  final String? rtcToken;
  final int? agoraUid;

  static RtcEngine? staticAgoraEngine;
  static bool staticIsJoined = false;
  static Map<String, dynamic>? staticMData;
  static int? staticRemoteUid;
  static final ValueNotifier<Map<String, dynamic>?> activeCallNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);
  static bool staticIsMuted = false;
  static bool staticIsSpeakerEnabled = false;
  // Mirrors the other static fields above - leave() is static (it's also
  // called from main.dart's global CallTimerBloc listener, for when the
  // astrologer has navigated away from this screen entirely), so the
  // call-session id and heartbeat timer it needs to clean up have to be
  // static too, not instance fields.
  static String? staticChannelId;
  static Timer? staticHeartbeatTimer;

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

    Private121AudioCall.staticHeartbeatTimer?.cancel();
    Private121AudioCall.staticHeartbeatTimer = null;

    // Report this call session as over - best effort, mirrors the customer
    // app's _reportCallEnd(). Only applicable when this call went through
    // the new session-based flow (channelId present); a call from an
    // un-updated customer app never created a server-side CallSession at
    // all, so there's nothing to report here.
    final endingChannelId = Private121AudioCall.staticChannelId;
    if (endingChannelId != null) {
      Repository()
          .endCallSession(endingChannelId, disconnectedBy: 'vendor')
          .catchError((e) {
        log("Error ending call session: $e");
      });
    }
    Private121AudioCall.staticChannelId = null;

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

  const Private121AudioCall({
    super.key,
    required this.mData,
    this.channelId,
    this.rtcToken,
    this.agoraUid,
  });

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
    Private121AudioCall.staticChannelId = widget.channelId;


    _isMuted = Private121AudioCall.staticIsMuted;
    isSpeakerEnabled = Private121AudioCall.staticIsSpeakerEnabled;

    // channelId (server-generated) when present; falls back to the legacy
    // mobile-concatenation scheme for a call from an un-updated customer app.
    channelName = widget.channelId ??
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

          // Confirms to the server that both sides are actually connected -
          // idempotent, safe even if the customer's app already triggered
          // this from their own onUserJoined. No-op for a call from an
          // un-updated customer app (no channelId, no server-side session).
          if (Private121AudioCall.staticChannelId != null) {
            Repository()
                .markCallJoined(Private121AudioCall.staticChannelId!)
                .catchError((e) {
              log("markCallJoined failed: $e");
            });
            Private121AudioCall.staticHeartbeatTimer?.cancel();
            Private121AudioCall.staticHeartbeatTimer =
                Timer.periodic(const Duration(seconds: 15), (_) async {
              try {
                final result = await Repository()
                    .callHeartbeat(Private121AudioCall.staticChannelId!);
                // Server force-ends a call once the customer's wallet runs
                // out mid-call (see call.controller.js) - without this
                // check the Agora session would just keep running for
                // free, since nothing else here would notice.
                if (result['callEnded'] == true) {
                  Fluttertoast.showToast(msg: "Call ended - customer balance exhausted");
                  navigationKey.currentContext?.read<CallTimerBloc>().add(CallEndEvent());
                  Private121AudioCall.leave();
                }
              } catch (e) {
                log("Heartbeat failed: $e");
              }
            });
          }
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

          navigationKey.currentContext?.read<CallTimerBloc>().add(CallEndEvent());
          Private121AudioCall.leave();
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

    String token;
    int joinUid;
    if (widget.rtcToken != null && widget.agoraUid != null) {
      // New flow: token/uid already fetched via GET /api/call/:channelId/token
      // (see CallKitService's accept handler) before this screen was pushed.
      token = widget.rtcToken!;
      joinUid = widget.agoraUid!;
    } else {
      // Legacy fallback - a call from an un-updated customer app that never
      // called /api/call/start, so there's no server-issued token to use.
      final fetchedToken = await Repository().generateRTCToken(
        channelName,
        'publisher',
        uid.toString(),
      );
      if (fetchedToken == null || fetchedToken.isEmpty) {
        Fluttertoast.showToast(msg: "Service not available");
        return;
      }
      token = fetchedToken;
      joinUid = uid;
    }

    await Private121AudioCall.staticAgoraEngine!.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: joinUid,
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
            onPressed: () async {
              Repository().updateProfile({
                "isChatAvailable": "true",
                "isVideoCallAvailable": "true",
                "isAudioCallAvailable": "true",
                "isNowAvailable": "true",
                "isOnline": "true",
              }, []);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('call_data');
              NotificationService.sendNotification(
                "${widget.mData["extra"]["userFcmToken"]}",
                "Call Declined",
                "Call Declined By Astrologer",
                <String, dynamic>{},
              );
              log("ggg ${widget.mData["extra"]["userFcmToken"]}");
              log("kya haaa ${widget.mData}");
              Navigator.pop(context, true);
            },
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
      context.read<CallTimerBloc>().add(CallEndEvent());
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
