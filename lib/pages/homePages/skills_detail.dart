// import package:appwrite/models.dart - using stubs
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/pages/Auth_screens/edit_skill_page.dart';
import 'package:skillhub/pages/gmap/view_location.dart';
import 'package:skillhub/pages/gmap/view_whatsapp_link.dart';
import 'package:skillhub/utils/category_mappers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:skillhub/utils/category_mappers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ModernInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final Color? accentColor;

  const ModernInfoTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: accentColor ?? BaseColors().customTheme.primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class SkillDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const SkillDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<SkillDetails> createState() => _SkillDetailsState();
}

class _SkillDetailsState extends State<SkillDetails> with SingleTickerProviderStateMixin {
  bool isRSVPedEvent = false;
  String id = "";
  // Removed DatabaseAPI reference for simplified app
  double userRating = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isAvailable = true; // For live availability toggle
  double estimatedPrice = 0.0; // For dynamic pricing calculator

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        id = "test_user_id";
        isRSVPedEvent = isUserPresent(widget.data["participants"] as List<dynamic>? ?? [], id);
        userRating = (widget.data["averageRating"] as num?)?.toDouble() ?? 0;
        isAvailable = widget.data['isAvailable'] ?? true;
      });
    });
  }

  void initializeDatabase() {
    // Simplified initialization for standalone app
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
    // TODO: Update rating in database
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = true; // Simplified for standalone app

    final String firstName = widget.data["firstName"] as String? ?? "Unknown";
    final String description = widget.data["description"] as String? ?? "No description available";
    final String imageUrl = "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260";
    final String datetime = widget.data["datetime"] as String? ?? DateTime.now().toIso8601String();
    final String location = widget.data["location"] as String? ?? "Unknown location";
    final List<dynamic> participants = widget.data["participants"] as List<dynamic>? ?? [];
    final bool isInPerson = widget.data["isInPerson"] as bool? ?? false;
    final String selectedCategory = widget.data["selectedCategory"] as String? ?? "Uncategorized";

    return Scaffold(
      floatingActionButton: isAuthenticated
          ? Padding(
              padding: EdgeInsets.only(left: 30), // Moves FAB to the left with some padding
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () {
                    // Simplified action button
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: FadeTransition(
                          opacity: _animation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(formatDate(datetime)),
                                    avatar: Icon(Icons.calendar_today, size: 16, color: Colors.white),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                  SizedBox(width: 8),
                                  Chip(
                                    label: Text(formatTime(datetime)),
                                    avatar: Icon(Icons.access_time, size: 16, color: Colors.white),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                      // Contact Info Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: BaseColors().customTheme.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(firstName, style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _launchUrl('tel:${widget.data["phoneNumber"] ?? "1234567890"}');
                                    },
                                    icon: Icon(Icons.phone, size: 18),
                                    label: Text("Call Now"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: BaseColors().customTheme.primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 24),
                              Text(
                                "About",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: BaseColors().customTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up, color: BaseColors().customTheme.primaryColor),
                                      SizedBox(width: 8),
                                      Text("${participants.length} likes",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share, color: BaseColors().customTheme.primaryColor),
                                    onPressed: () async {
                                      final shareLink = 'https://skillhub.avodahsystems.com/skillhub/skill/${widget.data["id"] ?? "sample"}';
                                      await Share.share('Check out this skill: $firstName\n$shareLink');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Service Details Card
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service Details",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: BaseColors().customTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Key Features
                              if (widget.data['keyFeatures'] != null)
                                ExpansionTile(
                                  leading: Icon(Icons.star, color: Colors.yellow[700]),
                                  title: Text("Key Features", style: TextStyle(fontWeight: FontWeight.bold)),
                                  children: List<String>.from(widget.data['keyFeatures'])
                                      .map((feature) => ListTile(
                                            leading: Icon(Icons.check_circle, color: Colors.green),
                                            title: Text(feature),
                                          ))
                                      .toList(),
                                ),

                              // Service Hours
                              ModernInfoTile(
                                icon: Icons.access_time,
                                title: "Service Hours",
                                value: widget.data['serviceHours'] ?? 'Available 24/7',
                                accentColor: Colors.blue,
                              ),

                              // Experience Level with Progress Indicator
                              ListTile(
                                leading: CircularPercentIndicator(
                                  radius: 20.0,
                                  lineWidth: 4.0,
                                  percent: (widget.data['experienceYears'] ?? 0) / 20, // Assuming max 20 years
                                  center: Text(
                                    "${widget.data['experienceYears'] ?? 0}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  progressColor: Colors.amber,
                                ),
                                title: Text("Experience"),
                                subtitle: Text("${widget.data['experienceYears'] ?? 'Not specified'} years"),
                                trailing: Chip(
                                  label: Text(widget.data['certification'] ?? 'Professional'),
                                  backgroundColor: Colors.blue[100],
                                ),
                              ),

                              // Pricing with Dynamic Calculator
                              ListTile(
                                leading: Icon(Icons.attach_money, color: Colors.green),
                                title: Text("Pricing"),
                                subtitle: Row(
                                  children: [
                                    Text("Estimate: \$$estimatedPrice"),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Estimate Your Cost"),
                                            content: TextField(
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(labelText: "Enter hours"),
                                              onChanged: (value) {
                                                setState(() {
                                                  estimatedPrice = (double.tryParse(value) ?? 0) *
                                                      (widget.data['hourlyRate'] ?? 50);
                                                });
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text("Done"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Text("Calculate"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                  ],
                                ),
                              ),

                              // Mini Interactive Map
                              Container(
                                height: 200,
                                margin: EdgeInsets.symmetric(vertical: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(37.7749, -122.4194), // Replace with actual lat/lng
                                      zoom: 12,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId('location'),
                                        position: LatLng(37.7749, -122.4194), // Replace with actual lat/lng
                                      ),
                                    },
                                  ),
                                ),
                              ),

                              // Live Availability Toggle
                              ListTile(
                                leading: Icon(Icons.event_available, color: Colors.teal),
                                title: Text("Availability"),
                                trailing: Switch(
                                  value: isAvailable,
                                  onChanged: (value) {
                                    setState(() {
                                      isAvailable = value;
                                    });
                                    // TODO: Update availability in database
                                  },
                                  activeColor: Colors.green,
                                ),
                                subtitle: Text(isAvailable ? "Available Now" : "Currently Busy"),
                              ),

                              // Social Proof Carousel
                              if (widget.data['portfolioImages'] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Past Work",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: BaseColors().customTheme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    CarouselSlider(
                                      options: CarouselOptions(
                                        height: 150,
                                        autoPlay: true,
                                        enlargeCenterPage: true,
                                      ),
                                      items: List<String>.from(widget.data['portfolioImages'])
                                          .map((image) => ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(image, fit: BoxFit.cover),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),

                              // Rating Section
                              SizedBox(height: 16),
                              Text(
                                "Rate this Skill",
                                style: TextStyle(
                                  fontSize: 20,
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
                                itemPadding: EdgeInsets.symmetric(horizontal: 4),
                                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                                onRatingUpdate: _updateRating,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Current Rating: ${(userRating * 10).toStringAsFixed(0)} likes",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Quick Action Buttons (Bottom-Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "call",
                  onPressed: () => _launchUrl('tel:${widget.data["phoneNumber"] ?? "1234567890"}'),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.phone),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "chat",
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewWhatsappLink())),
                  backgroundColor: Color(0xFF25D366),
                  child: Icon(Icons.chat),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "book",
                  onPressed: () {
                    // TODO: Implement booking logic
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Coming Soon!")));
                  },
                  backgroundColor: BaseColors().customTheme.primaryColor,
                  child: Icon(Icons.book),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}