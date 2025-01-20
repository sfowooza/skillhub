
import 'package:flutter/material.dart';
import 'package:skillhub/controllers/custom_widgets.dart';
import 'package:skillhub/pages/homePages/home_cards/category_homePage.dart';

class MyHomeCategoryPage extends StatefulWidget {
  const MyHomeCategoryPage({Key? key});

  @override
  _MyHomeCategoryPageState createState() => _MyHomeCategoryPageState();
}

class _MyHomeCategoryPageState extends State<MyHomeCategoryPage>
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
          const CategoryHomePage(),
          CustomStaggeredMenu(
            drawerSlideController: _drawerSlideController,
            toggleDrawer: _toggleDrawer,
          ),
        ],
      ),
    );
  }
}
