// import package:appwrite/models.dart - using stubs
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/pages/Auth_screens/edit_skill_page.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/gmap/view_location.dart';
import 'package:skillhub/pages/gmap/view_whatsapp_link.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/utils/category_mappers.dart';
import 'package:skillhub/appwrite/likes_api.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:provider/provider.dart';
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
  
  // Likes functionality
  bool isLiked = false;
  int likesCount = 0;
  bool isLoadingLike = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        id = "test_user_id";
        isRSVPedEvent = isUserPresent(widget.data["participants"] as List<dynamic>? ?? [], id);
        userRating = (widget.data["averageRating"] as num?)?.toDouble() ?? 0;
        isAvailable = widget.data['isAvailable'] ?? true;
        likesCount = (widget.data['likesCount'] as num?)?.toInt() ?? 0;
      });
      
      // Load likes data
      await _loadLikesData();
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

  int calculateExperience(String? startDate) {
    if (startDate == null || startDate.isEmpty) return 0;
    try {
      final start = DateTime.parse(startDate);
      final now = DateTime.now();
      final difference = now.difference(start);
      return (difference.inDays / 365).floor();
    } catch (e) {
      print('Error calculating experience: $e');
      return 0;
    }
  }

  Future<void> _loadLikesData() async {
    try {
      final likesAPI = context.read<LikesAPI>();
      final skillId = widget.data['\$id'] ?? '';
      
      if (skillId.isNotEmpty) {
        final liked = await likesAPI.hasLikedSkill(skillId);
        final count = await likesAPI.getLikesCount(skillId);
        
        if (mounted) {
          setState(() {
            isLiked = liked;
            likesCount = count;
          });
        }
      }
    } catch (e) {
      print('Error loading likes data: $e');
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BaseColors().customTheme.primaryColor.withOpacity(0.95),
                  BaseColors().kLightGreen.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, size: 48, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Show Your Love!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Create an account or sign in to like skills and show support to amazing providers!',
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: BaseColors().customTheme.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add, size: 20),
                              SizedBox(width: 8),
                              Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 20),
                              SizedBox(width: 8),
                              Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Maybe Later', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLike() async {
    final authAPI = context.read<AuthAPI>();
    if (authAPI.status != AuthStatus.authenticated) {
      _showAuthDialog();
      return;
    }

    setState(() {
      isLoadingLike = true;
    });

    try {
      final likesAPI = context.read<LikesAPI>();
      final skillId = widget.data['\$id'] ?? '';
      
      if (skillId.isNotEmpty) {
        // Toggle the like
        final newLikeStatus = await likesAPI.toggleLike(skillId);
        
        // Reload the actual count from database to ensure accuracy
        final actualCount = await likesAPI.getLikesCount(skillId);
        
        if (mounted) {
          setState(() {
            isLiked = newLikeStatus;
            likesCount = actualCount; // Use actual count from DB
            isLoadingLike = false;
          });
          
          // Update the widget data so it persists
          widget.data['likesCount'] = actualCount;
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      if (mounted) {
        setState(() {
          isLoadingLike = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update like status')),
        );
      }
    }
  }

  List<Widget> _buildBusinessNameWidgets() {
    return [
      Text(
        widget.data["businessName"],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 2),
    ];
  }

  // Format phone number to ensure it has country code
  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return "1234567890";
    
    // If already has country code, return as is
    if (phoneNumber.startsWith('+')) return phoneNumber;
    
    // If doesn't start with +, assume it needs Uganda country code
    // Remove leading 0 if present
    String cleanNumber = phoneNumber;
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }
    
    // Add Uganda country code by default
    return '+256$cleanNumber';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAPI = Provider.of<AuthAPI>(context);
    final isAuthenticated = authAPI.status == AuthStatus.authenticated;

    final String firstName = widget.data["firstName"] as String? ?? "Unknown";
    final String description = widget.data["description"] as String? ?? "No description available";
    
    // Get actual skill image from database
    final String? imageId = widget.data["image"] as String?;
    final String imageUrl = imageId != null && imageId.isNotEmpty
        ? '${Constants.endpoint}/storage/buckets/${Constants.bucketId}/files/$imageId/view?project=${Constants.projectId}'
        : "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260";
    
    final String datetime = widget.data["datetime"] as String? ?? DateTime.now().toIso8601String();
    final String location = widget.data["location"] as String? ?? "Unknown location";
    final List<dynamic> participants = widget.data["participants"] as List<dynamic>? ?? [];
    final bool isInPerson = widget.data["isInPerson"] as bool? ?? false;
    final String selectedCategory = widget.data["selectedCategory"] as String? ?? "Uncategorized";
    final String selectedSubcategory = widget.data["selectedSubcategory"] as String? ?? "";
    final String productOrService = widget.data["productOrService"] as String? ?? "Service";
    final List<dynamic> photos = widget.data["photos"] as List<dynamic>? ?? [];
    
    // Debug: Print photo data
    print('📸 Skill Photos Debug:');
    print('  Photo count: ${photos.length}');
    print('  Photos data: $photos');

    return Scaffold(
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
      floatingActionButtonLocation: isAuthenticated ? FloatingActionButtonLocation.startFloat : null,
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
                              // Name and Business Name on same row
                              Row(
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
                                  if (widget.data["businessName"] != null && widget.data["businessName"].toString().isNotEmpty) ...[
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        widget.data["businessName"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(
                                    label: Text(selectedCategory),
                                    avatar: Icon(Icons.category, size: 16, color: Colors.white),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                  ),
                                  if (selectedSubcategory.isNotEmpty)
                                    Chip(
                                      label: Text(selectedSubcategory),
                                      avatar: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.white),
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                    ),
                                  Chip(
                                    label: Text(productOrService),
                                    avatar: Icon(
                                      productOrService == 'Product' ? Icons.shopping_bag : Icons.work,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    backgroundColor: productOrService == 'Product' 
                                        ? Colors.blue.withOpacity(0.6)
                                        : Colors.green.withOpacity(0.6),
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
                                  Expanded(
                                    child: Column(
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
                                        if (widget.data["businessName"] != null && widget.data["businessName"].toString().isNotEmpty) ..._buildBusinessNameWidgets(),
                                        Text(firstName, style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final formattedPhone = _formatPhoneNumber(widget.data["phoneNumber"]);
                                          _launchUrl('tel:$formattedPhone');
                                        },
                                        icon: Icon(Icons.phone, size: 18, color: BaseColors().customTheme.primaryColor),
                                        label: Text(
                                          "Call",
                                          style: TextStyle(color: BaseColors().customTheme.primaryColor),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: BaseColors().customTheme.primaryColor, width: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final phoneNumber = widget.data["phoneNumber"] ?? '';
                                          if (phoneNumber.isNotEmpty) {
                                            final formattedNumber = _formatPhoneNumber(phoneNumber);
                                            final whatsappUrl = 'https://wa.me/${formattedNumber.replaceAll('+', '')}';
                                            _launchUrl(whatsappUrl);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('No phone number available')),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.phone, size: 18, color: Colors.white),
                                        label: Text(
                                          "WhatsApp",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Color(0xFF25D366),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(height: 24),
                              
                              // Category & Subcategory Info
                              Row(
                                children: [
                                  Icon(Icons.business_center, color: BaseColors().customTheme.primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Category: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    selectedCategory,
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  if (selectedSubcategory.isNotEmpty) ...[
                                    Text(
                                      " • ",
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      selectedSubcategory,
                                      style: TextStyle(fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 12),
                              
                              // Offering Type Info
                              Row(
                                children: [
                                  Icon(
                                    productOrService == 'Product' ? Icons.shopping_bag : Icons.work,
                                    color: BaseColors().customTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Offering: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: productOrService == 'Product' 
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: productOrService == 'Product' 
                                            ? Colors.blue
                                            : Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      productOrService,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: productOrService == 'Product' 
                                            ? Colors.blue[700]
                                            : Colors.green[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              
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
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        child: IconButton(
                                          icon: Icon(
                                            isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: isLiked ? Colors.red : BaseColors().customTheme.primaryColor,
                                            size: 28,
                                          ),
                                          onPressed: isLoadingLike ? null : _toggleLike,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "$likesCount",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: isLiked ? Colors.red : Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        likesCount == 1 ? "like" : "likes",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share, color: BaseColors().customTheme.primaryColor),
                                    onPressed: () async {
                                      final skillId = widget.data["\$id"] ?? widget.data["id"] ?? "unknown";
                                      final shareLink = 'https://skillhub.avodahsystems.com/skill/$skillId';
                                      await Share.share('Check out this skill: $firstName\n$shareLink');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Photo Gallery Card (if photos exist)
                      if (photos.isNotEmpty) ...[
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
                                  "Gallery",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: BaseColors().customTheme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: photos.length,
                                  itemBuilder: (context, index) {
                                    final photoId = photos[index].toString();
                                    final photoUrl = '${Constants.endpoint}/storage/buckets/${Constants.photosBucketId}/files/$photoId/view?project=${Constants.projectId}';
                                    print('🖼️ Loading gallery photo $index: $photoUrl');
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        // Show full screen image on tap
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.black,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Image.network(
                                                    photoUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 16,
                                                  right: 16,
                                                  child: IconButton(
                                                    icon: Icon(Icons.close, color: Colors.white),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!, width: 1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('❌ Error loading gallery photo $index: $error');
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.image_not_supported, color: Colors.grey[600], size: 32),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Image not available',
                                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[100],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Service/Product Details Card
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
                                "$productOrService Details",
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

                              // Business Hours
                              if (widget.data['openingTimes'] != null && widget.data['openingTimes'].toString().isNotEmpty)
                                ModernInfoTile(
                                  icon: Icons.access_time,
                                  title: "Business Hours",
                                  value: widget.data['openingTimes'],
                                  accentColor: Colors.blue,
                                ),

                              // Experience Level with Progress Indicator
                              Builder(
                                builder: (context) {
                                  final experienceYears = calculateExperience(widget.data['businessStartDate']);
                                  return ListTile(
                                    leading: CircularPercentIndicator(
                                      radius: 20.0,
                                      lineWidth: 4.0,
                                      percent: (experienceYears / 20).clamp(0.0, 1.0), // Assuming max 20 years
                                      center: Text(
                                        "$experienceYears",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      progressColor: Colors.amber,
                                    ),
                                    title: Text("Experience", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      experienceYears > 0 
                                        ? "$experienceYears ${experienceYears == 1 ? 'year' : 'years'} in business"
                                        : "New business",
                                    ),
                                    trailing: Chip(
                                      label: Text(
                                        experienceYears >= 5 ? 'Expert' : experienceYears >= 2 ? 'Professional' : 'Starter',
                                      ),
                                      backgroundColor: experienceYears >= 5 ? Colors.green[100] : Colors.blue[100],
                                    ),
                                  );
                                },
                              ),

                              // Pricing
                              if (widget.data['priceRange'] != null && widget.data['priceRange'].toString().isNotEmpty)
                                ModernInfoTile(
                                  icon: Icons.payments,
                                  title: "Price Range",
                                  value: "Ug Shs ${widget.data['priceRange']}",
                                  accentColor: Colors.green,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(Icons.payments, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text("Pricing Details"),
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Price Range:",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Ug Shs ${widget.data['priceRange']}",
                                              style: TextStyle(fontSize: 20, color: Colors.green[700]),
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              "Contact the service provider for:",
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                            ),
                                            SizedBox(height: 8),
                                            Text("• Exact quotes"),
                                            Text("• Custom packages"),
                                            Text("• Bulk discounts"),
                                            Text("• Payment plans"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                              // Location & Navigation Card
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Stack(
                                          children: [
                                            GoogleMap(
                                              initialCameraPosition: CameraPosition(
                                                target: LatLng(
                                                  widget.data['lat'] ?? 0.0,
                                                  widget.data['long'] ?? 0.0,
                                                ),
                                                zoom: 14,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: MarkerId('skill_location'),
                                                  position: LatLng(
                                                    widget.data['lat'] ?? 0.0,
                                                    widget.data['long'] ?? 0.0,
                                                  ),
                                                  infoWindow: InfoWindow(
                                                    title: firstName,
                                                    snippet: location,
                                                  ),
                                                ),
                                              },
                                              zoomControlsEnabled: false,
                                              myLocationButtonEnabled: false,
                                            ),
                                            // Overlay with navigation hint
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.location_on, size: 16, color: Colors.red),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Tap to navigate',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Navigation buttons
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, color: BaseColors().customTheme.primaryColor),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  location,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Get Directions:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final lat = widget.data['lat'] ?? 0.0;
                                                    final lng = widget.data['long'] ?? 0.0;
                                                    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                                                    if (await canLaunchUrl(Uri.parse(url))) {
                                                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Could not open Google Maps')),
                                                      );
                                                    }
                                                  },
                                                  icon: Icon(Icons.directions, size: 18),
                                                  label: Text(
                                                    'Navigate',
                                                    style: TextStyle(fontSize: 13),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final lat = widget.data['lat'] ?? 0.0;
                                                    final lng = widget.data['long'] ?? 0.0;
                                                    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                                    if (await canLaunchUrl(Uri.parse(url))) {
                                                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                    }
                                                  },
                                                  icon: Icon(Icons.map, size: 20),
                                                  label: Text('View Map'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: BaseColors().customTheme.primaryColor,
                                                    side: BorderSide(color: BaseColors().customTheme.primaryColor),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Tap "Navigate" to open Google Maps with turn-by-turn directions to this exact location',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

                              // Negotiation/Discount Info
                              if (widget.data['isNegotiable'] == true) ...[
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange, width: 2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.local_offer, color: Colors.orange, size: 24),
                                          SizedBox(width: 8),
                                          Text(
                                            'Open to Negotiation',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (widget.data['discountConditions'] != null && 
                                          widget.data['discountConditions'].toString().isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Text(
                                          widget.data['discountConditions'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],

                              // Social Links Section
                              if ((widget.data['tiktokUrl'] != null && widget.data['tiktokUrl'].toString().isNotEmpty) ||
                                  (widget.data['websiteUrl'] != null && widget.data['websiteUrl'].toString().isNotEmpty)) ...[
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
                                          'Connect Online',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: BaseColors().customTheme.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        if (widget.data['websiteUrl'] != null && 
                                            widget.data['websiteUrl'].toString().isNotEmpty)
                                          InkWell(
                                            onTap: () {
                                              _launchUrl(widget.data['websiteUrl']);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.blue, width: 1),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.language, color: Colors.blue, size: 28),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Visit Website',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.blue[700],
                                                          ),
                                                        ),
                                                        Text(
                                                          widget.data['websiteUrl'],
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[600],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(Icons.open_in_new, color: Colors.blue),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (widget.data['tiktokUrl'] != null && 
                                            widget.data['tiktokUrl'].toString().isNotEmpty) ...[
                                          SizedBox(height: 12),
                                          InkWell(
                                            onTap: () {
                                              _launchUrl(widget.data['tiktokUrl']);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.black87, width: 1),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.video_library, color: Colors.black87, size: 28),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Follow on TikTok',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        Text(
                                                          widget.data['tiktokUrl'],
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[600],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(Icons.open_in_new, color: Colors.black87),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],

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
                              
                              // Delete Skill Section (only for skill owners)
                              if (isAuthenticated && widget.data['user_id'] == authAPI.userid) ...[
                                SizedBox(height: 32),
                                Divider(),
                                SizedBox(height: 16),
                                Text(
                                  "Manage Skill",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: BaseColors().customTheme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.red.withOpacity(0.05),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.warning, color: Colors.orange, size: 24),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              "Danger Zone",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Deleting this skill will permanently remove it from the platform. This action cannot be undone.",
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      ),
                                      SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            // Show confirmation dialog
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: Row(
                                                  children: [
                                                    Icon(Icons.delete_forever, color: Colors.red, size: 28),
                                                    SizedBox(width: 12),
                                                    Text('Delete Skill?'),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'This will permanently delete:',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text('• Skill listing'),
                                                    Text('• All likes and ratings'),
                                                    Text('• Skill images'),
                                                    Text('• All associated data'),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      'This action cannot be undone!',
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text('Cancel', style: TextStyle(fontSize: 16)),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    ),
                                                    child: Text('Delete Forever', style: TextStyle(fontSize: 16)),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              try {
                                                final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);
                                                final skillId = widget.data['\$id'] ?? '';
                                                
                                                if (skillId.isNotEmpty) {
                                                  await databaseAPI.deleteSkill(skillId);
                                                  
                                                  if (mounted) {
                                                    Navigator.pop(context); // Go back to previous page
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(Icons.check_circle, color: Colors.white),
                                                            SizedBox(width: 8),
                                                            Text('Skill deleted successfully'),
                                                          ],
                                                        ),
                                                        backgroundColor: Colors.green,
                                                        duration: Duration(seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error deleting skill: ${e.toString()}'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.delete_forever, size: 24),
                                          label: Text(
                                            'Delete This Skill',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
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
                  onPressed: () {
                    final formattedPhone = _formatPhoneNumber(widget.data["phoneNumber"]);
                    _launchUrl('tel:$formattedPhone');
                  },
                  backgroundColor: Colors.green,
                  child: Icon(Icons.phone),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "chat",
                  onPressed: () {
                    final phoneNumber = widget.data["phoneNumber"] ?? '';
                    if (phoneNumber.isNotEmpty) {
                      final formattedNumber = _formatPhoneNumber(phoneNumber);
                      final whatsappUrl = 'https://wa.me/${formattedNumber.replaceAll('+', '')}';
                      _launchUrl(whatsappUrl);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No phone number available')),
                      );
                    }
                  },
                  backgroundColor: Color(0xFF25D366),
                  child: Icon(Icons.chat, color: Colors.white),
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