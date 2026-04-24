import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astro_mukti/utils/utils.dart';

import '../../bloc/notification/notification_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../widgets/chat_ringtone.dart';
import 'chat_page.dart';

// final RingtonePlayer ringtonePlayer = RingtonePlayer();

class ChatUserList extends StatefulWidget {
  const ChatUserList({super.key});

  @override
  State<ChatUserList> createState() => _ChatUserListState();
}

class _ChatUserListState extends State<ChatUserList> {
  dynamic totalChatsUsers;

  @override
  void initState() {
    super.initState();
    getTotalUser();
  }

  Future<void> getTotalUser() async {
    totalChatsUsers = await Repository().getTotalChats();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Chat List",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
      ),
      body: totalChatsUsers == null
          ? Center(
        child: CircularProgressIndicator(
          color: Resources.colors.buttonColor,
        ),
      )
          : totalChatsUsers["data"].isEmpty
          ? Center(
        child: Text(
          "No Data Available",
          style: Resources.styles.kTextStyle14B(Colors.black),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        itemCount: totalChatsUsers["data"].length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final data = totalChatsUsers["data"][index];

          return BlocConsumer<NotificationBloc, NotificationState>(
            listener: (_, __) {},
            builder: (context, state) {
              int userCounter = 0;
              if (state is NotificationUpdateState) {
                userCounter =
                    state.userCounters["${data['admin']["_id"]}"] ??
                        0;
              }

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (userCounter == 0) {
                    Fluttertoast.showToast(
                      msg: "User Inactive",
                      backgroundColor:
                      Resources.colors.buttonColor,
                    );
                    return;
                  }

                  final vendorId = PrefService().getRegId();
                  final v = await Repository().getAvailability(
                    vendorId,
                  );

                  if (v['isChatAvailable'] == true ||
                      v["chatGroupId"] ==
                          data["admin"]["_id"]) {
                    await ChatRingTone().stopRingtone();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          userDetails: data['admin'],
                          chatId: data["_id"],
                        ),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "You can chat only once at a time",
                      backgroundColor:
                      Resources.colors.buttonColor,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Resources.colors.themeColor,
                      width: .3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Resources.colors.themeColor
                            .withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                        (data["admin"]?["avatar"] != null &&
                            data["admin"]["avatar"]
                                .toString()
                                .isNotEmpty)
                            ? NetworkImage(
                          "${AppUrl.baseUrl}/images/${data["admin"]["avatar"]}",
                        )
                            : AssetImage(
                          Resources.images.noImage,
                        ) as ImageProvider,
                      ),

                      const SizedBox(width: 12),

                      /// Name + Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data['admin']["name"]} ${data['admin']["lastName"] ?? ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                              Resources.styles.kTextStyle14B(
                                Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Utils().formatDates(
                                "${data["createdAt"]}",
                              ),
                              style:
                              Resources.styles.kTextStyle10(
                                Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Badge
                      if (userCounter != 0)
                        Badge(
                          backgroundColor:
                          Resources.colors.greenColor,
                          label: Text(
                            "$userCounter",
                            style:
                            const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

