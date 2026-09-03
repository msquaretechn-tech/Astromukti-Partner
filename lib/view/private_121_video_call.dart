import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/call_timer/call_timer_bloc.dart';
import '../repository/repository.dart';
import '../resources/resources.dart';
import '../resources/string.dart';
import '../routes/routes_name.dart';
import '../services/notification_service.dart';
import 'kundli/kundli.dart';

class Private121VideoCall extends StatefulWidget {
  final Map<String, dynamic> mData;
  // Present only when the customer's app called /api/call/start - an
  // un-updated customer app still rings the old way with none of these, and
  // _initAgoraLive()/leave() below fall back to the legacy channel/token
  // scheme.
  final String? channelId;
  final String? rtcToken;
  final int? agoraUid;

  const Private121VideoCall({
    super.key,
    required this.mData,
    this.channelId,
    this.rtcToken,
    this.agoraUid,
  });

  @override
  State<Private121VideoCall> createState() => _Private121VideoCallState();
}

class _Private121VideoCallState extends State<Private121VideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  var dob;
  var name;
  var gender;
  var dot;
  var dop;
  bool _isMuted = false;
  String channelId = '';
  Timer? _heartbeatTimer;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    log('mData : ${widget.mData["extra"]}');
    log('pankaj : ${widget.mData}');
    channelId = widget.channelId ??
        "${widget.mData["extra"]['vendorId'].toString()}${widget.mData["extra"]['userId'].toString()}";
    _initAgoraLive();
    BlocProvider.of<AuthBloc>(context).add(ProfileUpdateEvent(formData: const {
      "isVideoCallAvailable": false,
      "isNowAvailable": false
    }, files: const []));
    NotificationService.dismissNotifications();
  }

  Future<void> _initAgoraLive() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("onUser $remoteUid");
          setState(() {
            _remoteUid = remoteUid;
          });
          context.read<CallTimerBloc>().add(CallStartEvent());

          // Confirms to the server that both sides are actually connected -
          // idempotent, safe even if the customer's app already triggered
          // this from their own onUserJoined. No-op for a call from an
          // un-updated customer app (no channelId, no server-side session).
          if (widget.channelId != null) {
            Repository().markCallJoined(widget.channelId!).catchError((e) {
              log("markCallJoined failed: $e");
            });
            _heartbeatTimer?.cancel();
            _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
              try {
                final result = await Repository().callHeartbeat(widget.channelId!);
                // Server force-ends a call once the customer's wallet runs
                // out mid-call (see call.controller.js) - without this
                // check the Agora session would just keep running for
                // free, since nothing else here would notice.
                if (result['callEnded'] == true) {
                  Fluttertoast.showToast(msg: "Call ended - customer balance exhausted");
                  context.read<CallTimerBloc>().add(CallEndEvent());
                }
              } catch (e) {
                log("Heartbeat failed: $e");
              }
            });
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("onUserOffline $remoteUid");
          setState(() {
            _remoteUid = null;
          });

          context.read<CallTimerBloc>().add(CallEndEvent());
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

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
      joinUid = math.Random().nextInt(1000000000);
      token = await Repository().generateRTCToken(channelId, 'audience', '$joinUid');
    }

    await _engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: joinUid,
      options: const ChannelMediaOptions(),
    );
    dob = widget.mData["extra"]["msg"].split(",")[1];
    dot = widget.mData["extra"]["msg"].split(",")[2];
    dop = widget.mData["extra"]["msg"].split(",")[3];
    name = widget.mData["extra"]["msg"].split(",")[4];
    gender = widget.mData["extra"]["msg"].split(",")[5];
    log("dob : $dob");
    log("dot : $dot");
    log("dop : $dop");
    userCallDetails();
  }

  @override
  void dispose() {
    super.dispose();
    leave();
  }

  Future<void> leave() async {
    _remoteUid = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Report this call session as over - best effort, mirrors the customer
    // app's _reportCallEnd(). Only applicable when this call went through
    // the new session-based flow (channelId present).
    if (widget.channelId != null) {
      try {
        await Repository().endCallSession(widget.channelId!, disconnectedBy: 'vendor');
      } catch (e) {
        log("Error ending call session: $e");
      }
    }

    await _engine.leaveChannel();
    await _engine.release();
    // context.read<CallTimerBloc>().add(CallEndEvent());
    await Repository().updateProfile({
      "isChatAvailable": true,
      "isVideoCallAvailable": true,
      "isAudioCallAvailable": true,
      "isNowAvailable": true,
      "isOnline": true,
    }, []);
    NotificationService.dismissNotifications();
  }

  @override
  Widget build(BuildContext context) {
    print("channelIds$channelId");
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: _remoteVideo()),
            _localPreview(),

            _callTimer(),
            _callControls(),
          ],
        ),
      ),
    );
  }

  // Local video preview
  Widget _localPreview() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.black,
          ),
          child: Center(
            child: _localUserJoined
                ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
                useFlutterTexture: true,
                useAndroidSurfaceView: true,
              ),
            )
                : const CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Call timer display
  Widget _callTimer() {
    return Positioned(
      top: 20,
      right: 20,
      child: BlocConsumer<CallTimerBloc, CallTimerState>(
        listener: (context, state) async {
          if (state is CallEndState) {
            // Route through leave() (not a bare engine.leaveChannel()) so
            // the server-side session-end report and heartbeat cleanup
            // above actually fire for every trigger that reaches this
            // listener - dispose() also calls leave(), which is a safe,
            // idempotent no-op the second time.
            await leave();
            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          String time = '00:00';
          if (state is CallStartState) {
            time = state.time.toString();
          }
          return Chip(
            backgroundColor: Colors.black54,
            label: Column(
              children: [
                widget.mData["extra"]["isNewUser"].toString()=="true"
                    ? Text(
                  "New User",
                  style: Resources.styles.kTextStyle16B(Colors.white),
                )
                    : const SizedBox.shrink(),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Call control buttons
  Widget _callControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _controlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              onTap: () {
                setState(() {
                  _isMuted = !_isMuted;
                  _engine.muteLocalAudioStream(_isMuted);
                });
              },
            ),
            _controlButton(
              icon: Icons.call_end,
              color: Colors.red,
              onTap: () {
                context.read<CallTimerBloc>().add(CallEndEvent());
              },
            ),
            _controlButton(
              icon: Icons.switch_camera,
              color: Colors.white,
              onTap: () {
                _engine.switchCamera();
              },
            ),
            InkWell(
              onTap: () async {
                EasyLoading.show(
                    status: 'loading...',
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.clear);
                try {
                  // Fetch latitude and longitude from the city name (dop)
                  List<Location> locations = await locationFromAddress(dop);
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
                backgroundColor: Resources.colors.buttonColor,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).pushNamed(
                    RoutesName.matching,
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Resources.colors.themeColor,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
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
          ],
        ),
      ),
    );
  }

  // Control button widget
  Widget _controlButton(
      {required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.black54,
      ),
      onPressed: onTap,
      child: Icon(icon, color: color, size: 28),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelId),
          ),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Waiting for remote user to join...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
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
                      Text("Name     : ",
                          style: Resources.styles.kTextStyle14B(Colors.black)),
                      Text("$name",
                          style: Resources.styles.kTextStyle14B(Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Gender : ",
                          style: Resources.styles.kTextStyle14B(Colors.black)),
                      Text("$gender",
                          style: Resources.styles.kTextStyle14B(Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Date of Birth : ",
                          style: Resources.styles.kTextStyle14B(Colors.black)),
                      Text("$dob",
                          style: Resources.styles.kTextStyle14B(Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Time of Birth : ",
                          style: Resources.styles.kTextStyle14B(Colors.black)),
                      Text("$dot",
                          style: Resources.styles.kTextStyle14B(Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Place of Birth :",
                          style: Resources.styles.kTextStyle14B(Colors.black)),
                      Text(" $dop",
                          style: Resources.styles.kTextStyle14B(Colors.grey)),
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
        });
  }
}
