import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../model/city_model.dart' show CitiesModel;
import '../../model/country_model.dart' as cs_model show CountryStateModel;
import '../../repository/country_services.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';

class RegistrationScreen extends StatefulWidget {
  final bool? isUpdate;
  const RegistrationScreen({super.key, this.isUpdate});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? img;
  XFile? img1;
  XFile? img2;
  XFile? img3;
  XFile? aadharBack;
  XFile? aadharFront;
  XFile? panImage;

  // PICK IMAGE
  Future<XFile?> selectImage(ImageSource imageSource) async {
    XFile? pickedImg = await _imagePicker.pickImage(source: imageSource);

    log("pickFile$pickedImg");
    return pickedImg;
  }

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final pinCodeController = TextEditingController();
  final bioController = TextEditingController();
  final learningAddressController = TextEditingController();
  final platformController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  bool termsAccepted = false;

  final CountryStateCityServices _countryStateCityServices =
      CountryStateCityServices();
  cs_model.CountryStateModel countryStateModel = cs_model.CountryStateModel(
    error: false,
    msg: '',
    data: [],
  );
  CitiesModel citiesModel = CitiesModel(error: false, msg: '', data: []);

  List<String> countries = ['Select Country'];
  List<String> states = ['Select State'];
  List<String> cities = ['Select City'];

  String selectedCountry = 'Select Country';
  String selectedState = 'Select State';
  String selectedCity = 'Select City';
  bool isPassword = true;
  bool isDataLoaded = false;
  String? selectedPinCode;
  bool _isPasswordVisible = false;
  getCountries() async {
    countryStateModel = await _countryStateCityServices.getCountriesStates();
    setState(() {
      countries = ['Select Country'];
      for (var element in countryStateModel.data) {
        countries.add(element.name);
      }
      isDataLoaded = true;
    });
  }

  getStates() async {
    for (var element in countryStateModel.data) {
      if (selectedCountry == element.name) {
        setState(() {
          resetStates();
          for (var state in element.states) {
            states.add(state.name);
          }
        });
        break;
      }
    }
  }

  getCities() async {
    isDataLoaded = false;
    citiesModel = await _countryStateCityServices.getCities(
      country: selectedCountry,
      state: selectedState,
    );
    setState(() {
      resetCities();
      for (var city in citiesModel.data) {
        cities.add(city);
      }
      isDataLoaded = true;
    });
  }

  resetCities() {
    cities = ['Select City'];
    selectedCity = 'Select City';
  }

  resetStates() {
    states = ['Select State'];
    selectedState = 'Select State';
    resetCities();
  }

  String? hoursValue;
  List<String> hoursList = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  String? _gender;
  String? _marital;
  String? _isWorking;
  String? _isFullTime;
  bool isShow = false;
  bool isLanguage = false;
  bool isPhone = false;
  List<bool> steps = [true, false, false];

  List<Map<String, dynamic>> skillList = [
    {"title": "Vedic", "isShow": false},
    {"title": "Vastu", "isShow": false},
    {"title": "Western", "isShow": false},
    {"title": "Tarot", "isShow": false},
    {"title": "Numerology", "isShow": false},
    {"title": "Palmistry", "isShow": false},
  ];
  List<Map<String, dynamic>> languageList = [
    {"title": "Hindi", "isLanguage": false},
    {"title": "English", "isLanguage": false},
  ];
  List<String> phoneList = ['Android', 'IOS'];
  String _textCount = '';
  int i = 0;
  int selectedIndex = 0;
  String countryCode = "+91";

