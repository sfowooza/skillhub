import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';

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
    return Scaffold(
      floatingActionButton: ExpandableFab(),
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
                  "https://coffee.avodahsystems.com/v1/storage/buckets/664baa5800325ff306fb/files/${widget.data.data["image"]}/view?project=6648f3ff003ca1aedbec",
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
                ],
              ),
            )
          ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                  Icon(Icons.share)
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
                      color: BaseColors().customTheme.primaryColor,)
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Skill Type : ${widget.data.data["isInPerson"] == true ? "In Person" : "Virtual"}",
                  style: TextStyle(color: BaseColors().baseTextColor,),
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
                ElevatedButton.icon(
                    onPressed: () {
                      _launchUrl(
                          "https://www.google.com/maps/search/?api=1&query=${widget.data.data["location"]}");
                    },
                    icon: const Icon(Icons.map),
                    label: const Text("Open in Google Maps")),
                SizedBox(
                  height: 8,
                ),
                isRSVPedEvent
                    ? SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MaterialButton(
                          color: BaseColors().baseTextColor,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("You are attending this event.")));
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
                                    SnackBar(
                                        content: Text(
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
