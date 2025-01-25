import 'package:skillhub/pages/Auth_screens/account_page.dart';
import 'package:skillhub/pages/Auth_screens/forgot_password_page.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
// import 'package:skillshub/pages/homePages/category_home_page.dart';
import 'package:skillhub/pages/Staggered/my_home_page.dart';
// import 'package:skillshub/pages/homePages/subCategory_home_page.dart';
// import 'package:skillshub/pages/messages_screens/loaded_messages_page.dart';
// import 'package:skillshub/pages/messages_screens/messages_page.dart';
// import 'package:skillshub/pages/staggered_homePages/loadedMessages.dart';
import 'package:flutter/material.dart';


// Define the routes using a Map
final Map<String, WidgetBuilder> routes = {
  //'/': (context) => const MyHomePage(title: 'Explore SkillsHub',),
  '/':(context) => MyHomeCategoryPage(),
   '/jobs': (context) => const JobOffersStaggeredPage(
  title: '',
  selectedSubCategory: null, // or 'All' depending on your preference
),
  // '/messages': (context) => const MessagesPage(),
  // '/account': (context) => const AccountPage(),
   '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forgot_password': (context) => const ForgotPasswordPage(),
  // '/job_offers': (context) => const JobOffersPage(),
  // Add more routes for other pages
};
