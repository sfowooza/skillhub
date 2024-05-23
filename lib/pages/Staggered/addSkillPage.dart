import 'dart:io';

import 'package:skillhub/controllers/menu.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/pages/homePages/skills_page.dart';




class AddSkillPage extends StatefulWidget {
  const AddSkillPage({super.key});

  @override
  _AddSkillPageState createState() => _AddSkillPageState();
}

class _AddSkillPageState extends State<AddSkillPage>
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

  // Inside the _showMenuOptions method

  bool _isDrawerOpen() {
    return _drawerSlideController.value == 1.0;
  }

  bool _isDrawerOpening() {
    return _drawerSlideController.status == AnimationStatus.forward;
  }

  bool _isDrawerClosed() {
    return _drawerSlideController.value == 0.0;
  }

  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawerSlideController.reverse();
    } else {
      _drawerSlideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildContent(),
          _buildDrawer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Center(
        child: Text(
          'Explore SkillsHub ',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Platform.isIOS
            ? const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )
            : const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        AnimatedBuilder(
          animation: _drawerSlideController,
          builder: (context, child) {
            return IconButton(
              onPressed: _toggleDrawer,
              icon: _isDrawerOpen() || _isDrawerOpening()
                  ? const Icon(
                      Icons.clear,
                      color: Colors.black,
                    )
                  : const Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    return const Center(
      child: Center(
        child: SkillsPage(),
      ),
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _drawerSlideController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(1.0 - _drawerSlideController.value, 0.0),
          child: _isDrawerClosed() ? const SizedBox() : const Menu(),
        );
      },
    );
  }
}
