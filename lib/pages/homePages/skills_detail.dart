import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/pages/Staggered/category_staggered_page.dart';
import 'package:skillhub/pages/gmap/view_location.dart';
import 'package:skillhub/pages/gmap/view_whatsapp_link.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:star_rating/star_rating.dart';
import 'package:share_plus/share_plus.dart';

class SkillDetails extends StatefulWidget {
  final Document data;

  const SkillDetails({super.key, required this.data});

  @override
  State<SkillDetails> createState() => _SkillDetailsState();
}

class _SkillDetailsState extends State<SkillDetails> {
  bool isRSVPedEvent = false;
  String id = "";

  late DatabaseAPI database;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeDatabase();
      setState(() {
        id = SavedData.getUserId();
        isRSVPedEvent = isUserPresent(widget.data.data["participants"], id);
      });
    });
  }

  void initializeDatabase() {
    database = DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false));
  }

  bool isUserPresent(List<dynamic> participants, String userId) {
    return participants.contains(userId);
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Provider.of<AuthAPI>(context).status == AuthStatus.authenticated;

    return Scaffold(
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            Container(
              color: Colors.purple,
              height: 300,
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.darken),
                child: Image.network(
                  "https://skillhub.avodahsystems.com/v1/storage/buckets/665a5bb500243dbb9967/files/${widget.data.data["image"]}/view?project=665a50350038457d0eb9",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                top: 25,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Colors.white,
                    ))),
            Positioned(
              bottom: 45,
              left: 8,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${formatDate(widget.data.data["datetime"])}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${formatTime(widget.data.data["datetime"])}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 8,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "${widget.data.data["location"]}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.work_outlined,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (event) {
                      setState(() {
                        isHovering = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        isHovering = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomeCategoryPage()),
                        );
                      },
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Text(
                            "Category: ${widget.data.data["selectedCategory"]}",
                            style: TextStyle(
                              color:
                                  isHovering ? Colors.purple : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: isHovering
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
              left: 8.0,
              right: 16.0, // Change this value to the desired right padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      widget.data.data["firstName"],
                      style: TextStyle(
                          color: BaseColors().customTheme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
             InkWell(
          onTap: () async {
            final String firstName = widget.data.data['firstName'];
            final String shareLink = 'https://skillhub.avodahsystems.com/skillhub?user=$firstName'; // Replace with your actual link generation logic

            final String text =
                'Check out this skill on SkillHub: $firstName\n$shareLink';
            await Share.share(text);
          },
          child: Icon(Icons.share),
        ),
                ]),
                SizedBox(
                  height: 8,
                ),
                Text(widget.data.data["description"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: BaseColors().baseTextColor,
                    )),
                SizedBox(height: 8),
                Text(
                  "${widget.data.data["participants"].length} person(s) like this!.",
                  style: TextStyle(
                      color: BaseColors().customTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "More Info ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BaseColors().customTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Skill Type : ${widget.data.data["isInPerson"] == true ? "In Person" : "Virtual"}",
                  style: TextStyle(
                    color: BaseColors().baseTextColor,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Time : ${formatTime(widget.data.data["datetime"])}",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Location : ${widget.data.data["location"]}",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    StarRating(
                      rating: 3,
                      color: Colors.orange,
                    ),
                    Text("Ratings"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _launchUrl(
                            "https://www.google.com/maps/search/?api=1&query=${widget.data.data["location"]}");
                      },
                      icon: const Icon(Icons.map, color: Colors.purple),
                      label: const Text("Open Place Name",
                          style: TextStyle(color: Colors.purple)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1, color: Colors.purple),
                        foregroundColor: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewLocation(
                                  documentId: widget.data.$id)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1, color: Colors.purple),
                        foregroundColor: Colors.purple,
                      ),
                      child: Text('View Location'),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                   Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewWhatsappLink()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          width: 1, color: Color(0xFF25D366)), // WhatsApp green color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: Image.asset(
                      'assets/logo_skillshub.png', // Replace with the path to your WhatsApp icon
                      width: 24,
                      height: 24,
                      color: Colors.green,
                    ),
                    label: Text(
                      'View WhatsApp Biz Catalogue',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                if (isAuthenticated)
                  isRSVPedEvent
                      ? SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: MaterialButton(
                            color: BaseColors().baseTextColor,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "You are attending this event.")));
                            },
                            child: Text(
                              "Attending Event",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: MaterialButton(
                            color: BaseColors().baseTextColor,
                            onPressed: () {
                              database
                                  .rsvpEvent(
                                      widget.data.data["participants"],
                                      widget.data.$id)
                                  .then((value) {
                                if (value) {
                                  setState(() {
                                    isRSVPedEvent = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("RSVP Successful !!!")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(
                                          "Something went wrong. Try Again.")));
                                }
                              });
                            },
                            child: Text(
                              "Liking this? Click",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20),
                            ),
                          ),
                        )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}