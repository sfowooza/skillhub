// Removed Appwrite imports for simplified app
// Removed Appwrite enums import for simplified app
// import package:appwrite/enums.dart - using stubs
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
              ],
            ),
          );
        },
      );

      try {
        final AuthAPI appwrite = context.read<AuthAPI>();

        // Clear any existing session before attempting to log in
        try {
          await appwrite.signOut(context);
        } catch (e) {
          // If no session exists, this will throw an error, which we can ignore
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
        await appwrite.loadUser(); // Ensure we have the latest user data
        if (!appwrite.currentUser['emailVerification']) {
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

          // Do not sign out, let the user verify their email or try again
          return;
        }

        // Email is verified - proceed with login
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JobOffersStaggeredPage(
              title: 'Job Offers',
              selectedSubCategory: null, // or 'All'
            ),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        // Handle nullable message
        final String errorMessage = e.toString().contains('Creation of a session is prohibited')
            ? 'Please verify your email first or sign out from any active session. Check your inbox for the verification link.'
            : e.toString();

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

  signInWithProvider(dynamic provider) {
    try {
      context.read<AuthAPI>().signInWithProvider(provider: provider);
    } catch (e) {
      showAlert(title: 'Login failed', text: e.toString());
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
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    const Text(
      'Back',
      style: TextStyle(fontSize: 16),
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