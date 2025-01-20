import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/forgot_password_page.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/homePages/skills_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  BaseColors baseColor = BaseColors();
  bool _passwordVisible = true;
  double iconSize = 19;

signIn() async {
  if (_formKey.currentState!.validate()) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
            ]
          ),
        );
      }
    );

    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      
      // First try to get current user to check verification
      if (appwrite.status == AuthStatus.authenticated && !appwrite.currentUser.emailVerification) {
        // User is logged in but email not verified
        Navigator.pop(context); // Close loading dialog
        
        // Send new verification email
        await appwrite.createEmailVerification(
          url: 'https://verify.skillhub.avodahsystems.com/verification',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email. A new verification link has been sent.'),
            duration: Duration(seconds: 5),
          ),
        );

        // Sign out the unverified user
        await appwrite.signOut(context);
        return;
      }

      // Attempt login
      final loginSuccess = await appwrite.createEmailSession(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      if (!loginSuccess) {
        Navigator.pop(context);
        return;
      }

      // Check verification status after login
      if (!appwrite.currentUser.emailVerification) {
        Navigator.pop(context); // Close loading dialog
        
        // Send verification email
        await appwrite.createEmailVerification(
          url: 'https://verify.skillhub.avodahsystems.com/verification',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email before logging in. Check your inbox for the verification link.'),
            duration: Duration(seconds: 5),
          ),
        );

        // Sign out since email isn't verified
        await appwrite.signOut(context);
        return;
      }

      // Email is verified - proceed with login
      Navigator.pop(context); // Close loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const JobOffersStaggeredPage(title: 'Job Offers')
        ),
      );
      
    } on AppwriteException catch (e) {
      Navigator.pop(context);
      // Handle nullable message
      final String errorMessage = e.message?.contains('Creation of a session is prohibited') == true
          ? 'Please verify your email first. Check your inbox for the verification link.'
          : e.message ?? 'An error occurred during login';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

  showAlert({required String title, required String text}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  signInWithProvider(OAuthProvider provider) {
    try {
      context.read<AuthAPI>().signInWithProvider(provider: provider);
    } on AppwriteException catch (e) {
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '🛠️ SkillsHub',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: baseColor.baseTextColor),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text.rich(
                    TextSpan(
                      text: 'Sign in now to get ',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: baseColor.baseTextColor),
                      children: [
                        TextSpan(
                          text: 'started',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'SkillsHub connects you to local talent & Local Job Offers near you.',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 17, bottom: 25, left: 12, right: 12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            size: iconSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        obscureText: _passwordVisible,
                        controller: passwordTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                size: iconSize,
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, size: iconSize)),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 67.0, left: 12),
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),
                Container(
                  height: 57,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: Text(
                      'Login',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600, fontSize: 21),
                    ),
                    onPressed: () => signIn(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: baseColor.baseTextColor),
                      ),
                      TextButton(
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500, fontSize: 17),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()));
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => signInWithProvider(OAuthProvider.google),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white),
                      child:
                          SvgPicture.asset('assets/google_icon.svg', width: 12),
                    ),
                    ElevatedButton(
                      onPressed: () => signInWithProvider(OAuthProvider.apple),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white),
                      child: SvgPicture.asset('assets/apple_icon.svg', width: 12),
                    ),
                    ElevatedButton(
                      onPressed: () => signInWithProvider(OAuthProvider.github),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white),
                      child:
                          SvgPicture.asset('assets/github_icon.svg', width: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
