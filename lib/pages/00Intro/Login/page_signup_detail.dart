import 'dart:io';

import 'package:crediApp/route.dart';
import 'package:crediApp/global/constants.dart';
import 'package:crediApp/global/helperfunctions.dart';
import 'package:crediApp/global/models/user/user_request_model.dart';
import 'package:crediApp/global/network/auth.dart';
import 'package:crediApp/global/providers/providers.dart';
import 'package:crediApp/global/singleton.dart';
import 'package:crediApp/global/util.dart';
import 'package:crediApp/global/components/add_photo_button.dart';
import 'package:crediApp/global/components/cdbutton.dart';
import 'package:crediApp/global/components/rounded_button.dart';
import 'package:crediApp/global/components/plain_text_field.component.dart';
import 'package:crediApp/pages/00Intro/Login/page_login.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

class PageSignUpDetail extends StatefulWidget {
  @override
  _PageSignUpDetailState createState() => _PageSignUpDetailState();
}

class _PageSignUpDetailState extends State<PageSignUpDetail> {
  AuthMethods authMethods = new AuthMethods();
  late TextEditingController _tecNickName;
  late TextEditingController _tecCompany;
  late TextEditingController _tecPhone;
  late TextEditingController _tecAddress;
  late TextEditingController _tecMainProduct;
  late TextEditingController _tecCompanyId;
  late TextEditingController _tecIntroduce;

  List<File> _images = [];
  List<String> _imageUrl = [];
  File? imageFile;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  int selectedIndex = 0;
  bool _isUploadingImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    _tecNickName = new TextEditingController();
    _tecCompany = new TextEditingController();
    _tecPhone = new TextEditingController();
    _tecAddress = new TextEditingController();
    _tecMainProduct = new TextEditingController();
    _tecCompanyId = new TextEditingController();
    _tecIntroduce = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _tecNickName.dispose();
    _tecCompany.dispose();
    _tecPhone.dispose();
    _tecAddress.dispose();
    _tecMainProduct.dispose();
    _tecCompanyId.dispose();
    _tecIntroduce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SelectUserType(
            //   categories: ['?????????', '??????'],
            //   onPress: (index) {
            //     setState(() {
            //       selectedIndex = index;
            //     });
            //   },
            // ),
            Container(
              // padding: EdgeInsets.all(10),
              child: Form(key: _formKey, child: _buildUserForm(size, context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserForm(Size size, BuildContext context) {
    final FocusScopeNode node = FocusScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "????????? ????????? ????????? / ????????? ??? ???????????? ?????? ???????????? ???????????????.\n???????????? ?????? ????????? ??????????????? ??????????????????.",
            style: CDTextStyle.p5.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 53),
          PlainTextField(
            controller: _tecNickName,
            title: "?????????",
            // hintText: "???????????? ??????????????????",
            warningMessage: "???????????? ??????????????????",
            showClear: true,
            onEditingComplete: () => context.nextEditableTextFocus(),
            validator: (value) {
              return value == null || value.length < 1 ? "???????????? ??????????????????" : null;
            },
          ),
          PlainTextField(
            controller: _tecCompany,
            title: "????????? (??????)",
            showClear: true,
            onEditingComplete: () => context.nextEditableTextFocus(),
            validator: (value) => null,
          ),
          PlainTextField(
            controller: _tecPhone,
            keyboardType: TextInputType.phone,
            title: "?????????",
            showClear: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              return value == null || value.length < 1 ? "???????????? ??????????????????" : null;
            },
          ),
          const SizedBox(height: 24),
          CDButton(
            width: size.width - 40,
            text: "??????",
            press: _updateUser,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: CDColors.nav_title),
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      title: _isLoading
          ? CircularProgressIndicator()
          : Text('????????????', style: CDTextStyle.nav),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: CDColors.nav_title,
        onPressed: _gotoLogin,
      ),
      actions: [
        IconButton(
          icon: Text("??????",
              style: TextStyle(color: CDColors.primary, fontSize: 16)),
          color: CDColors.primary,
          onPressed: _updateUser,
        )
      ],
    );
  }

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       imageFile = File(pickedFile.path);
  //     } else {
  //       logger.i("No image selected.");
  //     }
  //   });
  // }

  // Future<void> retrieveLostData() async {
  //   final LostData response = await picker.getLostData();
  //   if (response.isEmpty) {
  //     return;
  //   }
  //   if (response.file != null) {
  //     setState(() {
  //       if (response.type == RetrieveType.video) {
  //         _handleVideo(response.file);
  //       } else {
  //         _handleImage(response.file);
  //       }
  //     });
  //   } else {
  //     _handleError(response.exception);
  //   }
  // }

  Widget _decideImageView(File? imageFile) {
    if (imageFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "??????????????? ????????? ??? ?????? ????????? ???????????????",
              textAlign: TextAlign.center,
            ),
            Icon(Icons.photo),
          ],
        ),
      );
    } else {
      return Image.file(
        imageFile,
        width: 80,
        height: 80,
      );
    }
  }

  void _gotoLogin() {
    Navigator.of(context).pushReplacementNamed('PagePreview');
  }

  void _updateUser() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final String email = Singleton.shared.userData!.user!.email!;
    final int? uid = Singleton.shared.userData!.userId;
    final String nickname = _tecNickName.text;
    final String company = _tecCompany.text;
    final String phone = _tecPhone.text;
    HelperFunctions.saveUserEmail(email);
    // final String email = Singleton.shared.user!.email!;
    // final String uid = Singleton.shared.user!.id!;
    // final String nickname = _tecNickName.text;
    // final String company = _tecCompany.text;
    // final String phone = _tecPhone.text;
    // HelperFunctions.saveUserEmail(email);

    setState(() {
      _isLoading = true;
    });
    logger.i("here");

    Singleton.shared.userData!.user = Singleton.shared.userData!.user!.copyWith(
      email: email,
      name: nickname,
      companyName: company,
      phoneNumber: phone,
      agreeTerms: true,
    );

    // TODO sharedpref ??? uid ????????? ?????????????????? .. id ??????????????????..
    // HelperFunctions.saveUserId(uid);

    // TODO api test ????????? , user model ?????? ??????????????????..
    UserRequest userRequest =
        UserRequest(user: Singleton.shared.userData!.user!);
    await context.read(userNotifier).setUser(userRequest);
    gotoTabs();
  }

  void gotoTabs() {
    Routers.loadMain(context);
  }

  _stopLoading() {
    if (_isLoading == true) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _onErrorSingUp(Object error) {
    _stopLoading();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$error'),
    ));
  }
}
