import 'dart:io';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/pages/Auth_screens/checkSession.dart';
import 'package:skillhub/pages/Auth_screens/forgot_password_page.dart';
import 'package:skillhub/pages/Staggered/my_home_page.dart';
import 'package:skillhub/pages/nav_tabs/tabs_page.dart';
import 'package:skillhub/providers/registration_form_providers.dart';
import 'package:skillhub/routes/routes.dart';
import 'appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await SavedData.init();
  final client = Client();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthAPI(client: client)),
        ChangeNotifierProvider(create: (_) => RegistrationFormProvider()),
        Provider<Client>(
          create: (_) => client,
        ),
        Provider<Account>(
          create: (context) => Account(context.read<Client>()),
        ),
      ],
      child: MyApp(client: client),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Client client;

  const MyApp({Key? key, required this.client}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    });

    // Handle any initial links when the app is launched
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink);
    }
  }

void handleDeepLink(Uri uri) {
  print('Handling deep link: ${uri.toString()}');
  
  // Reset password handling
  if (uri.path == '/reset-password') {
    // Reset password code unchanged
  }
  // Skill details handling
  else if (uri.host == 'skill' || uri.path.contains('/skill/')) {
    // Extract the skill ID from either host or path
    String? skillId;
    
    if (uri.host == 'skill' && uri.path.isNotEmpty) {
      // Handle skillhub://skill/123456
      skillId = uri.path.replaceFirst('/', '');
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments.contains('skill')) {
      // Handle https://skillhub.avodahsystems.com/skillhub/skill/123456
      final index = uri.pathSegments.indexOf('skill');
      if (index >= 0 && index < uri.pathSegments.length - 1) {
        skillId = uri.pathSegments[index + 1];
      }
    }
    
    if (skillId != null && skillId.isNotEmpty) {
      print('Navigating to SkillDetails with skillId: $skillId');
      setState(() => _isHandlingDeepLink = true);
      
      // Use the non-null skillId since we've checked it's not null
      final String nonNullSkillId = skillId;
      
      // Call database to get the skill data
      final databaseAPI = DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false));
      
      databaseAPI.getSkillById(nonNullSkillId).then((skillData) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SkillDetails(skillId: nonNullSkillId),
          ),
          (route) => false,
        ).then((_) {
          setState(() => _isHandlingDeepLink = false);
        });
      }).catchError((error) {
        print('Error fetching skill data: $error');
        setState(() => _isHandlingDeepLink = false);
        // Show error message to user
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Error loading skill data. Please try again.')),
        );
      });
    } else {
      print('Skill ID is null or empty, navigation failed.');
      setState(() => _isHandlingDeepLink = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillsHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        // Handle skill details route
        if (settings.name?.startsWith('/skill/') ?? false) {
          final skillId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => SkillDetails(skillId: skillId),
          );
        }
        // Handle reset password route
        if (settings.name?.startsWith('/reset-password') ?? false) {
          final uri = Uri.parse(settings.name!);
          final userId = uri.queryParameters['userId'];
          final secret = uri.queryParameters['secret'];
          
          if (userId != null && secret != null) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                userId: userId,
                secret: secret,
              ),
            );
          }
        }
        // Use the routes defined in routes.dart for other routes
        return MaterialPageRoute(
          builder: routes[settings.name] ?? (context) => const MyHomePage(title: ''),
          settings: settings,
        );
      },
      debugShowCheckedModeBanner: false,
      home: _isHandlingDeepLink ? null : const CheckSessions(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class SkillDetails extends StatelessWidget {
  final String skillId;

  const SkillDetails({Key? key, required this.skillId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skill Details'),
      ),
      body: Center(
        child: Text('Displaying details for skill: $skillId'),
      ),
    );
  }
}

class ResetPasswordPage extends StatelessWidget {
  final String userId;
  final String secret;

  const ResetPasswordPage({Key? key, required this.userId, required this.secret}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Center(
        child: Text('Reset Password for User ID: $userId with Secret: $secret'),
      ),
    );
  }
}