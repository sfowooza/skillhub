import 'package:flutter/material.dart';
import 'package:skillhub/controllers/custom_widgets.dart';
import 'package:skillhub/pages/homePages/job_offers.dart';

class JobOffersStaggeredPage extends StatefulWidget {
  const JobOffersStaggeredPage({super.key, required String title});

  @override
  _JobOffersStaggeredPageState createState() => _JobOffersStaggeredPageState();
}

class _JobOffersStaggeredPageState extends State<JobOffersStaggeredPage>
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
          JobOffersPage(title: '',),
          CustomStaggeredMenu(
            drawerSlideController: _drawerSlideController,
            toggleDrawer: _toggleDrawer,
          ),
        ],
      ),
    );
  }
}