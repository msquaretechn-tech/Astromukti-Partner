import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:astro_mukti/routes/routes_name.dart';
import 'package:astro_mukti/view/drawer.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';

import '../../bloc/home/home_bloc.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';

class MyBlog extends StatefulWidget {
  const MyBlog({super.key});

  @override
  State<MyBlog> createState() => _MyBlogState();
}

class _MyBlogState extends State<MyBlog> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<HomeBloc>().add(GetVendorBlogDetailsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerPage(),

      appBar: AppbarProfile(
        userName: "My Blog",
        actions: [TextButton(onPressed: () {
          GoRouter.of(context).pushNamed(RoutesName.addBlog, extra: "Create Blog");
        }, child: Text("Create Blog",
          style: TextStyle(fontSize: 16, color: Colors.black),))],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          log("Bloc Listener: $state");
        },
        builder: (context, state) {
          log("Bloc Builder: $state");

          if (state is HomeLoadingState) {
            // 🔹 Show loader while fetching
            return Center(
              child: CircularProgressIndicator(
                color: Resources.colors.buttonColor,
              ),
            );
          } else if (state is GetBlogListSuccessState) {
            final blogList = state.blogList;

            if (blogList.isEmpty) {
              return const Center(
                child: Text(
                  "No blogs available",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            // 🔹 Show list of blogs
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: blogList.length,
              itemBuilder: (context, index) {
                final blog = blogList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: .1,
                        color: Resources.colors.themeColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Resources.colors.themeColor.withValues(
                            alpha: 0.5,
                          ),
                          spreadRadius: 2,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Blog Image
                        if (blog.image != null && blog.image!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              "${AppUrl.baseUrl}/images/${blog.image}",
                              height: Resources.dimens.height(context) * 0.2,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;

                                return Container(
                                  height: Resources.dimens.height(context) * 0.2,
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child:  CircularProgressIndicator(
                                    color: Resources.colors.buttonColor,
                                    strokeWidth: .8,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: Resources.dimens.height(context) * 0.2,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),


                        const SizedBox(height: 8),

                        // 🔹 Title + Delete Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  blog.title ?? "No Title",
                                  style: Resources.styles.kTextStyle14B(
                                    Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  context.read<HomeBloc>().add(
                                    DeleteBlogEvent(
                                      documentId: blog.id.toString(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 🔹 Description
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Text(
                            blog.description ?? "No description",
                            style: Resources.styles.kTextStyle12(
                              Colors.black54,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is HomeErrorState) {
            // 🔹 Error state
            return Center(
              child: Text(
                "Failed to load blogs.\n${state.error}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          // 🔹 Default fallback
          return const SizedBox();
        },
      ),
    );
  }
}
