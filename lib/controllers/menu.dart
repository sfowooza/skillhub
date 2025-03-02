import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late AuthAPI authApi;
  late DatabaseAPI databaseApi;
  final Client client = Client();
  List<Document> newSkills = [];
  bool _isNewItemsExpanded = false;

  static const _menuTitles = [
    'Login',
    'Privacy Policy',
    'Documentation',
    'New Items',
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
    databaseApi = DatabaseAPI(auth: authApi);
    _fetchNewSkills();
    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _fetchNewSkills() async {
    try {
      final skills = await databaseApi.getAllSkills();
      setState(() {
        newSkills = skills.take(5).toList(); // Take first 5 skills
      });
    } catch (e) {
      print('Error fetching new skills: $e');
    }
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

    final buttonStartTime = Duration(milliseconds: (_menuTitles.length * 50)) + _buttonDelayTime;
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
    final isAuthenticated = Provider.of<AuthAPI>(context).status == AuthStatus.authenticated;

    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildAvodahLogo(),
          _buildContent(isAuthenticated),
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

  Widget _buildContent(bool isAuthenticated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ..._buildListItems(isAuthenticated),
        const Spacer(),
        _buildGetStartedButton(),
      ],
    );
  }

  List<Widget> _buildListItems(bool isAuthenticated) {
    final listItems = <Widget>[];
    
    // Create a modified list of menu titles based on authentication
    final displayMenuTitles = List<String>.from(_menuTitles);
    if (isAuthenticated) {
      // Replace 'Login' with 'Logout' if user is authenticated
      displayMenuTitles[0] = 'Logout';
    }
    
    for (var i = 0; i < displayMenuTitles.length; ++i) {
      listItems.add(
        AnimatedBuilder(
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
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    switch (displayMenuTitles[i]) {
                      case 'Login':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                        break;
                      case 'Logout':
                        authApi.signOut(context);
                        break;
                      case 'Privacy Policy':
                        _launchPrivacyPolicy();
                        break;
                      case 'Documentation':
                        _launchDocumentation();
                        break;
                      case 'New Items':
                        setState(() {
                          _isNewItemsExpanded = !_isNewItemsExpanded;
                        });
                        break;
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      displayMenuTitles[i] == 'New Items'
                          ? 'New Items (${newSkills.length})'
                          : displayMenuTitles[i],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (displayMenuTitles[i] == 'New Items' && _isNewItemsExpanded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: newSkills.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: Text(
                                'Loading skills...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ]
                        : newSkills.map<Widget>((skill) {
                            final title = skill.data['firstName'] as String? ?? 'Unknown';
                            final category = skill.data['selectedCategory'] as String? ?? 'Unknown';
                            final subCategory = skill.data['selectedSubcategory'] as String? ?? 'Unknown';
                            return Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SkillDetails(data: skill),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        //fontWeight: FontWeight.bold,
                                        color:  Colors.deepPurple,
                                      ),
                                    ),
                                    Text(
                                      '$category - $subCategory',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return listItems;
  }

  void _launchPrivacyPolicy() async {
    const privacyPolicyUrl = 'https://avodahsystems.com/?page_id=101';
    if (await canLaunch(privacyPolicyUrl)) {
      await launch(privacyPolicyUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch Privacy Policy')),
      );
    }
  }

  void _launchDocumentation() async {
    const documentationUrl = 'https://avodahsystems.com/?page_id=154';
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
              Navigator.pushNamed(context, '/');
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}