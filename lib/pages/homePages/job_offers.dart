import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/events_container.dart';
import 'package:skillhub/pages/Staggered/addSkillPage.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

class JobOffersPage extends StatefulWidget {
    const JobOffersPage({super.key, required String title});
  @override
  State<JobOffersPage> createState() => _JobOffersPageState();
}

class _JobOffersPageState extends State<JobOffersPage> {
  late Client client;
  late AuthAPI auth;
  late DatabaseAPI database;

  String userName = "User";
  List<Document> skills = [];
  bool isLoading = true;

 
@override
void initState() {
  super.initState();
   client = Client();
    auth = AuthAPI(client: client);
    database = DatabaseAPI(auth: auth);
  userName = SavedData.getUserName().split(" ")[0];
  refresh();
  // database.getAllSkills().then((value) => setState(() {
  //   skills = value;
  //   isLoading = false;
  // }));
}
  void refresh() {
    database.getAllSkills().then((value) {
      skills = value;
      isLoading = false;
      setState(() {});
    });
    // getPastEvents().then((value) {
    //   events = value;
    //   isLoading = false;
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers:[SliverToBoxAdapter( child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children:[
               Text(
                        "Hi $userName \u{1F44B}\u{FE0F}",
                        style:  TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Expore Services & Products Around You",
                        style: TextStyle(
                          color: BaseColors().baseTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
          ]),
        ),
        ),
         SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => EventContainer(data: skills[index]),
              childCount: skills.length,
            ),
          ),
        ],
       
      ),
        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSkillPage()),
          );
          setState(() {
            refresh();
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),

    );
  }
}