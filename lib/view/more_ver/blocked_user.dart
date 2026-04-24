
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/blocked/user_bloc.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class BlockedUser extends StatefulWidget {
  const BlockedUser({super.key});

  @override
  State<BlockedUser> createState() => _BlockedUserState();
}

class _BlockedUserState extends State<BlockedUser> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<BlockedBloc>().add(BlockedGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Blocked User",
          style: Resources.styles.kTextStyle16B(Resources.colors.blackColor),
        ),
      ),
      body: BlocConsumer<BlockedBloc, BlockedState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BlockedLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                  color: Resources.colors.buttonColor),
            );
          } else if (state is BlockedGetState) {
            final blockedData = state.blocked;

            if (blockedData.isEmpty) {
              return Center(
                child: Text('No Blocked User Available',
                    style: Resources.styles.kTextStyle14B(Colors.black)),
              );
            }

            return ListView.separated(
                itemCount: blockedData.length,
                separatorBuilder: (context, index) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Divider()),
                itemBuilder: (context, index) {
                  final data = blockedData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          data.avatar != null && data.avatar!.isNotEmpty
                              ? NetworkImage(
                                  "${AppUrl.baseUrl}/images/${data.avatar}")
                              : AssetImage(Resources.images.noImage)
                                  as ImageProvider,
                    ),
                    title: Text(
                      "${data.name ?? ""} ${data.lastName ?? ""}",
                      style: Resources.styles.kTextStyle14B(Colors.black),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                textAlign: TextAlign.center,
                                "Unblock User",
                                style: Resources.styles
                                    .kTextStyle16B(Colors.black),
                              ),
                              content: Text(
                                "Are you sure you want to unblock this user?",
                                style: Resources.styles
                                    .kTextStyle14B5(Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "No",
                                    style: Resources.styles.kTextStyle16B(
                                        Resources.colors.themeColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {

                                    Repository().userUnBlock(
                                       data.id.toString()
                                    ).then((value){
                                     Navigator.pop(context);
                                     Fluttertoast.showToast(msg: "${value["message"]}",
                                         backgroundColor:Resources.colors.buttonColor );
                                     context.read<BlockedBloc>().add(BlockedGetEvent());
                                    });
                                  },
                                  child: Text(
                                    "Yes",
                                    style: Resources.styles.kTextStyle16B(
                                        Resources.colors.buttonColor),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * .2,
                        height: MediaQuery.of(context).size.height * .04,
                        decoration: BoxDecoration(
                          color: Resources.colors.buttonColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                           "Blocked",
                          style: Resources.styles.kTextStyle14B(Colors.white),
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return Center(
              child: Text('Something went wrong!',
                  style: Resources.styles.kTextStyle14B(Colors.red)),
            );
          }
        },
      ),
    );
  }
}
