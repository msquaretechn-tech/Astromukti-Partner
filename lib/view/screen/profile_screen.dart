import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../model/get_vendor.dart';
import '../../repository/repository.dart';
import '../../resources/app_url.dart';
import '../../resources/resources.dart';
import '../../routes/routes_name.dart';
import '../drawer.dart';
import '../widgets/appbar_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final Repository _repository = Repository();

  VendorProfileModel? userDetails;
  bool isLoading = false;
  String astrologerName = "Hanumanta Partner";

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthGetVendorProfileEvent());
    _fetchVendorDetails();
  }

  Future<void> _fetchVendorDetails() async {
    setState(() => isLoading = true);
    try {
      userDetails = await _repository.getVendorProfile();
      astrologerName =
          "${userDetails?.name ?? ""} ${userDetails?.lastName ?? ""}";
    } catch (e) {
      if (kDebugMode) log("Profile error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ======================== UI ========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerPage(),
      appBar: AppbarProfile(
        userName: 'Profile',
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share, color: Colors.black),
        //     onPressed: _shareProfile,
        //   ),
        // ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Resources.colors.themeColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileHeader(),
                  const SizedBox(height: 20),
                  _profileCard(),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: _bankCard(),
                  ),
                  // SizedBox(height: MediaQuery.of(context).size.height*.1),
                ],
              ),
            ),
    );
  }

  // ======================== HEADER ========================

  Widget _profileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 40,
            backgroundImage:
                userDetails?.avatar != null && userDetails?.avatar != ""
                ? NetworkImage(
                    "${AppUrl.baseUrl}/images/${userDetails?.avatar}",
                  )
                : AssetImage(Resources.images.noImage) as ImageProvider,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          astrologerName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Verified Astrologer",
          style: TextStyle(color: Colors.black87, letterSpacing: 1),
        ),
      ],
    );
  }

  // ======================== PROFILE CARD ========================

  Widget _profileCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("PERSONAL DETAILS"),
          _infoRow("Mobile", userDetails?.mobile ?? "N/A"),
          _infoRow("Email", userDetails?.email ?? "N/A"),
          _infoRow("Experience", "${userDetails?.experienceYear ?? "0"} years"),
          _infoRow(
            "DOB",
            userDetails?.dob != null
                ? DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(userDetails!.dob!))
                : "N/A",
          ),
          _infoRow("Gender", userDetails?.gender ?? "N/A"),
          _infoRow("Skills", (userDetails?.skills ?? []).join(", ")),
          const SizedBox(height: 10),
          _sectionTitle("ADDRESS"),
          Text(
            "${userDetails?.country ?? ""}, "
            "${userDetails?.state ?? ""}, "
            "${userDetails?.city ?? ""} - "
            "${userDetails?.pincode ?? ""}",
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          SizedBox(height: 5),
          _sectionTitle("IDENTITY DOCUMENTS"),
          _documentItem("Aadhaar Card Front", userDetails?.aadharFront),
          const SizedBox(height: 15),
          _documentItem("Aadhaar Card Back", userDetails?.aadharBack),
          const SizedBox(height: 15),
          _documentItem("higher Educations Certificate", userDetails?.panImage),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .085,
              child: GestureDetector(
                onTap: () async {
                  await GoRouter.of(context)
                      .pushNamed(RoutesName.registrationScreen, extra: true)
                      .then((value) {
                        _fetchVendorDetails();
                      });
                },

                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // pill shape
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
                    child: Text(
                      'Edit',
                      style: Resources.styles.kTextStyle16B(Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================== BANK CARD ========================

  Widget _bankCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("BANK DETAILS"),
          _infoRow("Bank", userDetails?.bankName ?? "N/A"),
          _infoRow("Account Holder", userDetails?.accountHolderName ?? "N/A"),
          _infoRow(
            "Account No.",
            userDetails?.accountNumber?.toString() ?? "N/A",
          ),
          _infoRow("IFSC", userDetails?.ifscCode ?? "N/A"),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .085,
              child: GestureDetector(
                onTap: () {
                  GoRouter.of(context).pushNamed(RoutesName.bankScreen).then((
                    value,
                  ) {
                    _fetchVendorDetails();
                  });
                },

                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                    child: Text(
                      'Edit',
                      style: Resources.styles.kTextStyle16B(Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================== DOCUMENTS CARD ========================

  Widget _documentItem(String label, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.withOpacity(0.05),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${AppUrl.baseUrl}/images/$imageUrl",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Resources.colors.themeColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, color: Colors.grey),
                          const SizedBox(height: 5),
                          Text(
                            "Failed to load image",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Not Uploaded",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ======================== UI HELPERS ========================

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        color: Resources.colors.whiteColor,

        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, top: 15),
      child: Text(
        title,
        style: TextStyle(
          color: Resources.colors.blackColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
