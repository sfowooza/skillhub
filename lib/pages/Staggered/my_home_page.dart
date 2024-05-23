// my_home_page.dart
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/controllers/custom_widgets.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required String title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerSlideController;

  @override
  void initState() {
    _drawerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    super.initState();
  }

  @override
  void dispose() {
    _drawerSlideController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawerSlideController.reverse();
    } else {
      _drawerSlideController.forward();
    }
  }

  bool _isDrawerOpen() {
    return _drawerSlideController.value == 1.0;
  }

  bool _isDrawerOpening() {
    return _drawerSlideController.status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(onMenuPressed: _toggleDrawer),
      body: Stack(
        children: [
          const LoginPage(),
          CustomStaggeredMenu(
            drawerSlideController: _drawerSlideController,
            toggleDrawer: _toggleDrawer,
          ),
        ],
      ),
    );
  }
}
