import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/storage_api.dart';
import 'package:skillhub/appwrite/likes_api.dart';
import 'package:skillhub/providers/registration_form_providers.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:skillhub/pages/homePages/home_cards/category_homePage.dart';
import 'package:skillhub/pages/homePages/skill_detail_loader.dart';
import 'package:skillhub/routes/routes.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skillhub/models/registration_fields.dart';
import 'dart:async';

// MyHttpOverrides class at top level
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthAPI()),
        ChangeNotifierProxyProvider<AuthAPI, DatabaseAPI>(
          create: (context) => DatabaseAPI(auth: context.read<AuthAPI>()),
          update: (context, auth, previous) => previous ?? DatabaseAPI(auth: auth),
        ),
        ChangeNotifierProxyProvider<AuthAPI, StorageAPI>(
          create: (context) => StorageAPI(auth: context.read<AuthAPI>()),
          update: (context, auth, previous) => previous ?? StorageAPI(auth: auth),
        ),
        ChangeNotifierProxyProvider<AuthAPI, LikesAPI>(
          create: (context) => LikesAPI(auth: context.read<AuthAPI>()),
          update: (context, auth, previous) => previous ?? LikesAPI(auth: auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    
    // Delay deep link initialization to improve startup performance
    Future.delayed(const Duration(milliseconds: 300), () {
      initDeepLinks();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    try {
      _appLinks = AppLinks();

      // Handle incoming links with error handling
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          handleDeepLink(uri);
        }
      }, onError: (error) {
        print('Error in deep link stream: $error');
      });

      // Handle any initial links with timeout to prevent blocking
      final initialLink = await _appLinks.getInitialLink().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Initial link fetch timed out');
          return null;
        },
      );
      
      if (initialLink != null) {
        handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Deep link initialization error: $e');
      // Continue even if deep link initialization fails
    }
  }

  void handleDeepLink(Uri uri) {
    print('Handling deep link: ${uri.toString()}');
    
    try {
      // Process deep links off the main thread to avoid UI jank
      Future.microtask(() {
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
          
          // Navigate directly to home page for now
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const CategoryHomePage(),
            ),
            (route) => false,
          ).then((_) {
            setState(() => _isHandlingDeepLink = false);
          });
        } else {
          print('Skill ID is null or empty, navigation failed.');
          setState(() => _isHandlingDeepLink = false);
        }
      }
      });
    } catch (e) {
      print('Deep link handling error: $e');
      setState(() => _isHandlingDeepLink = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthAPI()),
        ChangeNotifierProxyProvider<AuthAPI, DatabaseAPI>(
          create: (context) => DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false)),
          update: (context, auth, previous) => DatabaseAPI(auth: auth),
        ),
        ChangeNotifierProvider(create: (context) => RegistrationFormProvider()),
      ],
      child: MaterialApp(
        title: 'SkillsHub',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        try {
          // Handle reset password route
          if (settings.name?.startsWith('/reset-password') ?? false) {
            final uri = Uri.parse(settings.name!);
            final userId = uri.queryParameters['userId'];
            final secret = uri.queryParameters['secret'];
            
            if (userId != null && secret != null) {
              // For now, redirect to home page instead of ResetPasswordPage
              return MaterialPageRoute(
                builder: (context) => const CategoryHomePage(),
              );
            }
          }
          
          // Handle shared skill detail links (/skill/:skillId)
          if (settings.name?.startsWith('/skill/') ?? false) {
            final skillId = settings.name!.substring('/skill/'.length);
            if (skillId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (context) => SkillDetailLoader(skillId: skillId),
              );
            }
          }
        } catch (e) {
          print('Route generation error: $e');
        }
        // Use the routes defined in routes.dart for other routes
        return MaterialPageRoute(
          builder: routes[settings.name] ?? (context) => const CategoryHomePage(),
          settings: settings,
        );
      },
        debugShowCheckedModeBanner: false,
        home: _isHandlingDeepLink ? null : const CategoryHomePage(),
      ),
    );
  }
}

class ResetPasswordPage extends StatelessWidget {
  final String userId;
  final String secret;

  const ResetPasswordPage({super.key, required this.userId, required this.secret});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Text('Reset Password for User ID: $userId with Secret: $secret'),
      ),
    );
  }
}