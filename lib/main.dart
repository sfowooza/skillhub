import 'dart:io';

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
      child: MyApp(client: client), // Pass the client to MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final Client client;

  MyApp({super.key, required this.client});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appwrite Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        // Use the routes defined in routes.dart
        return MaterialPageRoute(
          builder: routes[settings.name] ?? (context) => const MyHomePage(title: '',),
          settings: settings,
        );
      },
      debugShowCheckedModeBanner: false,
      home: const CheckSessions(), // Use CheckSessions as the home widget
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
