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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:skillhub/utils/category_mappers.dart';

class SkillDetails extends StatefulWidget {
  final Document data;

  const SkillDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<SkillDetails> createState() => _SkillDetailsState();
}

class _SkillDetailsState extends State<SkillDetails> {
  bool isRSVPedEvent = false;
  String id = "";
  late DatabaseAPI database;
  bool isHovering = false;
  double userRating = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeDatabase();
      setState(() {
        id = SavedData.getUserId();
        isRSVPedEvent = isUserPresent(widget.data.data["participants"] as List<dynamic>? ?? [], id);
        userRating = (widget.data.data["averageRating"] as num?)?.toDouble() ?? 0;
      });
    });
  }

  void initializeDatabase() {
    database = DatabaseAPI(auth: Provider.of<AuthAPI>(context, listen: false));
  }

  bool isUserPresent(List<dynamic> participants, String userId) {
    return participants.contains(userId);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _updateRating(double rating) {
    setState(() {
      userRating = rating;
    });
    // TODO: Implement rating update in the database
    // database.updateRating(widget.data.$id, rating);
  }

  String formatDate(String? dateTimeString) {
    if (dateTimeString == null) return "Unknown date";
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }

  String formatTime(String? dateTimeString) {
    if (dateTimeString == null) return "Unknown time";
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return "Invalid time";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Provider.of<AuthAPI>(context).status == AuthStatus.authenticated;

    // Provide default values or null checks for data
    final String firstName = widget.data.data["firstName"] as String? ?? "Unknown";
    final String description = widget.data.data["description"] as String? ?? "No description available";
    final String imageUrl = widget.data.data["image"] != null
        ? "https://skillhub.avodahsystems.com/v1/storage/buckets/665a5bb500243dbb9967/files/${widget.data.data["image"]}/view?project=665a50350038457d0eb9"
        : "https://placeholder.com/300";
    final String datetime = widget.data.data["datetime"] as String? ?? DateTime.now().toIso8601String();
    final String location = widget.data.data["location"] as String? ?? "Unknown location";
    final List<dynamic> participants = widget.data.data["participants"] as List<dynamic>? ?? [];
    final bool isInPerson = widget.data.data["isInPerson"] as bool? ?? false;
    final String selectedCategory = widget.data.data["selectedCategory"] as String? ?? "Uncategorized";

    return Scaffold(
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.darken),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "${formatDate(datetime)} ${formatTime(datetime)}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              location,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
   Text(
     "First Name",
     style: TextStyle(
       fontSize: 20,
       fontWeight: FontWeight.bold, 
       color: BaseColors().customTheme.primaryColor,
     ),
   ),
   Row(
     children: [
       Icon(Icons.phone, color: BaseColors().customTheme.primaryColor),
       SizedBox(width: 8),
       Text(
         widget.data.data["phoneNumber"] as String? ?? "No phone number",
         style: TextStyle(
           fontSize: 16,
           color: BaseColors().customTheme.primaryColor,
           fontWeight: FontWeight.w500,
         ),
       ),
     ],
   ),
 ],
),
SizedBox(height: 8),
Text(
 description,
 style: TextStyle(
   fontSize: 18,
   color: BaseColors().baseTextColor,
 ),
),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${participants.length} person(s) like this!",
                        style: TextStyle(
                          color: BaseColors().customTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
 IconButton(
  icon: Icon(Icons.share, color: BaseColors().customTheme.primaryColor),
  onPressed: () async {
    final String shareLink = 'https://skillhub.avodahsystems.com/skillhub/skill/${widget.data.$id}';
    final String text = 'Check out this skill on SkillHub: $firstName\n$shareLink';
    
    // Assuming you have an image URL or path for the skill
    final String imageUrl = 'URL_OR_PATH_TO_YOUR_IMAGE'; // Replace with actual URL or path
    
    // Check if the app is running on Android or iOS
    if (Platform.isAndroid || Platform.isIOS) {
      // Share with text
      await Share.share(
        text,
        subject: 'Skill on SkillHub',
      );
      
      // For WhatsApp sharing, since shareToWhatsApp isn't available, we'll use share with package
      // Note: This is a workaround. For direct WhatsApp sharing, you might need to use a different package or check for updates in share_plus
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        await Share.share(
          text,
          subject: 'Skill on SkillHub',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        );
      }
    } else {
      // For other platforms, just share the text
      await Share.share(text);
    }
  },
),
                    ],
                  ),
                  SizedBox(height: 16),
              Text(
  "Rate this skill:",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: BaseColors().customTheme.primaryColor,
  ),
),
SizedBox(height: 8),
RatingBar.builder(
  initialRating: userRating,
  minRating: 1,
  direction: Axis.horizontal,
  allowHalfRating: true,
  itemCount: 5,
  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  itemBuilder: (context, _) => Icon(
    Icons.star,
    color: Colors.amber,
  ),
  onRatingUpdate: _updateRating,
),
Divider(  // Added divider before More Info
  color: Colors.grey.shade300,
  thickness: 1,
  height: 32,
),
Text(
  "More Info",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BaseColors().customTheme.primaryColor,
  ),
),
SizedBox(height: 8),
ListTile(
  leading: Icon(isInPerson ? Icons.person : Icons.computer),
  title: Text(
    "Skill Type: ${isInPerson ? "In Person" : "Virtual"}",
    style: TextStyle(color: BaseColors().baseTextColor),
  ),
),
ListTile(
  leading: Icon(Icons.category),
  title: Text(
    "Category: ${CategoryMapper.toDisplayName(selectedCategory)}",
    style: TextStyle(color: BaseColors().baseTextColor),
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomeCategoryPage()),
    );
  },
),
ListTile(
  leading: Icon(Icons.layers_outlined),
  title: Text(
    "Subcategory: ${SubCategoryMapper.toDisplayName(widget.data.data["selectedSubcategory"] as String? ?? "Not specified")}",
    style: TextStyle(color: BaseColors().baseTextColor),
  ),
),
Divider(  // Added divider after subcategory
  color: Colors.grey.shade300,
  thickness: 1,
  height: 32,
),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton.icon(
      onPressed: () {
        _launchUrl(
            "https://www.google.com/maps/search/?api=1&query=$location");
      },
      icon: Icon(Icons.map),
      label: Text("Open in Maps",style:TextStyle(color:Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: BaseColors().customTheme.primaryColor,
      ),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewLocation(documentId: widget.data.$id)),
        );
      },
      child: Text('View Location',style:TextStyle(color:Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: BaseColors().customTheme.primaryColor,
      ),
    ),
  ],
),
SizedBox(height: 16),
Center(
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewWhatsappLink()),
      );
    },
    icon: Image.asset(
      'assets/logo_skillshub.png',
      width: 24,
      height: 24,
      color: Colors.white,
    ),
    label: Text('View WhatsApp Biz Catalogue'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF25D366),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
),
                  SizedBox(height: 16),
                  if (isAuthenticated)
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRSVPedEvent ? Colors.grey : BaseColors().customTheme.primaryColor,
                        ),
                        onPressed: isRSVPedEvent
                            ? null
                            : () {
                                database.rsvpEvent(participants, widget.data.$id).then((value) {
                                  if (value) {
                                    setState(() {
                                      isRSVPedEvent = true;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text("RSVP Successful!")));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text("Something went wrong. Try Again.")));
                                  }
                                });
                              },
                        child: Text(
                          isRSVPedEvent ? "Attending Event" : "Like this? Click!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}