import 'package:skillhub/controllers/menu.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const CustomAppBar({required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(
        child: Text(
          'Explore SkillsHub',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomStaggeredMenu extends StatelessWidget {
  final AnimationController drawerSlideController;
  final VoidCallback toggleDrawer;

  const CustomStaggeredMenu({
    required this.drawerSlideController,
    required this.toggleDrawer,
  });

  bool _isDrawerOpen() {
    return drawerSlideController.value == 1.0;
  }

  bool _isDrawerOpening() {
    return drawerSlideController.status == AnimationStatus.forward;
  }

  bool _isDrawerClosed() {
    return drawerSlideController.value == 0.0;
  }

  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      drawerSlideController.reverse();
    } else {
      drawerSlideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: drawerSlideController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(1.0 - drawerSlideController.value, 0.0),
          child: _isDrawerClosed() ? const SizedBox() : const Menu(),
        );
      },
    );
  }
}
