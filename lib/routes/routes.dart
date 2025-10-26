import 'package:skillhub/pages/Auth_screens/account_page.dart';
import 'package:skillhub/pages/Auth_screens/forgot_password_page.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';

import 'package:skillhub/pages/Staggered/my_home_page.dart';
import 'package:skillhub/pages/homePages/home_page.dart';

import 'package:flutter/material.dart';
import 'package:skillhub/pages/Auth_screens/reset_password_page.dart'; 

// Define the routes using a Map
final Map<String, WidgetBuilder> routes = {
  '/': (context) => const MyHomeCategoryPage(),
  '/home':(context) => const MyHomeCategoryPage(),
   '/jobs': (context) => const JobOffersStaggeredPage(
  title: '',
  selectedSubCategory: null, // or 'All' depending on your preference
),
  // '/messages': (context) => const MessagesPage(),
  // '/account': (context) => const AccountPage(),
   '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forgot_password': (context) => const ForgotPasswordPage(),

  '/reset-password': (context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return ResetPasswordPage(
      userId: routeArgs?['userId'] ?? '',
      secret: routeArgs?['secret'] ?? '',
    );
  },
  // Add more routes for other pages
};