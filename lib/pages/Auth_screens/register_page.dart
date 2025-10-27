// Removed Appwrite import for simplified app
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  bool loading = false;
  BaseColors baseColor = BaseColors();
  bool _passwordVisible = true;
  double iconSize = 19;
  String? _verificationId;

  void createAccount() async {
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
          });

      try {
        final AuthAPI appwrite = context.read<AuthAPI>();
        final result = await appwrite.createUserAccount(
          email: emailTextController.text,
          password: passwordTextController.text,
          username: usernameTextController.text,
        );

        Navigator.pop(context); // Close loading dialog

        if (result['success']) {
          print('Registration and login successful');
          
          // Show success message
          showAlert(
            title: 'Registration Successful', 
            text: 'Welcome to SkillHub! You are now logged in.',
          );
          
          // Navigate to home page after successful registration and login
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/');
          });
        } else {
          showAlert(
            title: 'Registration Failed', 
            text: result['message'] ?? 'Unable to create account. Please try again.',
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        showAlert(title: 'Account creation failed', text: e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: Text(
                  '🛠️ SkillsHub',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: Colors.black, // Adjust color as needed
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: Text.rich(
                  TextSpan(
                    text: 'Create an account & find',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: Colors.black, // Adjust color as needed
                    ),
                    children: [
                      TextSpan(
                        text: 'Skills',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'SkillsHub helps you connect to skilled labour & Jobs in Uganda.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 17, bottom: 25, left: 12, right: 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameTextController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person,
                          size: iconSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailTextController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email';
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
                      obscureText: !_passwordVisible,
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
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            size: iconSize,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, size: iconSize),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      obscureText: !_passwordVisible,
                      controller: confirmPasswordTextController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordTextController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            size: iconSize,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock, size: iconSize),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Container(
                height: 57,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: Text(
                    'Sign up',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                  ),
                  onPressed: createAccount,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.black, // Adjust color as needed
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Log in',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Theme.of(context).primaryColor, // Adjust color as needed
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    )
                  ],
                ),
                margin: const EdgeInsets.only(left: 12.0),
              ),
              const SizedBox(height: 16), // Added spacing before back button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}