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

  MyApp({super.key, required this.client});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

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

    // Handle any initial links
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink);
    }
  }

  void handleDeepLink(Uri uri) {
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'skill') {
      String skillId = uri.pathSegments[1];
      // Navigate to the SkillDetails page with the given skillId
      navigatorKey.currentState?.pushNamed('/skill/$skillId');
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
        if (settings.name?.startsWith('/skill/') ?? false) {
          final skillId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => SkillDetails(skillId: skillId),
          );
        }
        // Use the routes defined in routes.dart
        return MaterialPageRoute(
          builder: routes[settings.name] ?? (context) => const MyHomePage(title: ''),
          settings: settings,
        );
      },
      debugShowCheckedModeBanner: false,
      home: const CheckSessions(),
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

  SkillDetails({required this.skillId});

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
