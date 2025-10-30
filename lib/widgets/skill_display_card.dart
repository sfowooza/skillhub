import 'package:flutter/material.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/constants/constants.dart';

class SkillDisplayCard extends StatelessWidget {
  final Map<String, dynamic> skillData;

  const SkillDisplayCard({Key? key, required this.skillData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 218, 255, 123),
                    blurRadius: 0,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWithOverlay(),
              ),
            ),

            // Title at bottom
            Positioned(
              bottom: 70,
              left: 16,
              right: 16,
              child: Text(
                skillData['text'] ?? 'No Title',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Date and Time info
            Positioned(
              bottom: 45,
              left: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(skillData['datetime']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(skillData['datetime']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Location info
            Positioned(
              bottom: 20,
              left: 16,
              right: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      skillData['location'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons overlay
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (skillData['link'] != null && skillData['link'].toString().isNotEmpty)
                    _buildActionButton(
                      icon: Icons.message,
                      onPressed: () => _launchWhatsApp(skillData['link']),
                      color: const Color(0xFF25D366),
                    ),
                  if (skillData['link'] != null && skillData['link'].toString().isNotEmpty)
                    const SizedBox(width: 8),
                  if (skillData['phoneNumber'] != null && skillData['phoneNumber'].toString().isNotEmpty)
                    _buildActionButton(
                      icon: Icons.call,
                      onPressed: () => _launchPhone(skillData['phoneNumber']),
                      color: Colors.green,
                    ),
                  if (skillData['phoneNumber'] != null && skillData['phoneNumber'].toString().isNotEmpty)
                    const SizedBox(width: 8),
                  if (skillData['gmap_location'] != null && skillData['gmap_location'].toString().isNotEmpty)
                    _buildActionButton(
                      icon: Icons.location_on,
                      onPressed: () => _launchMaps(skillData['gmap_location']),
                      color: Colors.red,
                    ),
                ],
              ),
            ),

            // Category chip
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  skillData['selectedSubcategory'] ?? skillData['selectedCategory'] ?? 'Service',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    final hasImage = skillData['image'] != null && skillData['image'].toString().isNotEmpty;

    if (!hasImage) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
      );
    }

    // Use Appwrite Storage URL with proper image ID from skill data
    final imageId = skillData['image'].toString();
    final imageUrl = '${Constants.endpoint}/storage/buckets/${Constants.bucketId}/files/$imageId/view?project=${Constants.projectId}';

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.35),
        BlendMode.darken,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          print('Image URL: $imageUrl');
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return formatDate(dateTime);
    } catch (e) {
      return dateTime;
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return formatTime(dateTime);
    } catch (e) {
      return dateTime;
    }
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillDetails(data: skillData),
      ),
    );
  }

  void _launchWhatsApp(String? link) async {
    if (link != null && link.isNotEmpty) {
      if (await canLaunch(link)) {
        await launch(link);
      }
    }
  }

  void _launchPhone(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  void _launchMaps(String? location) async {
    if (location != null && location.isNotEmpty) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }
}
