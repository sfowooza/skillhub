// import 'dart:io';

// import 'package:appwrite/appwrite.dart';
// import 'package:flutter/material.dart';
// import 'package:skillshub/appwrite/auth_api.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:provider/provider.dart';

// class AccountPage extends StatefulWidget {
//   const AccountPage({Key? key}) : super(key: key);

//   @override
//   _AccountPageState createState() => _AccountPageState();
// }

// class _AccountPageState extends State<AccountPage> {
//   late String? email;
//   late String? username;
//   TextEditingController bioTextController = TextEditingController();
//   TextEditingController phoneTextController = TextEditingController();
//   String? _selectedImagePath; // Store the selected image path

//   @override
//   void initState() {
//     super.initState();
//     final AuthAPI appwrite = context.read<AuthAPI>();
//     email = appwrite.email;
//     username = appwrite.username;
//     appwrite.getUserPreferences().then((value) {
//       if (value.data.isNotEmpty) {
//         setState(() {
//           bioTextController.text = value.data['bio'];
//           phoneTextController.text = value.data['phone'];
//         });
//       }
//     });
//   }

//   // Function to handle image selection
//   Future<void> _pickImage() async {
//     try {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//     );
//     if (result != null) {
//       setState(() {
//         _selectedImagePath = result.files.single.path;
//       });
//     }} catch (e) { print ('Error picnking image: $e'); }
//     }
  
// // Function to upload profile image to Appwrite storage
// Future<void> _uploadProfileImage() async {
//   if (_selectedImagePath != null) {
//     final AuthAPI appwrite = context.read<AuthAPI>();
//     try {
//       final upload = await appwrite.storage.createFile(
//         bucketId: '662206ef002ab1e924ea', // Replace with your bucket ID
//         file: InputFile(path: _selectedImagePath!), fileId: 'unique()', // Ensure you generate a unique file ID
//       );
//       // Assuming 'upload' is the response object from Appwrite that contains the file ID
//       final imageUrl = 'https://coffee.avodahsystems.com/v1/storage/files/${upload.$id}/view'; // Construct the URL using the file ID
//       // Save the image URL to user preferences or database
//       // (e.g., update the 'profileImage' field in your preferences)
      
//       print('Uploaded image URL: $imageUrl');
//     } catch (e) {
//       print('Error uploading image: $e');
//     }
//   }
// }

//   // Function to save user preferences
//   void _savePreferences() {
//     final AuthAPI appwrite = context.read<AuthAPI>();
//     appwrite.updatePreferences(
//       bio: bioTextController.text,
//       phone: phoneTextController.text,
//       profileImage: _selectedImagePath != null ? 'url_of_uploaded_image' : null,
//     );
//     const snackbar = SnackBar(content: Text('Preferences updated!'));
//     ScaffoldMessenger.of(context).showSnackBar(snackbar);
//   }

//     signOut() {
//     final AuthAPI appwrite = context.read<AuthAPI>();
//     appwrite.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Account'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               signOut();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                     // Display avatar if profile image is uploaded
//               if (_selectedImagePath != null)
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: FileImage(File(_selectedImagePath!)),
//                 ),
//                 const SizedBox(height: 16),
//                 Text('Welcome back $username!',
//                     style: Theme.of(context).textTheme.headlineSmall),
//                 Text('$email'),
//                 const SizedBox(height: 40),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: bioTextController,
//                           decoration: const InputDecoration(
//                             labelText: 'Your Bio',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: phoneTextController,
//                           decoration: const InputDecoration(
//                             labelText: 'Your Phone Number',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _pickImage, // Call image picker
//                           child: const Text('Pick Profile Image'),
//                         ),
//                         if (_selectedImagePath != null)
//                           Image.file(File(_selectedImagePath!)),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _uploadProfileImage, // Call image uploader
//                           child: const Text('Upload Profile Image'),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _savePreferences, // Save preferences
//                           child: const Text('Save Preferences'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }