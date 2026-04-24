import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/view/widgets/sensor_management.dart';
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
import '../routes/routes_name.dart';
import '../services/notification_service.dart';
import 'kundli/kundli.dart';

class Private121AudioCall extends StatefulWidget {
  final Map<String, dynamic> mData;

  const Private121AudioCall({super.key, required this.mData});

  @override
  State<Private121AudioCall> createState() => _Private121AudioCallState();
}

class _Private121AudioCallState extends State<Private121AudioCall> {
  String channelName = "";
  bool _showOverlay = true;
  bool _isMuted = false;
  int uid = 0;
  int? _remoteUid;
  bool _isJoined = false;
  late RtcEngine agoraEngine;
  late AudioPlayer _audioPlayer;
  bool _hasPlayed15SecAlert = false;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  bool isSpeakerEnabled = false;
  SensorManagement sensorManagement = SensorManagement();

  // for kundli , match making user details storage
  var dob;
  var name;
  var gender;
  var dot;
  var dop;

  // for static
  int _secondsElapsed = 0;
  Timer? _staticTimer;
  bool _isTimerRunning = false;

  void _startStaticTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;

    _staticTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopStaticTimer() {
    _staticTimer?.cancel();
    _isTimerRunning = false;
    _secondsElapsed = 0;
  }

  String _formatStaticDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  // end static timer
  @override
  void initState() {
    super.initState();

    channelName =
        "${widget.mData["extra"]["vendorMobile"] ?? ''}${widget.mData["extra"]["userMobile"] ?? ''}";

    setupVoiceSDKEngine().then((value) => join());

    // Update astrologer's profile status to busy
    BlocProvider.of<AuthBloc>(context).add(
      ProfileUpdateEvent(
        formData: const {
          "isAudioCallAvailable": false,
          "isNowAvailable": false,
        },
        files: const [],
      ),
    );
    _audioPlayer = AudioPlayer();
    sensorManagement.startListening();
    KeepScreenOn.turnOn(withAllowLockWhileScreenOn: true);
  }

  final _channel = const MethodChannel('com.bookmyastro.app.channel');

  Future<void> _startCallService() async {
    try {
      await _channel.invokeMethod('startCallService');
      print(" starting foreground service:");
    } catch (e) {
      print("Error starting foreground service: $e");
    }
  }

  Future<void> _stopCallService() async {
    try {
      await _channel.invokeMethod('stopCallService');
      print(" stop foreground service:");
    } catch (e) {
      print("Error stopping foreground service: $e");
    }
  }

  Future<void> setupVoiceSDKEngine() async {
    await [Permission.microphone].request();

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
      RtcEngineContext(
        appId: AgoraConfig.appId,
        areaCode: AreaCode.areaCodeGlob.value(),
      ),
    );
    // Enable audio processing and background mode
    await agoraEngine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    // Set audio scenario for background audio
    await agoraEngine.setAudioScenario(
      AudioScenarioType.audioScenarioGameStreaming,
    );

    // Enable audio in background
    await agoraEngine.setParameters('{"che.audio.keep.audiosession": true}');
    await agoraEngine.setParameters('{"che.audio.enable.agc": true}');
    await agoraEngine.setParameters('{"che.audio.enable.ns": true}');

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          log("Local user uid:${connection.localUid} joined the channel");
          await Future.delayed(const Duration(milliseconds: 300));

          await agoraEngine.setEnableSpeakerphone(false);

