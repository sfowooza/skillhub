import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

class RSVPEvents extends StatefulWidget {
  const RSVPEvents({super.key});

  @override
  State<RSVPEvents> createState() => _RSVPEventsState();
}

class _RSVPEventsState extends State<RSVPEvents> {
  List<Document> skills = [];
  List<Document> userSkills = [];
  bool isLoading = true;
  late Client client;
  late DatabaseAPI database;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeDatabase();
      refresh();
    });
  }

  void initializeDatabase() {
    database = DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false));
  }

  void refresh() {
    String userId = SavedData.getUserId();
    database.getAllSkills().then((value) {
      setState(() {
        skills = value;
        for (var skill in skills) {
          List<dynamic> participants = skill.data["participants"];
          if (participants.contains(userId)) {
            userSkills.add(skill);
          }
        }
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("RSVP Events")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userSkills.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SkillDetails(data: userSkills[index]))),
                  title: Text(
                    userSkills[index].data["firstName"],
                    style: TextStyle(color: BaseColors().baseTextColor),
                  ),
                  subtitle: Text(
                    userSkills[index].data["location"],
                    style: TextStyle(color: BaseColors().baseTextColor),
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: BaseColors().baseTextColor,
                  ),
                ),
              ),
            ),
    );
  }
}
