import 'package:flutter/material.dart';
import 'package:skillhub/controllers/events_container.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:skillhub/colors.dart';

class RSVPEvents extends StatefulWidget {
  const RSVPEvents({super.key});

  @override
  State<RSVPEvents> createState() => _RSVPEventsState();
}

class _RSVPEventsState extends State<RSVPEvents> {
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> userSkills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeDatabase();
      refresh();
    });
  }

  void initializeDatabase() {
    // Simplified initialization
  }

  void refresh() {
    // Load sample data
    setState(() {
      userSkills = [
        {
          "firstName": "Sample Skill 1",
          "location": "Sample Location 1",
          "datetime": "2024-01-01T10:00:00",
        },
        {
          "firstName": "Sample Skill 2", 
          "location": "Sample Location 2",
          "datetime": "2024-01-02T14:00:00",
        }
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("RSVP Endorsements")),
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
                    userSkills[index]["firstName"],
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text(
                    userSkills[index]["location"],
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
