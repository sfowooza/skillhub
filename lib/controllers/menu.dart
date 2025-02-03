import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:url_launcher/url_launcher.dart';


class Menu extends StatefulWidget {
  const Menu({Key? key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {

 late AuthAPI authApi;
  final Client client = Client();

 

  static const _menuTitles = [
    'Login',
    'Privacy Policy',
    'Documentation',
  ];

  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration = _initialDelayTime +
      (_staggerTime * _menuTitles.length) +
      _buttonDelayTime +
      _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];
  late Interval _buttonInterval;

  @override
  void initState() {
    super.initState();
   authApi = AuthAPI(client: client);
    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuTitles.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }

    final buttonStartTime =
        Duration(milliseconds: (_menuTitles.length * 50)) + _buttonDelayTime;
    final buttonEndTime = buttonStartTime + _buttonTime;
    _buttonInterval = Interval(
      buttonStartTime.inMilliseconds / _animationDuration.inMilliseconds,
      buttonEndTime.inMilliseconds / _animationDuration.inMilliseconds,
    );
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildAvodahLogo(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildAvodahLogo() {
    return Positioned(
      right: -100,
      bottom: -30,
      child: Opacity(
        opacity: 0.2,
        child: Image.asset(
          'assets/avd1.png',
          width: 400,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ..._buildListItems(),
        const Spacer(),
        _buildGetStartedButton(),
      ],
    );
  }

List<Widget> _buildListItems() {
  final listItems = <Widget>[];
  for (var i = 0; i < _menuTitles.length; ++i) {
    listItems.add(
      GestureDetector(
        onTap: () {
          // Handle menu item tap with different actions based on title
          switch (_menuTitles[i]) {
            case 'Login':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            //   break;
            // case 'Reset Password':
            //   Navigator.of(context).pushNamed('/reset_password');
              break;
            case 'Privacy Policy':
              _launchPrivacyPolicy();
              break;
            case 'Documentation':
              _launchDocumentation();
              break;
          }
        },
        child: AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.easeOut.transform(
              _itemSlideIntervals[i].transform(_staggeredController.value),
            );
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(slideDistance, 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _menuTitles[i],
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  return listItems;
}

// Add these helper methods for launching URLs
void _launchPrivacyPolicy() async {
  const privacyPolicyUrl = 'https://avodahsystems.com/?page_id=101'; // Replace with your actual URL
  if (await canLaunch(privacyPolicyUrl)) {
    await launch(privacyPolicyUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch Privacy Policy')),
    );
  }
}

void _launchDocumentation() async {
  const documentationUrl = 'https://yourapp.com/documentation'; // Replace with your actual URL
  if (await canLaunch(documentationUrl)) {
    await launch(documentationUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch Documentation')),
    );
  }
}

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.elasticOut.transform(
              _buttonInterval.transform(_staggeredController.value),
            );
            final opacity = animationPercent.clamp(0.0, 1.0);
            final scale = (animationPercent * 0.5) + 0.5;

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            onPressed: () {
              // Navigate to the home page ('/')
              Navigator.pushNamed(context, '/');
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(
                color: Color.fromARGB(255, 199, 170, 170),
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}