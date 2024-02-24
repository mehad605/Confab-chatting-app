//Packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_image.dart';

//Providers
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService _navigation;

  String? _email;
  String? _password;
  String? _name;
  PlatformFile? _profileImage;
  bool _isLoading = false;

  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03,
                vertical: _deviceHeight * 0.02,
              ),
              height: _deviceHeight * 0.98,
              width: _deviceWidth * 0.97,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _profileImageField(),
                  SizedBox(
                    height: _deviceHeight * 0.05,
                  ),
                  _registerForm(),
                  // SizedBox(
                  //   height: _deviceHeight * 0.05,
                  // ),
                  // _verifyEmailButton(),
                  SizedBox(
                    height: _deviceHeight * 0.05,
                  ),
                  _registerButton(),
                  SizedBox(
                    height: _deviceHeight * 0.02,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
          (file) {
            setState(
              () {
                _profileImage = file;
              },
            );
          },
        );
      },
      child: () {
        if (_profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: _profileImage!,
            size: _deviceHeight * 0.15,
          );
        } else {
          return Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(
                color: Colors.black26, shape: BoxShape.circle),
            child: const Center(
              child: Text(
                "Select Image",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                regEx: r'.{6,}',
                hintText: "Name",
                obscureText: false),
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false),
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                regEx: r".{8,}",
                hintText: "Password",
                obscureText: true),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          setState(() {
            _isLoading = true;
          });
          _registerFormKey.currentState!.save();
          String? uid = await _auth.registerUserUsingEmailAndPassword(
              _email!, _password!);
          String? imageURL =
              await _cloudStorage.saveUserImageToStorage(uid!, _profileImage!);
          await _auth.sendEmailVerification();
          await _db.createUser(uid, _email!, _name!, imageURL!);
          await _auth.logout();
          await _auth.loginUsingEmailAndPassword(_email!, _password!);
          setState(() {
            _isLoading = false;
          });
        } else if (!_registerFormKey.currentState!.validate()) {
          Fluttertoast.showToast(msg: 'Please fill all the details');
        } else {
          Fluttertoast.showToast(msg: 'Image must be provided');
        }
      },
    );
  }

  // Widget _verifyEmailButton() {
  //   return Container(
  //     height: _deviceHeight * 0.065,
  //     width: _deviceWidth * 0.65,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
  //       color: const Color.fromARGB(
  //           255, 174, 0, 255), // Replace with your desired button color
  //     ),
  //     child: ElevatedButton(
  //       onPressed: () async {
  //         try {
  //           // Send email verification
  //           await _auth.sendEmailVerification();

  //           // Show a message to the user
  //           _showEmailVerificationMessage();
  //         } catch (e) {
  //           print("Error sending email verification: $e");
  //         }
  //       },
  //       style: ButtonStyle(
  //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //           RoundedRectangleBorder(
  //             borderRadius:
  //                 BorderRadius.circular(15), // Same radius as the container
  //           ),
  //         ),
  //         backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  //         elevation: MaterialStateProperty.all<double>(0), // No shadow
  //       ),
  //       child: const Text(
  //         "Verify Email",
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _showEmailVerificationMessage() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Email Verification'),
  //         content: const Text(
  //           'A verification email has been sent. Please check your email and verify your account.',
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
