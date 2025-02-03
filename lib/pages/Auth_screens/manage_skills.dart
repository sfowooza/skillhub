import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/Auth_screens/edit_skill_page.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

class ManageSkills extends StatefulWidget {
  const ManageSkills({super.key});

  @override
  State createState() => _ManageSkillsState();
}

class _ManageSkillsState extends State<ManageSkills> {
  List userCreatedSkills = [];
  bool isLoading = true;
  late DatabaseAPI database;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  void initializeDatabase() {
    database = DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false));
    refresh();
  }

  Future<void> refresh() async {
    try {
      final skills = await database.manageSkills();
      setState(() {
        userCreatedSkills = skills;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading skills: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Skills"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : userCreatedSkills.isEmpty
          ? const Center(child: Text('No skills found'))
          : ListView.builder(
              itemCount: userCreatedSkills.length,
              itemBuilder: (context, index) {
                final skill = userCreatedSkills[index];
                final skillData = skill.data;
                
                // Safely access data with null checks
                final firstName = skillData["firstName"] as String? ?? '';
                final participants = (skillData["participants"] as List?)?.length ?? 0;
                final image = skillData["image"] as String? ?? '';
                final description = skillData["description"] as String? ?? '';
                final location = skillData["location"] as String? ?? '';
                final gmaplocation = skillData["gmaplocation"] as String? ?? '';
                final link = skillData["link"] as String? ?? '';
                final datetime = skillData["datetime"] as String? ?? '';
                final inSoleBusiness = skillData["inSoleBusiness"] as bool? ?? false;
                final lastName = skillData["lastName"] as String? ?? '';
                final text = skillData["text"] as String? ?? '';
                final email = skillData["email"] as String? ?? '';
                final phoneNumber = skillData["phoneNumber"] as String? ?? '';
                final selectedCategory = skillData["selectedCategory"] as String? ?? '';
                final selectedSubcategory = skillData["selectedSubcategory"] as String? ?? '';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkillDetails(data: skill),
                      ),
                    ),
                    title: Text(
                      firstName,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$participants Potential Client(s)",
                      style: TextStyle(
                        color: BaseColors().baseTextColor,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            try {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditSkillsPage(
                                    image: image,
                                    firstName: firstName,
                                    description: description,
                                    location: location,
                                    gmaplocation: gmaplocation,
                                    link: link,
                                    datetime: datetime,
                                    inSoleBusiness: inSoleBusiness,
                                    docID: skill.$id,
                                    lastName: lastName,
                                    message: text,
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    selectedCategory: selectedCategory,
                                    selectedSubcategory: selectedSubcategory,
                                  ),
                                ),
                              );
                              if (result == true) {
                                refresh();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error editing skill: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.edit,
                            color: BaseColors().baseTextColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}