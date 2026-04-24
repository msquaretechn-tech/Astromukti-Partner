


import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/home/home_bloc.dart';
import '../../data/local/pref_service.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';

class AddBlog extends StatefulWidget {
  const AddBlog({super.key});

  @override
  State<AddBlog> createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  XFile? img;
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> selectImage(ImageSource source) async {
    return await _imagePicker.pickImage(source: source);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Resources.colors.buttonColor.withOpacity(.3),
      appBar: AppbarProfile(
        userName: "Create Blog",

      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// IMAGE PICKER CARD
          GestureDetector(
            onTap: () async {
              img = await selectImage(ImageSource.gallery);
              setState(() {});

            },
            child: Container(
              height: size.height * 0.22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: img == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 40, color: Colors.grey.shade500),
                  const SizedBox(height: 10),
                  Text(
                    "Upload Blog Image",
                    style: Resources.styles
                        .kTextStyle14B(Colors.grey),
                  ),
                ],
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(img!.path),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// TITLE FIELD
          _inputField(
            controller: titleController,
            hint: "Blog Title",
            maxLines: 1,
          ),

          const SizedBox(height: 15),

          /// DESCRIPTION FIELD
          _inputField(
            controller: descriptionController,
            hint: "Blog Description",
            maxLines: 5,
          ),
          SizedBox(height: 20,),
          /// SUBMIT BUTTON
          BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is CreateBlogSuccessState) {
                EasyLoading.dismiss();
                Fluttertoast.showToast(
                  msg: "Blog created successfully!",
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                );
                Navigator.pop(context);
              } else if (state is HomeErrorState) {
                EasyLoading.dismiss();
                Utils.snackBar("Blog creation failed!", context);
              }
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () async {
                  final vendorId = PrefService().getRegId();
              
                  if (img == null ||
                      titleController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    Utils.snackBar("Please fill all fields!", context);
                    return;
                  }
              
                  EasyLoading.show(status: "Uploading...");
              
                  final avatar = await http.MultipartFile.fromPath(
                    "image",
                    img!.path,
                  );
              
                  BlocProvider.of<HomeBloc>(context).add(
                    CreateBlogEvent(
                      formData: {
                        "heading": "date time",
                        "title": titleController.text,
                        "description": descriptionController.text,
                        "vendorId": vendorId,
                      },
                      files: [avatar],
                    ),
                  );
                },
                child:  Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40), // pill shape
                    gradient: LinearGradient(
                      colors:  [
                        Color(0xFFF9E076),
                        Color(0xFFD4AF37),
                        Color(0xFFF9E076),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: Resources.styles.kTextStyle16B(Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),



    );
  }

  /// REUSABLE INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Resources.styles.kTextStyle14B(Colors.grey),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
  void showImagePicker(BuildContext context, Function(File file) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  final file =
                  await ImagePickerService().pickFromCamera();
                  if (file != null) onSelected(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final file =
                  await ImagePickerService().pickFromGallery();
                  if (file != null) onSelected(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

}

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    final XFile? file =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    return file != null ? File(file.path) : null;
  }

  Future<File?> pickFromGallery() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) return null;

    final XFile? file =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return file != null ? File(file.path) : null;
  }
}