  @override
  void initState() {
    if (widget.isUpdate != null && widget.isUpdate == true) {
      context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
    }
    super.initState();
    getCountries().then((_) {
      if (selectedCountry != 'Select Country') {
        getStates().then((_) {
          if (selectedState != 'Select State') {
            getCities();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        i = steps.indexOf(true);

        if (i > 0) {
          steps[i] = false;
          steps[i - 1] = true;
          i -= 1;
          setState(() {});
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              print("state.runtimeType : ${state.runtimeType}");
              if (state.runtimeType == AuthRegistrationSuccessState) {
                var data = state as AuthRegistrationSuccessState;
                Navigator.pop(context);
                Utils.snackBar(" ${data.response['message']}", context);
              } else if (state is AuthGetVendorSuccessState) {
                final vendor = state.response;
                nameController.text = vendor.name ?? '';
                lastNameController.text = vendor.lastName ?? '';
                mobileController.text = vendor.mobile.toString();
                emailController.text = vendor.email ?? '';
                dateOfBirthController.text = vendor.dob != null
                    ? DateFormat(
                        'yyyy-MM-dd',
                      ).format(DateTime.parse(vendor.dob ?? ""))
                    : '';
                _gender = vendor.gender;
                experienceController.text = vendor.experienceYear?.toString() ?? '';
                hoursValue = vendor.workingHours.toString();
                _isWorking = vendor.exclusiveStatus.toString();
                platformController.text = vendor.workingPlatform ?? "";
                selectedCountry = vendor.country?.toString() ?? "";
                selectedState = vendor.state?.toString() ?? "";
                selectedCity = vendor.city?.toString() ?? "";
                pinCodeController.text = vendor.pincode.toString();
                learningAddressController.text = vendor.learningAddress ?? "";
                bioController.text = vendor.bio.toString();
                _isFullTime = vendor.isFulltimeJob.toString();
                if (vendor.currentDevice != null) {
                  int dIndex = phoneList.indexOf(vendor.currentDevice!);
                  if (dIndex != -1) {
                    selectedIndex = dIndex;
                  }
                }
                setState(() {});

                if (kDebugMode) {
                  print("experience${vendor.experienceYear}");
                }
                vendor.languages!.forEach((e) {
                  print("language :$e");
                  languageList.forEach((element) {
                    for (int i = 0; i < languageList.length; i++) {
                      var element = languageList[i];
                      if (element["title"].toString().contains(e)) {
                        print("Element found at index: $i");
                        languageList[i]["isLanguage"] = true;
                      }
                    }
                  });
                });

                vendor.skills!.forEach((element) {
                  if (kDebugMode) {
                    print("Skills : #$element");
                  }
                  skillList.forEach((newElement) {
                    for (int i = 0; i < skillList.length; i++) {
                      var newElement = skillList[i];
                      if (newElement["title"].toString().contains(element)) {
                        if (kDebugMode) {
                          print("Element found at index: $i");
                        }
                        // Access element at index i
                        if (kDebugMode) {
                          print(skillList[i]);
                        }
                        skillList[i]["isShow"] = true;
                      }
                    }
                  });
                });
                // selected phone
              } else if (state is ProfileUpdateSuccessState) {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
              }
            },
            builder: (context, state) {
              if (kDebugMode) {
                print("state.runtimeType : ${state.runtimeType}");
              }

              return GestureDetector(
                onTap: () async {
                  log("image file: $img");

                  var avatar;

                  if (img != null) {
                    avatar = await http.MultipartFile.fromPath(
                      "avatar",
                      img!.path,
                    );
                  }

                  List<http.MultipartFile> otherImages = [];

                  if (img1?.path != null) {
                    var otherImage1 = await http.MultipartFile.fromPath(
                      "otherImages",
                      img1!.path,
                    );
                    otherImages.add(otherImage1);
                    print("otherImage1:$otherImage1");
                  }

                  if (img2?.path != null) {
                    var otherImage2 = await http.MultipartFile.fromPath(
                      "otherImages",
                      img2!.path,
                    );
                    otherImages.add(otherImage2);
                    print("otherImage2:$otherImage2");
                  }

                  if (img3?.path != null) {
                    var otherImage3 = await http.MultipartFile.fromPath(
                      "otherImages",
                      img3!.path,
                    );
                    otherImages.add(otherImage3);
                    print("otherImage3:$otherImage3");
                  }

                  // Prepare documents (async work)
                  http.MultipartFile? aadharFrontFile;
                  http.MultipartFile? aadharBackFile;
                  http.MultipartFile? panImageFile;

                  if (aadharFront != null) {
                    aadharFrontFile = await http.MultipartFile.fromPath(
                      "aadharFront",
                      aadharFront!.path,
                    );
                  }
                  if (aadharBack != null) {
                    aadharBackFile = await http.MultipartFile.fromPath(
                      "aadharBack",
                      aadharBack!.path,
                    );
                  }
                  if (panImage != null) {
                    panImageFile = await http.MultipartFile.fromPath(
                      "panImage",
                      panImage!.path,
                    );
                  }

                  int currentIdx = steps.indexOf(true);

                  if (currentIdx < steps.length - 1) {
                    bool canGoNext = false;
                    if (currentIdx == 0 &&
                        nameController.text != "" &&
                        lastNameController.text != "" &&
                        emailController.text != "" &&
                        mobileController.text != "" &&
                        dateOfBirthController.text != "" &&
                        _gender != "" &&
                        skillList.toString().contains('true')) {
                      canGoNext = true;
                    } else if (currentIdx == 1 &&
                        languageList.toString().contains('true') &&
                        hoursValue != null &&
                        _isWorking != null) {
                      canGoNext = true;
                    } else if (currentIdx == 2 &&
                        selectedCountry != "Select Country" &&
                        selectedState != "Select State" &&
                        selectedCity != "Select City" &&
                        pinCodeController.text != "" &&
                        learningAddressController.text != "" &&
                        bioController.text != "" &&
                        _isFullTime != "") {
                      canGoNext = true;
                    }

                    if (canGoNext) {
                      if (currentIdx == 2 && !termsAccepted) {
                        Fluttertoast.showToast(
                          msg: 'Please accept Terms & Conditions',
                        );
                        return;
                      }
                      setState(() {
                        steps[currentIdx] = false;
                        steps[currentIdx + 1] = true;
                        i = currentIdx + 1;
                      });
                    } else {
                      Fluttertoast.showToast(msg: 'All Field Required');
                    }
                  } else if (currentIdx == steps.length - 1) {
                    // Final Submission
                    var selectedLng = [];
                    for (var element in languageList) {
                      if (element["isLanguage"] == true) {
                        selectedLng.add(element["title"]);
                      }
                    }

                    var selectedSkill = [];
                    for (var element in skillList) {
                      if (element["isShow"] == true) {
                        selectedSkill.add(element["title"]);
                      }
                    }

                    List<http.MultipartFile> allFiles = [
                      if (avatar != null) avatar,
                      if (aadharFrontFile != null) aadharFrontFile,
                      if (aadharBackFile != null) aadharBackFile,
                      if (panImageFile != null) panImageFile,
                      ...otherImages,
                    ];

                    if (widget.isUpdate == true) {
                      context.read<AuthBloc>().add(
                        ProfileUpdateEvent(
                          formData: {
                            "name": nameController.text,
                            "lastName": lastNameController.text,
                            "password": passwordController.text,
                            "dob": DateTime.parse(dateOfBirthController.text),
                            "gender": _gender.toString(),
                            "skills": selectedSkill.join(', '),
                            "experienceYear": experienceController.text.trim(),
                            "languages": selectedLng.join(', '),
                            "workingHours": hoursValue.toString(),
                            "exclusiveStatus": _isWorking,
                            "workingPlatform": platformController.text.trim(),
                            "country": selectedCountry.toString(),
                            "state": selectedState.toString(),
                            "city": selectedCity.toString(),
                            "pincode": pinCodeController.text,
                            "learningAddress": learningAddressController.text,
                            "bio": bioController.text,
                            "isFulltimeJob": _isFullTime,
                            "termsAccepted": true,
                            "mobile": countryCode + mobileController.text,
                            "currentDevice": phoneList[selectedIndex],
                          },
                          files: allFiles,
                        ),
                      );
                    } else {
                      if (nameController.text.isEmpty ||
                          lastNameController.text.isEmpty ||
                          passwordController.text.isEmpty ||
                          mobileController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          dateOfBirthController.text.isEmpty ||
                          pinCodeController.text.isEmpty ||
                          learningAddressController.text.isEmpty ||
                          bioController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "All fields are required");
                      } else {
                        context.read<AuthBloc>().add(
                          RegistrationEvent(
                            formData: {
                              "name": nameController.text,
                              "lastName": lastNameController.text,
                              "password": passwordController.text,
                              "mobile": countryCode + mobileController.text,
                              "email": emailController.text,
                              "dob": DateTime.parse(dateOfBirthController.text),
                              "gender": _gender.toString(),
                              "skills": selectedSkill.join(', '),
                              "experienceYear": experienceController.text
                                  .trim(),
                              "languages": selectedLng.join(', '),
                              "workingHours": hoursValue.toString(),
                              "exclusiveStatus": _isWorking,
                              "workingPlatform": platformController.text.trim(),
                              "country": selectedCountry.toString(),
                              "state": selectedState.toString(),
                              "city": selectedCity.toString(),
                              "pincode": pinCodeController.text,
                              "learningAddress": learningAddressController.text,
                              "bio": bioController.text,
                              "isFulltimeJob": _isFullTime,
                              "termsAccepted": true,
                              "currentDevice": phoneList[selectedIndex],
                            },
                            files: allFiles,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
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
                    child: state is AuthLoadingState
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            i == steps.length - 1 ? 'Submit' : 'Next',
                            style: Resources.styles.kTextStyle16B(Colors.black),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              );
            },
          ),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Resources.colors.blackColor),
              onPressed: () {
                i = steps.indexOf(true);

                if (i > 0) {
                  steps[i] = false;
                  steps[i - 1] = true;
                  i -= 1;
                  setState(() {});
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              widget.isUpdate == true ? "Update" : 'Registration',
              style: Resources.styles.kTextStyle14B(
                Resources.colors.blackColor,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: steps[0],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            var data;
                            if (state is AuthGetVendorSuccessState) {
                              data = state;
                            }

                            switch (state.runtimeType) {
                              default:
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 0,
                                        top: 5,
                                      ),
                                      decoration: Resources.styles
                                          .kBoxDecoration(
                                            Resources.colors.whiteColor,
                                          ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          img = await selectImage(
                                            ImageSource.gallery,
                                          );
                                          setState(() {});
                                          log("imageProblem :$img");
                                        },
                                        child: Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 45,
                                              backgroundImage: img != null
                                                  ? FileImage(File(img!.path))
                                                        as ImageProvider
                                                  : data != null &&
                                                        data.response.avatar !=
                                                            ""
                                                  ? NetworkImage(
                                                          "${AppUrl.baseUrl}/images/${data.response.avatar}",
                                                        )
                                                        as ImageProvider
                                                  : null,
                                              // backgroundColor:
                                              //     (data == null ||
                                              //         data.response.avatar == "")
                                              //     ? Resources.colors.buttonColor
                                              //     : null,
                                              // child:
                                              //     (data == null ||
                                              //         data.response.avatar == "")
                                              //     ? Icon(
                                              //         Icons.person,
                                              //         size: 45,
                                              //         color: Resources
                                              //             .colors
                                              //             .blackColor,
                                              //       )
                                              //     : null,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Icon(
                                                Icons.camera_alt,
                                                color:
                                                    Resources.colors.themeColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                            }
                          },
                        ),

                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '* First Name',
                                      style: Resources.styles.kTextStyle14B5(
                                        Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Enter First Name',
                                        hintStyle: Resources.styles
                                            .kTextStyle14B5(Colors.grey),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '* Last Name',
                                      style: Resources.styles.kTextStyle14B5(
                                        Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: lastNameController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Enter Last Name',
                                        hintStyle: Resources.styles
                                            .kTextStyle14B5(Colors.grey),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            width: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Email Id',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        widget.isUpdate == true
                            ? TextFormField(
                                controller: emailController,
                                readOnly: true,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Enter Email Id',
                                  hintStyle: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            : TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Enter Email Id',
                                  hintStyle: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                        widget.isUpdate == true
                            ? const SizedBox.shrink()
                            : Container(
                                margin: const EdgeInsets.only(
                                  left: 5,
                                  top: 10,
                                  bottom: 5,
                                ),
                                decoration: Resources.styles.kBoxDecoration(
                                  Resources.colors.whiteColor,
                                ),
                                child: Text(
                                  '* Password',
                                  style: Resources.styles.kTextStyle14B5(
                                    Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                        widget.isUpdate == true
                            ? const SizedBox.shrink()
                            : TextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: isPassword && !_isPasswordVisible,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  fillColor: Colors.white,
                                  suffixIcon: isPassword
                                      ? IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  hintText: 'Enter Password',
                                  hintStyle: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Mobile No',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        widget.isUpdate == true
                            ? IntlPhoneField(
                                readOnly: true,
                                enabled: false,
                                keyboardType: TextInputType.number,
                                controller: mobileController,
                                // focusNode: focusNode,
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Phone Number',
                                  hintStyle: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                initialCountryCode: 'IN',
                                showDropdownIcon: false,
                                onChanged: (phone) {
                                  setState(() {
                                    countryCode = phone.countryCode;
                                  });
                                  if (kDebugMode) {
                                    print(phone.completeNumber);
                                  }
                                },
                                onCountryChanged: (country) {
                                  setState(() {
                                    countryCode = "+${country.dialCode}";
                                  });
                                },
                              )
                            : IntlPhoneField(
                                keyboardType: TextInputType.number,
                                controller: mobileController,
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Phone Number',
                                  hintStyle: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                initialCountryCode: 'IN',
                                showDropdownIcon: false,
                                onChanged: (phone) {
                                  setState(() {
                                    countryCode = phone.countryCode;
                                  });
                                  if (kDebugMode) {
                                    print(phone.completeNumber);
                                  }
                                },
                                onCountryChanged: (country) {
                                  setState(() {
                                    countryCode = "+${country.dialCode}";
                                  });
                                },
                              ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Date Of Birth ',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        TextFormField(
                          controller: dateOfBirthController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Date Of Birth ',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1930),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Format the date to your preferred format
                              String formattedDate = DateFormat(
                                "yyyy-MM-dd",
                              ).format(pickedDate);

                              // Update the TextFormField text
                              dateOfBirthController.text = formattedDate;
                            }
                          },
                        ),
                        SizedBox(
                          height: Resources.dimens.height(context) * 0.01,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Gender',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Row(
                          children: [
                            Radio(
                              activeColor: Resources.colors.themeColor,
                              value: "Male",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value.toString();
                                });
                              },
                            ),
                            Text(
                              "Male",
                              style: Resources.styles.kTextStyle16B5(
                                Resources.colors.blackColor,
                              ),
                            ),
                            SizedBox(
                              width: Resources.dimens.width(context) * 0.03,
                            ),
                            Radio(
                              activeColor: Resources.colors.themeColor,
                              value: "Female",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value.toString();
                                });
                              },
                            ),
                            Text(
                              "Female",
                              style: Resources.styles.kTextStyle16B5(
                                Resources.colors.blackColor,
                              ),
                            ),
                            SizedBox(
                              width: Resources.dimens.width(context) * 0.03,
                            ),
                            Radio(
                              activeColor: Resources.colors.themeColor,
                              value: "Other",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value.toString();
                                });
                              },
                            ),
                            Text(
                              "Other",
                              style: Resources.styles.kTextStyle16B5(
                                Resources.colors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        Card(
                          child: Container(
                            height: Resources.dimens.height(context) * 0.06,
                            decoration: Resources.styles.kBoxDecoration(
                              Resources.colors.whiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '* Primary Skills ',
                                  style: Resources.styles.kTextStyle14B5(
                                    Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(
                                  width: Resources.dimens.width(context) * 0.2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isShow = !isShow;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isShow,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 4,
                                ),
                            physics: const NeverScrollableScrollPhysics(),
                            primary: false,
                            shrinkWrap: true,
                            itemCount: skillList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // print(skillList);
                                    if (kDebugMode) {
                                      print(skillList[index]["isShow"]);
                                    }
                                    skillList[index]["isShow"] =
                                        !skillList[index]["isShow"];
                                  });
                                },
                                child: Container(
                                  height:
                                      Resources.dimens.height(context) * 0.05,
                                  width: Resources.dimens.width(context) * 0.4,
                                  decoration: Resources.styles.kBoxDecoration(
                                    skillList[index]["isShow"]
                                        ? Resources.colors.themeColor
                                              .withOpacity(0.7)
                                        : Resources.colors.blackColor
                                              .withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      skillList[index]["title"].toString(),
                                      style: Resources.styles.kTextStyle14B5(
                                        Resources.colors.blackColor.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: steps[1],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Experience In Years ',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        TextFormField(
                          controller: experienceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter Experience',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 10),
                        //   width: double.infinity,
                        //   decoration: Resources.styles.kBoxBorderDecoration(),
                        //   child: DropdownButtonHideUnderline(
                        //     child: DropdownButton(
                        //       hint: Text(
                        //         'Select Experience  Years ',
                        //         style: Resources.styles.kTextStyle14B5(
                        //           Colors.grey,
                        //         ),
                        //         textAlign: TextAlign.start,
                        //       ),
                        //
                        //       /// Initial Value
                        //       value: experienceValue,
                        //
                        //       /// Down Arrow Icon
                        //       icon: const Icon(Icons.keyboard_arrow_down),
                        //
                        //       /// Array list of items
                        //       items: experienceList
                        //           .map<DropdownMenuItem<String>>((items) {
                        //             return DropdownMenuItem(
                        //               value: items.toString(),
                        //               child: Text(
                        //                 "$items years",
                        //                 style: Resources.styles.kTextStyle14B5(
                        //                   Colors.black,
                        //                 ),
                        //               ),
                        //             );
                        //           })
                        //           .toList(),
                        //       // After selecting the desired option,it will
                        //       // change button value to selected value
                        //       onChanged: (String? newValue) {
                        //         setState(() {
                        //           experienceValue = (newValue!);
                        //         });
                        //       },
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: Resources.dimens.height(context) * 0.02,
                        ),
                        Card(
                          child: Container(
                            height: Resources.dimens.height(context) * 0.06,
                            decoration: Resources.styles.kBoxDecoration(
                              Resources.colors.whiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Select Your Language ',
                                  style: Resources.styles.kTextStyle14B5(
                                    Colors.grey,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(
                                  width: Resources.dimens.width(context) * 0.2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLanguage = !isLanguage;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isLanguage,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: 4,
                                ),
                            physics: const NeverScrollableScrollPhysics(),
                            primary: false,
                            shrinkWrap: true,
                            itemCount: languageList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // print(skillList);
                                    if (kDebugMode) {
                                      print(languageList[index]["isLanguage"]);
                                    }
                                    languageList[index]["isLanguage"] =
                                        !languageList[index]["isLanguage"];
                                  });
                                },
                                child: Container(
                                  height:
                                      Resources.dimens.height(context) * 0.05,
                                  width: Resources.dimens.width(context) * 0.4,
                                  decoration: Resources.styles.kBoxDecoration(
                                    languageList[index]["isLanguage"]
                                        ? Resources.colors.themeColor
                                        : Resources.colors.blackColor
                                              .withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      languageList[index]["title"].toString(),
                                      style: Resources.styles.kTextStyle14B5(
                                        Resources.colors.blackColor.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* How Many Hours You Can Contribute Daily',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: Resources.styles.kBoxBorderDecoration(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: Text(
                                'select Hours',
                                style: Resources.styles.kTextStyle14B5(
                                  Colors.grey,
                                ),
                              ),

                              /// Initial Value
                              value: hoursValue,

                              /// Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              /// Array list of items
                              items: hoursList.map<DropdownMenuItem<String>>((
                                item,
                              ) {
                                return DropdownMenuItem(
                                  value: item.toString(),
                                  child: Text(
                                    "$item Hours",
                                    style: Resources.styles.kTextStyle14B5(
                                      Resources.colors.blackColor.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  hoursValue = (newValue!);
                                });
                              },
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 5,
                                top: 10,
                                bottom: 5,
                              ),
                              decoration: Resources.styles.kBoxDecoration(
                                Resources.colors.whiteColor,
                              ),
                              child: Text(
                                '* Are you working on any other online platform',
                                style: Resources.styles.kTextStyle14B5(
                                  Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Row(
                              children: [
                                Radio(
                                  activeColor: Resources.colors.themeColor,
                                  value: "true",
                                  groupValue: _isWorking,
                                  onChanged: (value) {
                                    log("IsWorking: $value");
                                    setState(() {
                                      _isWorking = value!;
                                    });
                                  },
                                ),
                                Text(
                                  "Yes",
                                  style: Resources.styles.kTextStyle14B5(
                                    Resources.colors.blackColor.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  activeColor: Resources.colors.themeColor,
                                  value: "false",
                                  groupValue: _isWorking,
                                  onChanged: (value) {
                                    log("IsWorking: $value");
                                    setState(() {
                                      _isWorking = value!;
                                    });
                                  },
                                ),
                                Text(
                                  "No",
                                  style: Resources.styles.kTextStyle14B5(
                                    Resources.colors.blackColor.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isWorking == "true")
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextFormField(
                                  controller: platformController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: "Where you work",
                                    hintStyle: Resources.styles.kTextStyle14B5(
                                      Colors.grey,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 5,
                                top: 10,
                                bottom: 5,
                              ),
                              decoration: Resources.styles.kBoxDecoration(
                                Resources.colors.whiteColor,
                              ),
                              child: Text(
                                '* Which Device You Use',
                                style: Resources.styles.kTextStyle14B5(
                                  Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    activeColor: Resources.colors.themeColor,
                                    value: 0,
                                    groupValue: selectedIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedIndex = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "Android",
                                    style: Resources.styles.kTextStyle14B5(
                                      Resources.colors.blackColor.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Radio<int>(
                                    activeColor: Resources.colors.themeColor,
                                    value: 1,
                                    groupValue: selectedIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedIndex = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "IOS",
                                    style: Resources.styles.kTextStyle14B5(
                                      Resources.colors.blackColor.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: steps[2],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Country',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: countries.contains(selectedCountry)
                              ? selectedCountry
                              : 'Select Country',
                          items: countries.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (selectedValue) {
                            setState(() {
                              selectedCountry = selectedValue!;
                              getStates();
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Select Country',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* State',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: states.contains(selectedState)
                              ? selectedState
                              : null,
                          items: states.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (selectedValue) {
                            setState(() {
                              selectedState = selectedValue!;
                              getCities();
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Select Sates',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* City',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: cities.contains(selectedCity)
                              ? selectedCity
                              : 'Select City',
                          items: cities.map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (selectedValue) {
                            setState(() {
                              selectedCity = selectedValue!;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Select City',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Pincode',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        TextFormField(
                          controller: pinCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: ' Pincode',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Aadhar Front
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          child: Text(
                            '* Aadhar Card Front',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            aadharFront = await selectImage(
                              ImageSource.gallery,
                            );
                            setState(() {});
                          },
                          child: DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashPattern: const [6, 3],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: aadharFront != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(aadharFront!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        var vendorData;
                                        if (state
                                            is AuthGetVendorSuccessState) {
                                          vendorData = state.response;
                                        }
                                        if (vendorData != null &&
                                            vendorData.aadharFront != null &&
                                            vendorData.aadharFront != "") {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              "${AppUrl.baseUrl}/images/${vendorData.aadharFront}",
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color:
                                                  Resources.colors.themeColor,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Upload Aadhar Front',
                                              style: Resources.styles
                                                  .kTextStyle12(Colors.grey),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        // Aadhar Back
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          child: Text(
                            '* Aadhar Card Back',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            aadharBack = await selectImage(ImageSource.gallery);
                            setState(() {});
                          },
                          child: DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashPattern: const [6, 3],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: aadharBack != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(aadharBack!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        var vendorData;
                                        if (state
                                            is AuthGetVendorSuccessState) {
                                          vendorData = state.response;
                                        }
                                        if (vendorData != null &&
                                            vendorData.aadharBack != null &&
                                            vendorData.aadharBack != "") {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              "${AppUrl.baseUrl}/images/${vendorData.aadharBack}",
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color:
                                                  Resources.colors.themeColor,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Upload Aadhar Back',
                                              style: Resources.styles
                                                  .kTextStyle12(Colors.grey),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        // PAN Card
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          child: Text(
                            '* higher Educations Certificate',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            panImage = await selectImage(ImageSource.gallery);
                            setState(() {});
                          },
                          child: DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashPattern: const [6, 3],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: panImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(panImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        var vendorData;
                                        if (state
                                            is AuthGetVendorSuccessState) {
                                          vendorData = state.response;
                                        }
                                        if (vendorData != null &&
                                            vendorData.panImage != null &&
                                            vendorData.panImage != "") {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              "${AppUrl.baseUrl}/images/${vendorData.panImage}",
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color:
                                                  Resources.colors.themeColor,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Upload Education Certificate',
                                              style: Resources.styles
                                                  .kTextStyle12(Colors.grey),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* From where did you learn Astrology',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        TextFormField(
                          controller: learningAddressController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter Name ',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            '* Bio',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        TextFormField(
                          controller: bioController,
                          onChanged: (value) {
                            setState(() {
                              _textCount = value;
                            });
                          },
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Maximum 1000 words.. ',
                            hintStyle: Resources.styles.kTextStyle14B5(
                              Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            _textCount.length.toString(),
                            textAlign: TextAlign.end,
                            style: Resources.styles.kTextStyle14B5(
                              Resources.colors.themeColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 5,
                            top: 10,
                            bottom: 5,
                          ),
                          decoration: Resources.styles.kBoxDecoration(
                            Resources.colors.whiteColor,
                          ),
                          child: Text(
                            'Are you here for  full time role',
                            style: Resources.styles.kTextStyle14B5(
                              Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Row(
                          children: [
                            Radio(
                              activeColor: Resources.colors.themeColor,
                              value: "true",
                              groupValue: _isFullTime,
                              onChanged: (value) {
                                log("message fullTime$value");
                                setState(() {
                                  _isFullTime = value;
                                });
                              },
                            ),
                            Text(
                              "Yes",
                              style: Resources.styles.kTextStyle16B5(
                                Resources.colors.blackColor,
                              ),
                            ),
                            SizedBox(
                              width: Resources.dimens.width(context) * 0.03,
                            ),
                            Radio(
                              activeColor: Resources.colors.themeColor,
                              value: "false",
                              groupValue: _isFullTime,
                              onChanged: (value) {
                                log("message FullTime$value");
                                setState(() {
                                  _isFullTime = value;
                                });
                              },
                            ),
                            Text(
                              "No",
                              style: Resources.styles.kTextStyle16B5(
                                Resources.colors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Resources.colors.themeColor,
                              value: termsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  termsAccepted = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final Uri url = Uri.parse(
                                    'https://www.astromukti.com/astro-terms-conditions',
                                  );
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "I accept the ",
                                        style: Resources.styles.kTextStyle12(
                                          Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "Privacy Policy and Terms & Conditions",
                                        style: Resources.styles
                                            .kTextStyle12B(
                                              Resources.colors.blackColor,
                                            )
                                            .copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
