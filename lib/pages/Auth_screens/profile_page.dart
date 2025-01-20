import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/rsvp_events.dart';

class Profile extends StatefulWidget {
   final AuthAPI auth;

  Profile({required this.auth});

  @override
  State<Profile> createState() => _ProfileState(auth: auth);
}

class _ProfileState extends State<Profile> {
  String name = "";
  String email = "";
final AuthAPI auth;
 _ProfileState({required this.auth});
  @override
  void initState() {
    super.initState();
    name = SavedData.getUserName();
    email = SavedData.getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      color: BaseColors().baseTextColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 24),
                ),
                Text(
                  email,
                  style: TextStyle(
                      color: BaseColors().baseTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RSVPEvents())),
                    title: Text(
                      "RSVP Events",
                      style: TextStyle(color: BaseColors().baseTextColor,),
                    ),
                  ),
                  // ListTile(
                  //   onTap: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ManageEvents())),
                  //   title: Text(
                  //     "Manage Events",
                  //     style: TextStyle(color: BaseColors().baseTextColor,),
                  //   ),
                  // ),
                  ListTile(
                    onTap: () {
                      auth.signOut(context);
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    title: Text(
                      "Logout",
                      style: TextStyle(color: BaseColors().baseTextColor,),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}