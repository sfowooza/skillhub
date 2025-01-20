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
  State<ManageSkills> createState() => _ManageSkillsState();
}

class _ManageSkillsState extends State<ManageSkills> {
  List<Document> userCreatedSkills = [];
  bool isLoading = true;
  late Client client;
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
  void refresh() {
    database.manageSkills().then((value) {
      userCreatedSkills = value;
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Skills")),
      body: ListView.builder(
        itemCount: userCreatedSkills.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SkillDetails(data: userCreatedSkills[index]))),
            title: Text(
              userCreatedSkills[index].data["firstName"],
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Text(
              "${userCreatedSkills[index].data["participants"].length} Potential Client(s)",
              style: TextStyle(color: BaseColors().baseTextColor,),
            ),
            trailing: IconButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditSkillsPage(
                              image: userCreatedSkills[index].data["image"],
                              firstName: userCreatedSkills[index].data["firstName"],
                              description:
                                  userCreatedSkills[index].data["description"],
                              location: userCreatedSkills[index].data["location"],
                                 gmaplocation: userCreatedSkills[index].data["gmaplocation"],
                                    link: userCreatedSkills[index].data["link"],
                              datetime:
                                  userCreatedSkills[index].data["datetime"],
                              inSoleBusiness:
                                  userCreatedSkills[index].data["inSoleBusiness"],
                              docID: userCreatedSkills[index].$id, 
                              lastName: userCreatedSkills[index].data["lastName"],
                              message: userCreatedSkills[index].data["text"],
                              email: userCreatedSkills[index].data["email"],
                              phoneNumber: userCreatedSkills[index].data["phoneNumber"],
                              selectedCategory: userCreatedSkills[index].data["selectedCategory"],
                              selectedSubcategory: userCreatedSkills[index].data["selectedSubcategory"],
                            
                            )));
                refresh();
              },
              icon: Icon(
                Icons.edit,
                color: BaseColors().baseTextColor,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}