// import 'package:skillshub/pages/Auth_screens/account_page.dart';
// import 'package:skillshub/pages/staggered_homePages/addMessages.dart';
// import 'package:flutter/material.dart';
// import 'package:skillshub/pages/staggered_homePages/addMessages.dart';

// import '../Auth_screens/account_page.dart';
// import '../staggered_homePages/loadedMessages.dart';

// class TabsPage extends StatefulWidget {
//   const TabsPage({Key? key}) : super(key: key);

//   @override
//   _TabsPageState createState() => _TabsPageState();
// }

// class _TabsPageState extends State<TabsPage> {
//   int _selectedIndex = 0;

//   static const _widgets = [MessageStaggeredPage(), LoadedMessageStaggeredPage(), AccountPage()];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgets.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.message_outlined), label: "AddMessages"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.message_outlined), label: "Messages"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.account_circle_outlined), label: "Account")
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
