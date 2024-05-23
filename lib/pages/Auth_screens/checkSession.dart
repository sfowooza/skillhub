import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/pages/Staggered/my_home_page.dart';

class CheckSessions extends StatefulWidget {
  const CheckSessions({super.key});

  @override
  State<CheckSessions> createState() => _CheckSessionsState();
}

class _CheckSessionsState extends State<CheckSessions> {
  late AuthAPI authAPI;

  @override
  void initState() {
    super.initState();
    authAPI = Provider.of<AuthAPI>(context, listen: false);
    checkUserSession();
  }

  Future<void> checkUserSession() async {
    final user = await authAPI.loadUser();
    if (authAPI.status == AuthStatus.authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const JobOffersStaggeredPage(title: ''),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'SkillHub'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
