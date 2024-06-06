// ignore_for_file: nullable_type_in_catch_clause

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:my_app/environment.dart';
// import 'package:my_app/authScreens/forgot_password_page.dart';
// import 'package:my_app/authScreens/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillhub/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggedIn = false;
  late Client client;
  late Account account;
  //Environment env = Environment();
  BaseColors baseColor = BaseColors();
  bool _passwordVisible = true;
  double iconSize = 19;

  @override
  void initState() {
    super.initState();
    client = Client();
    account = Account(client);
//    client
    // .setEndpoint(env.appWriteClientDbUrl)
    // .setProject(env.appWriteClientProject);
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      isLoggedIn = true;
      try {
        await account.createRecovery(
          email: nameController.text.trim(),
          url: 'https://skillhub.avodahsystems.com',
        );
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password Recovery Email Sent'),
            );
          },
        );
      } on AppwriteException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.message!.contains('email')) {
          errorMessage = 'Please enter a valid email address';
        } else if (e.message!.contains('already')) {
          errorMessage =
              'A recovery email has already been sent for this account';
        } else {
          errorMessage = 'An unknown error occurred';
        }
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 55),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 27),
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
                    text: 'Recover your ',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        color: baseColor.baseTextColor),
                    children: [
                      TextSpan(
                        text: 'password anytime',
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
                  'Enter your email now, and password reset instrustions will be sent.',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 17, bottom: 25, left: 12, right: 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
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
                    const SizedBox(height: 15)
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Container(
                height: 57,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: Text(
                    'Recover Password',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, fontSize: 21),
                  ),
                  onPressed: _submitForm,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: baseColor.baseTextColor),
                    ),
                    TextButton(
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                    )
                  ],
                ),
                margin: EdgeInsets.only(left: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
