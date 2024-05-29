import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/events_container.dart';
import 'package:skillhub/controllers/popular_item.dart';
import 'package:skillhub/pages/Auth_screens/profile_page.dart';
import 'package:skillhub/pages/Staggered/addSkillPage.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';

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
  database.getAllSkills().then((value) => setState(() {
    skills = value;
    isLoading = false;
  }));
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
    return 
    Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi $userName \u{1F44B}\u{FE0F}",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Explore Services & Products Around You",
                style: TextStyle(
                  color: BaseColors().baseTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
                isLoading
                      ? const SizedBox()
                      : CarouselSlider(
  options: CarouselOptions(
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 5),
    aspectRatio: 16 / 9,
    viewportFraction: 0.99,
    enlargeCenterPage: true,
    scrollDirection: Axis.horizontal,
  ),
  items: skills.map((skill) {
    return EventContainer(
      data: skill,
    );
  }).toList(),
),

                  const SizedBox(height: 16),
                  Text(
                    "Popular Skills ",
                    style: TextStyle(
                      color: BaseColors().customTheme.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ],
          ),
        ),
      ),
        SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Color.fromARGB(255, 25, 44, 53),
                  child: isLoading
                      ? const SizedBox()
                      : Column(
                          children: [
                            for (int i = 0; i < skills.length && i < 5; i++) ...[
                              PopularItem(
                                eventData: skills[i],
                                index: i + 1,
                              ),
                              const Divider(),
                            ],
                          ],
                        ),
                ),
              )
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 2, top: 8, left: 6, right: 6),
              child: Text(
                "All Skills",
                style: TextStyle(
                  color: BaseColors().customTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
  floatingActionButton: ExpandableFab(),
  // floatingActionButton: Column(
  //   mainAxisSize: MainAxisSize.min,
  //   children: [
  //     FloatingActionButton(
  //       heroTag: 'addSkill', // Unique Hero tag
  //       onPressed: () async {
  //         await Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => AddSkillPage()),
  //         );
  //         setState(() {
  //           refresh();
  //         });
  //       },
  //       child: Icon(
  //         Icons.add,
  //         color: Colors.black,
  //       ),
  //       backgroundColor: Theme.of(context).primaryColor,
  //     ),
  //     SizedBox(height: 16), // Space between FABs
  //     FloatingActionButton(
  //       heroTag: 'profile', // Unique Hero tag
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => Profile(auth: Provider.of<AuthAPI>(context)),
  //           ),
  //         );
  //       },
  //       child: Icon(
  //         Icons.account_circle,
  //         color: Colors.black,
  //       ),
  //       backgroundColor: Theme.of(context).primaryColor,
  //     ),
  //   ],
  // ),
  
);

  }
}