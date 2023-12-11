//Packages
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloud_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/authentication_provider.dart';
import '../services/navigation_service.dart';
import '../services/database_service.dart' hide USER_COLLECTION;

// User model - Replace with your actual User model structure

AuthenticationProvider authenticationProvider = AuthenticationProvider(
  firebaseAuth: FirebaseAuth.instance,
  googleSignIn: GoogleSignIn(),
  navigationService: NavigationService(),
  databaseService: DatabaseService(),
);

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user;
  String? userName;
  String? userEmail;
  String? userImageURL;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    user = authenticationProvider.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await DatabaseService().getUser(user!.uid);
      userName = userData.get('name') as String?;
      userEmail = userData.get('email') as String?;
      userImageURL = userData.get('image') as String?;
      setState(() {});
    }
  }

  Future<void> changeProfilePhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('images/users/${user!.uid}/profile.${file.extension}');

        UploadTask uploadTask = ref.putFile(
          File('${file.path}'),
        );

        TaskSnapshot snapshot = await uploadTask;
        if (snapshot.state == TaskState.success) {
          String? imageURL = await snapshot.ref.getDownloadURL();

          // Delete old image if it exists
          if (userImageURL != null) {
            await FirebaseStorage.instance.refFromURL(userImageURL!).delete();
          }

          // Update user's image URL in Firestore
          await FirebaseFirestore.instance
              .collection(USER_COLLECTION)
              .doc(user!.uid)
              .update({'image': imageURL});

          setState(() {
            userImageURL = imageURL;
          });
        }
      } else {
        // User didn't select an image
        // You can inform the user or handle this scenario accordingly
        print('No image selected.');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // Inform the user about the error
      // You might want to display a snackbar or toast to inform the user about the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Profile',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    color: Color.fromARGB(255, 246, 241, 171),
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color.fromARGB(255, 246, 241, 171),
            ),
            user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: changeProfilePhoto,
                        child: Stack(
                          children: [
                            userImageURL != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userImageURL!),
                                    radius: 70,
                                  )
                                : Container(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromRGBO(33, 33, 33, 1),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 246, 241, 171),
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: changeProfilePhoto,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: const Color(0xFF2E3440),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Name:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        Colors.white, // Added white font color
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color:
                                        Color(0xFFB0BEC5), // Blueish gray color
                                  ),
                                  onPressed: () {
                                    _editUserName(context);
                                  },
                                ),
                              ],
                            ),
                            // const SizedBox(height: 4),
                            Text(
                              userName ?? "Loading...",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white, // Added white font color
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Email:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white, // Added white font color
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail ?? "No email",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white, // Added white font color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _editUserName(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Edit Name'),
          content: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Name',
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: const Color.fromARGB(
                    255, 174, 0, 255), // Change the button's background color
              ),
              onPressed: () async {
                // Update the local state
                setState(() {
                  userName = nameController.text;
                });

                // Update the user's name in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection(
                          'Users') // Replace 'Users' with your collection name
                      .doc(user!.uid)
                      .update({'name': nameController.text});
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating name: $e');
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
