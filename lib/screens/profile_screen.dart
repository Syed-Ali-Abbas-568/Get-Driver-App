// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:get_driver_app/providers/firestore_provider.dart';
import 'package:get_driver_app/widgets/snackbar_widget.dart';
import 'package:get_driver_app/widgets/text_field_widget.dart';
import 'package:get_driver_app/widgets/textfield_label.dart';
import 'package:get_driver_app/widgets/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../widgets/image_picker.dart';

Color readOnly = const Color(0xFF152C5E);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenceNumController = TextEditingController();
  final TextEditingController _yearsOfExpController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _editable = false;
  String? _imagePath;
  String? _imageUrl;
  String _name = "";
  final appBar = AppBar(
    backgroundColor: const Color(0xFF152C5E),
    title: const Text("Profile"),
  );
  final String _pattern = '^(?:[+0]9)?[0-9]{11}\$';
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _cnicController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _licenceNumController.dispose();
    _yearsOfExpController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return StreamBuilder<DocumentSnapshot>(
      stream: context.read<FirestoreProvider>().getUserStream(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong try again");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            semanticsLabel: "Loading",
            color: Color(0xFF152C5E),
          );
        }

        _firstNameController.text = snapshot.data?.get('firstName') ?? '';
        _lastNameController.text = snapshot.data?.get('lastName') ?? '';

        _imageUrl = snapshot.data?.get('photoUrl');

        _emailController.text = snapshot.data?.get('email') ?? '';
        _licenceNumController.text = (snapshot.data?.get('licenseNO') != null
            ? snapshot.data?.get('licenseNO').toString()
            : '')!;
        _yearsOfExpController.text = (snapshot.data?.get('experience') != null
            ? snapshot.data?.get('experience').toString()
            : " ")!;
        _cnicController.text = (snapshot.data?.get('cnic') != null
            ? snapshot.data?.get('cnic').toString()
            : " ")!;

        _phoneController.text = (snapshot.data?.get('phoneNO') != null
            ? snapshot.data?.get('phoneNO').toString()
            : 'null')!;

        _dobController.text = snapshot.data?.get('dateOfBirth') ?? " ";
        _name = "${_firstNameController.text} ${_lastNameController.text}";

        return Scaffold(
          appBar: _editable
              ? snapshot.data?.get('userType') == 'client'
                  ? appBar
                  : AppBar(
                      title: const Text("Edit Mode"),
                      centerTitle: true,
                      backgroundColor: readOnly,
                      automaticallyImplyLeading: false,
                    )
              : appBar,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: snapshot.data?.get('userType') == 'client'
                        ? height - 15
                        : 1000, //increase heres
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          height: 248,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            color: const Color(0xFF152C5E),
                          ),
                        ),
                        Positioned(
                          height: 365.61,
                          width: 366.24,
                          left: -216,
                          top: -118,
                          child: Image.asset(
                            "assets/images/splash_corner_image.png",
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          height: 365.61,
                          width: 366.24,
                          left: -85,
                          top: 527,
                          child: Image.asset(
                            "assets/images/splash_corner_image.png",
                          ),
                        ),
                        Positioned(
                          height: 108.62,
                          width: 253.64,
                          right: -86.64,
                          top: 139,
                          child: Image.asset(
                            "assets/images/car_logo.png",
                          ),
                        ),
                        Positioned(
                          width: 134,
                          height: 134,
                          top: 165,
                          left: 26,
                          child: GestureDetector(
                            onTap: () async {
                              if (_editable) {
                                _imagePath = await getImage();
                                setState(() {});
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    (_imageUrl != null && _imagePath == null)
                                        ? NetworkImage(_imageUrl!)
                                        : (_imagePath != null)
                                            ? FileImage(File(_imagePath!))
                                            : const AssetImage(
                                                    'assets/images/profile.png')
                                                as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_editable,
                          child: Positioned(
                            top: 270,
                            height: 34,
                            width: 118,
                            right: 18,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF152C5E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                onPressed: () {
                                  _editable = true;
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Image(
                                      image:
                                          AssetImage('assets/images/edit.png'),
                                    ),
                                    Text(
                                      "Edit Details",
                                      style: GoogleFonts.manrope(
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 327,
                          child: Text(
                            _name,
                            style: GoogleFonts.manrope(
                              fontStyle: FontStyle.normal,
                              color: const Color(0xFF152C5E),
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 367,
                          child: Text(
                            _emailController.text,
                            style: GoogleFonts.manrope(
                              fontStyle: FontStyle.normal,
                              color: const Color(0xFF8893AC),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 400,
                          left: 16,
                          right: 17,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldLabel(
                                height: height,
                                label: "First Name",
                                top: 0,
                                bottom: height * 0.01,
                                left: 0,
                                right: 0,
                              ),
                              TextFieldWidget(
                                controller: _firstNameController,
                                hintText: "Input First Name Here",
                                errorText: "",
                                inputType: TextInputType.name,
                                enabled: false,
                              ),
                              TextFieldLabel(
                                height: height,
                                label: "Last Name",
                                top: height * 0.02,
                                bottom: height * 0.01,
                                left: 0,
                                right: 0,
                              ),
                              TextFieldWidget(
                                controller: _lastNameController,
                                hintText: "Input Last Name Here",
                                errorText: "Invalid Name",
                                inputType: TextInputType.name,
                                enabled: false,
                              ),
                              TextFieldLabel(
                                height: height,
                                top: height * 0.02,
                                right: 0,
                                left: 0,
                                bottom: height * 0.01,
                                label: "Phone Number",
                              ),
                              TextFormField(
                                enabled: _editable,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Phone number required";
                                  }
                                  if (!RegExp(_pattern).hasMatch(value)) {
                                    return "Please enter a valid phone number";
                                  }
                                  return null;
                                },
                                cursorColor: const Color(0xff152C5E),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                decoration: constants
                                    .kMessageTextFieldDecoration
                                    .copyWith(
                                  hintText: "+92----------",
                                ),
                              ),
                              Visibility(
                                visible:
                                    snapshot.data?.get('userType') == 'client'
                                        ? false
                                        : true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFieldLabel(
                                      height: height,
                                      label: "License Number",
                                      top: height * 0.02,
                                      bottom: height * 0.01,
                                      left: 0,
                                      right: 0,
                                    ),
                                    TextFieldWidget(
                                      controller: _licenceNumController,
                                      hintText: "Input License Number here",
                                      errorText:
                                          "Invalid or Empty License Number",
                                      inputType: TextInputType.number,
                                      enabled: _editable,
                                    ),
                                    TextFieldLabel(
                                      height: height,
                                      label: "Years of experience",
                                      top: height * 0.02,
                                      bottom: height * 0.01,
                                      left: 0,
                                      right: 0,
                                    ),
                                    TextFieldWidget(
                                      controller: _yearsOfExpController,
                                      hintText:
                                          "Input Years of Experience here",
                                      errorText: "Invalid or Empty Value",
                                      inputType: TextInputType.number,
                                      enabled: _editable,
                                      length: 1,
                                    ),
                                    TextFieldLabel(
                                      height: height,
                                      label: "Date of birth",
                                      top: height * 0.02,
                                      bottom: height * 0.01,
                                      left: 0,
                                      right: 0,
                                    ),
                                    TextFieldWidget(
                                      controller: _dobController,
                                      hintText: "Input DOB here",
                                      errorText: "",
                                      inputType: TextInputType.datetime,
                                      enabled: false,
                                    ),
                                  ],
                                ),
                              ),
                              TextFieldLabel(
                                height: height,
                                label: "CNIC",
                                top: height * 0.02,
                                bottom: height * 0.01,
                                left: 0,
                                right: 0,
                              ),
                              TextFieldWidget(
                                controller: _cnicController,
                                hintText: "Input CNIC here",
                                errorText: "",
                                inputType: TextInputType.datetime,
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _editable,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF152C5E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width - 33, 50)),
                      child: const Text(
                        "Update",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _editable = false;

                          await context
                              .read<FirestoreProvider>()
                              .uploadProfileData(
                                _imagePath ?? _imageUrl!,
                                _dobController.text,
                                int.parse(_yearsOfExpController.text),
                                int.parse(_cnicController.text),
                                int.parse(_licenceNumController.text),
                                _phoneController.text,
                                (_imagePath != null) ? true : false,
                              );
                          _imagePath = null;

                          Toast.toasts(
                            "Changes Applied Successfully",
                            const Color(0xFF2DD36F),
                            context,
                          );

                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
