// import 'package:skillshub/pages/messages_screens/loaded_messages_page.dart';
// import 'package:skillshub/pages/Auth_screens/register_page.dart';
// import 'package:flutter/material.dart';

// class BottomNavigation extends StatelessWidget {
//   final VoidCallback onLoginPressed;
//   final VoidCallback onSignUpPressed;

//   const BottomNavigation({
//     required this.onLoginPressed,
//     required this.onSignUpPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             onPressed: onLoginPressed,
//             child: const Row(
//               children: [
//                 Icon(Icons.person_outlined),
//                 SizedBox(width: 5), // Space between icon and text
//                 Text('Login to Update',style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 17,
//                   ),), // Text "Login"
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: onSignUpPressed,
//             child: const Row(
//               children: [
//                 Icon(Icons.how_to_reg),
//                 SizedBox(width: 5), // Space between icon and text
//                 Text(
//                   'Register to Post',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 17,
//                   ),
//                 ), // Text "Sign Up"
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
