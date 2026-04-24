import 'dart:developer';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../bloc/follow/follow_block.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    context.read<FollowBloc>().add(FollowGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Followers",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
      ),
      body: BlocConsumer<FollowBloc, FollowState>(
        listener: (context, state) {},
        builder: (context, state) {
          log("state:$state");
          if (state is FollowLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                  color: Resources.colors.buttonColor),
            );
          } else if (state is FollowGetState) {
            final followData = state.follow;

            if (followData.isEmpty) {
              return Center(
                child: Text('No Data Available',
                    style: Resources.styles.kTextStyle14B(Colors.black)),
              );
            }

            return RefreshIndicator(
              backgroundColor: Resources.colors.buttonColor,
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: followData.length,
                itemBuilder: (context, index) {
                  var followItem = followData[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Resources.colors.buttonColor.withOpacity(.5),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: followItem
                                            .followerDetails!.avatar !=
                                        null &&
                                    followItem
                                        .followerDetails!.avatar!.isNotEmpty
                                ? NetworkImage(
                                    "${AppUrl.baseUrl}/images/${followItem.followerDetails!.avatar}")
                                : AssetImage(Resources.images.noImage)
                                    as ImageProvider,
                          ),
                        ),
                        title: Text(
                          "${followItem.followerDetails!.name} ${followItem.followerDetails!.lastName}" ,
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                        trailing: Text(
                          "Follow",
                          style: Resources.styles.kTextStyle14B(Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
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
