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

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const InfoTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: BaseColors().customTheme.primaryColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}

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
    fontSize: 28, // Increased size
    fontWeight: FontWeight.bold,
  ),
),
SizedBox(height: 4),
Row(
  children: [
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            formatDate(datetime),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    SizedBox(width: 8),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            formatTime(datetime),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
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
        // First Card - Main Content
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contact Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: BaseColors().customTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          firstName,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: BaseColors().customTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, 
                            color: BaseColors().customTheme.primaryColor,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.data.data["phoneNumber"] as String? ?? "No phone",
                            style: TextStyle(
                              fontSize: 14,
                              color: BaseColors().customTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 24),
                Text(
                  "About",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BaseColors().customTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: BaseColors().baseTextColor,
                  ),
                ),
                Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up,
                          size: 16,
                          color: BaseColors().customTheme.primaryColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${participants.length} likes",
                          style: TextStyle(
                            color: BaseColors().customTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.share),
                      color: BaseColors().customTheme.primaryColor,
                      onPressed: () async {
    final String shareLink = 'https://skillhub.avodahsystems.com/skillhub/skill/${widget.data.$id}';
    final String text = 'Check out this skill on SkillHub: $firstName\n$shareLink';
    
    // Check if the app is running on Android or iOS
    if (Platform.isAndroid || Platform.isIOS) {
      // Share with text
      await Share.share(
        text,
        subject: 'Skill on SkillHub',
      );
      
      // For WhatsApp sharing
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
              ],
            ),
          ),
        ),

// Location Buttons
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

// WhatsApp Button
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
// Rating Card
Card(
  elevation: 0,
  margin: EdgeInsets.symmetric(vertical: 8),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rate this skill",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BaseColors().customTheme.primaryColor,
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: RatingBar.builder(
            initialRating: userRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: _updateRating,
          ),
        ),
      ],
    ),
  ),
),

// More Info Card
Card(
  elevation: 0,
  margin: EdgeInsets.symmetric(vertical: 8),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "More Info",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BaseColors().customTheme.primaryColor,
          ),
        ),
        SizedBox(height: 12),
        InfoTile(
          icon: isInPerson ? Icons.person : Icons.computer,
          title: "Type",
          value: isInPerson ? "In Person" : "Virtual",
        ),
        InfoTile(
          icon: Icons.category,
          title: "Category",
          value: CategoryMapper.toDisplayName(selectedCategory),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomeCategoryPage()),
            );
          },
        ),
        InfoTile(
          icon: Icons.layers_outlined,
          title: "Subcategory",
          value: SubCategoryMapper.toDisplayName(
            widget.data.data["selectedSubcategory"] as String? ?? "Not specified"
          ),
        ),
      ],
    ),
  ),
),


// Like Button
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
        // Your existing code continues here...
        
      ],
    ),
  ),
),
        ],
      ),
    );
  }
}