          setState(() {
            isSpeakerEnabled = false;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("Remote user uid:$remoteUid joined the channel");
          _remoteUid = remoteUid;
          _isJoined = true;

          context.read<CallTimerBloc>().add(CallStartEvent());

          _startCountdownTimer();
          _startCallService();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) async {
              log("Remote user uid:$remoteUid left the channel");
              _remoteUid = null;
              _isJoined = false;

              if (mounted) {
                context.read<CallTimerBloc>().add(CallEndEvent());
              }
            },
        onError: (ErrorCodeType err, String msg) {
          log("Agora Audio Error: $err, Msg: $msg");
        },
      ),
    );
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

    await agoraEngine.joinChannel(
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
      log(
        "dobnn: $dob, dot: $dot, dop: $dop, name: $name, gender: $gender, user details for kundli: ${widget.mData["extra"]}",
      );
    }
    userCallDetails();
  }



  void leave() {
    _isJoined = false;
    _remoteUid = null;

    Repository().updateProfile({
      "isChatAvailable": true,
      "isVideoCallAvailable": true,
      "isAudioCallAvailable": true,
      "isNowAvailable": true,
      "isOnline": true,
    }, []);

    agoraEngine.leaveChannel();
    // agoraEngine.release(); // Keep this commented or released properly
    _stopCallService();
  }

  @override
  void dispose() {
    leave();
    _countdownTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    KeepScreenOn.turnOff(withAllowLockWhileScreenOn: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('call_data');
    });
    sensorManagement.stopListening();
    super.dispose();
  }

  // void toggleSpeaker() async {
  //   isSpeakerEnabled = !isSpeakerEnabled;
  //   await agoraEngine.setEnableSpeakerphone(isSpeakerEnabled);
  //
  //   setState(() {});
  // }
  void toggleSpeaker() async {
    // using sensor management
    isSpeakerEnabled = !isSpeakerEnabled;
    await agoraEngine.setEnableSpeakerphone(isSpeakerEnabled);
    if (isSpeakerEnabled) {
      sensorManagement.stopListening();
    } else {
      await sensorManagement.startListening();
    }

    setState(() {}); // Update UI
  }

  void _startCountdownTimer() {
    final dynamic rawValue = widget.mData["extra"]["totalRemainingMinute"];

    // Try parsing to double, default to 0 if invalid
    double minutes = 0;
    if (rawValue is num) {
      minutes = rawValue.toDouble();
    } else if (rawValue is String) {
      minutes = double.tryParse(rawValue) ?? 0;
    }

    _remainingSeconds = (minutes * 60).round();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        context.read<CallTimerBloc>().add(CallEndEvent());
      } else {
        if (_remainingSeconds == 15 && !_hasPlayed15SecAlert) {
          _hasPlayed15SecAlert = true;

          // Play your alert sound here
          await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));
          // Stop the sound after 14 seconds
          Future.delayed(const Duration(seconds: 14), () {
            _audioPlayer.stop();
          });
        }
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
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
              style: Resources.styles.kTextStyle16B(Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              EasyLoading.show(status: "Ending call...");
              await Repository().updateProfile({
                "isChatAvailable": true,
                "isVideoCallAvailable": true,
                "isAudioCallAvailable": true,
                "isNowAvailable": true,
                "isOnline": true,
              }, []);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('call_data');
              NotificationService.sendNotification(
                "${widget.mData["extra"]["userFcmToken"]}",
                "Call Declined",
                "Call Declined ",
                <String, dynamic>{},
              );
              EasyLoading.dismiss();
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
    return Scaffold(
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
            // BlocConsumer<CallTimerBloc, CallTimerState>(
            //   listener: (context, state) async {
            //     if (state is CallEndState) {
            //       log("statess:$state");
            //       final prefs = await SharedPreferences.getInstance();
            //       await prefs.remove('call_data');
            //       try {
            //         NotificationService.sendNotification(
            //           "${widget.mData["extra"]["userFcmToken"]}",
            //           "Call Declined",
            //           "Call Declined ",
            //           <String, dynamic>{},
            //         );
            //       } catch (e) {
            //         log("Error sending notification: $e");
            //       }
            //
            //       _countdownTimer?.cancel();
            //       WidgetsBinding.instance.addPostFrameCallback((_) {
            //         if (mounted) Navigator.pop(context);
            //       });
            //     }
            //   },
            //   builder: (context, state) {
            //     if (state is CallStartState) {
            //       return Column(
            //         children: [
            //           Text(
            //             _formatDuration(_remainingSeconds),
            //             style: Resources.styles.kTextStyle14(Colors.black),
            //           ),
            //           SizedBox(
            //             height: 40,
            //             child: Center(
            //               child: _isJoined
            //                   ? Text(
            //                       "Connected",
            //                       style: Resources.styles.kTextStyle14B(
            //                         Colors.grey,
            //                       ),
            //                     )
            //                   : Text(
            //                       "Not Connected",
            //                       style: Resources.styles.kTextStyle14B(
            //                         Colors.grey,
            //                       ),
            //                     ),
            //             ),
            //           ),
            //         ],
            //       );
            //     }
            //     return const SizedBox.shrink();
            //   },
            // ),
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
                      "Call Declined",
                      <String, dynamic>{},
                    );
                  } catch (e) {
                    log("Error sending notification: $e");
                  }

                  _stopStaticTimer();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) Navigator.pop(context);
                  });
                }

                if (state is CallStartState && _isJoined) {
                  // start timer only when actually connected
                  _startStaticTimer();
                }
              },
              builder: (context, state) {
                if (state is CallStartState) {
                  return Column(
                    children: [
                      Text(
                        _formatStaticDuration(_secondsElapsed),
                        style: Resources.styles.kTextStyle14(Colors.black),
                      ),
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: _isJoined
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
                          isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _isMuted = !_isMuted;
                        agoraEngine.muteLocalAudioStream(_isMuted);
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
                    // InkWell(
                    //   onTap: () async {
                    //     EasyLoading.show(
                    //       status: 'loading...',
                    //       dismissOnTap: false,
                    //       maskType: EasyLoadingMaskType.clear,
                    //     );
                    //     try {
                    //       // Fetch latitude and longitude from the city name (dop)
                    //       List<Location> locations = await locationFromAddress(
                    //         dop,
                    //       );
                    //       if (locations.isNotEmpty) {
                    //         double latitude = locations[0].latitude;
                    //         double longitude = locations[0].longitude;
                    //         log("Latitude: $latitude, Longitude: $longitude");
                    //         EasyLoading.dismiss();
                    //         // Navigate to the next screen with the latitude and longitude
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => ZodiacSign(
                    //               dob: dob,
                    //               dot: dot,
                    //               dop: dop,
                    //               name: name,
                    //               gender: gender,
                    //               latitude: latitude,
                    //               longitude: longitude,
                    //             ),
                    //           ),
                    //         );
                    //       } else {
                    //         EasyLoading.dismiss();
                    //         log("No locations found for the given address.");
                    //       }
                    //     } catch (e) {
                    //       EasyLoading.dismiss();
                    //       log("Error fetching location: $e");
                    //     }
                    //   },
                    //   child: CircleAvatar(
                    //     backgroundColor: Colors.grey.withOpacity(.3),
                    //     child: Container(
                    //       width: 35,
                    //       height: 35,
                    //       decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: Center(
                    //         child: Image.asset(
                    //           Resources.images.kundliImage,
                    //           height: 25,
                    //           width: 25,
                    //           color: Colors.red,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
                    //             color: Colors.red,
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
                    //             height: 25,
                    //             width: 25,
                    //             color: Colors.red,
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
                    SizedBox(width: 15),
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
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("Cancel ",
                              style: Resources.styles
                                  .kTextStyle16B(Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      onTap: () async {
                        EasyLoading.show(
                            status: 'loading...',
                            dismissOnTap: false,
                            maskType: EasyLoadingMaskType.clear);
                        try {
                          // Fetch latitude and longitude from the city name (dop)
                          List<Location> locations =
                          await locationFromAddress(dop);
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
