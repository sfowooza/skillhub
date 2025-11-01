// Removed Appwrite import for simplified app
// import package:appwrite/models.dart - using stubs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/pages/Auth_screens/edit_skill_page.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';

class ManageSkills extends StatefulWidget {
  const ManageSkills({super.key});

  @override
  State createState() => _ManageSkillsState();
}

class _ManageSkillsState extends State<ManageSkills> {
  List userCreatedSkills = [];
  bool isLoading = true;
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

  Future<void> refresh() async {
    try {
      print('🔄 Refreshing manage skills...');
      final authAPI = Provider.of<AuthAPI>(context, listen: false);
      print('👤 User ID: ${authAPI.userid}');
      print('🔐 Auth status: ${authAPI.status}');
      
      final skills = await database.manageSkills();
      print('📋 Retrieved ${skills.length} skills');
      
      if (mounted) {
        setState(() {
          userCreatedSkills = skills;
          isLoading = false;
        });
        print('✅ State updated with ${userCreatedSkills.length} skills');
      }
    } catch (e) {
      print('❌ Error loading skills: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading skills: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: BaseColors().customTheme.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.work, color: Colors.white),
            SizedBox(width: 8),
            Text("My Skills", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: BaseColors().customTheme.primaryColor),
                SizedBox(height: 16),
                Text('Loading your skills...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          )
        : userCreatedSkills.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.work_off, size: 64, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No Skills Yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Create your first skill to showcase your services',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Stats Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [BaseColors().customTheme.primaryColor, BaseColors().kLightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${userCreatedSkills.length}',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Active Skill${userCreatedSkills.length != 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.stars, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                // Skills List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: userCreatedSkills.length,
                    itemBuilder: (context, index) {
                      final skillData = userCreatedSkills[index] as Map<String, dynamic>;
                      
                      // Safely access data with null checks
                      final skillId = skillData['\$id'] as String? ?? '';
                      final firstName = skillData["firstName"] as String? ?? '';
                      final lastName = skillData["lastName"] as String? ?? '';
                      final text = skillData["text"] as String? ?? 'Untitled';
                      final participants = (skillData["participants"] as List?)?.length ?? 0;
                      final image = skillData["image"] as String? ?? '';
                      final description = skillData["description"] as String? ?? '';
                      final location = skillData["location"] as String? ?? '';
                      final gmaplocation = skillData["gmap_location"] as String? ?? '';
                      final link = skillData["link"] as String? ?? '';
                      final datetime = skillData["datetime"] as String? ?? '';
                      final inSoleBusiness = skillData["inSoleBusiness"] as bool? ?? false;
                      final email = skillData["email"] as String? ?? '';
                      final phoneNumber = skillData["phoneNumber"] as String? ?? '';
                      final selectedCategory = skillData["selectedCategory"] as String? ?? '';
                      final selectedSubcategory = skillData["selectedSubcategory"] as String? ?? '';
                      final likesCount = skillData["likesCount"] ?? 0;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SkillDetails(data: skillData),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Row(
                                  children: [
                                    // Image thumbnail
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [BaseColors().customTheme.primaryColor.withOpacity(0.7), BaseColors().kLightGreen.withOpacity(0.7)],
                                        ),
                                      ),
                                      child: image.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                '${Constants.endpoint}/storage/buckets/${Constants.bucketId}/files/$image/view?project=${Constants.projectId}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(Icons.work, color: Colors.white, size: 28),
                                              ),
                                            )
                                          : Icon(Icons.work, color: Colors.white, size: 28),
                                    ),
                                    SizedBox(width: 16),
                                    // Title and description
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            text.isNotEmpty ? text : '$firstName $lastName',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            description.isNotEmpty ? description : "No description",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Divider(height: 1),
                                SizedBox(height: 12),
                                // Stats and Actions Row
                                Row(
                                  children: [
                                    // Location
                                    if (location.isNotEmpty) ...[
                                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    // Likes
                                    Icon(Icons.favorite, size: 16, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text('$likesCount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    SizedBox(width: 16),
                                    Spacer(),
                                    // Action Buttons
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue, size: 22),
                                        tooltip: 'Edit',
                                        padding: EdgeInsets.all(8),
                                        constraints: BoxConstraints(),
                                        onPressed: () async {
                                          try {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditSkillsPage(
                                                  image: image,
                                                  firstName: firstName,
                                                  description: description,
                                                  location: location,
                                                  gmaplocation: gmaplocation,
                                                  link: link,
                                                  datetime: datetime,
                                                  inSoleBusiness: inSoleBusiness,
                                                  docID: skillId,
                                                  lastName: lastName,
                                                  message: text,
                                                  email: email,
                                                  phoneNumber: phoneNumber,
                                                  selectedCategory: selectedCategory,
                                                  selectedSubcategory: selectedSubcategory,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              refresh();
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error editing skill: ${e.toString()}')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Delete Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red, size: 22),
                                        tooltip: 'Delete',
                                        padding: EdgeInsets.all(8),
                                        constraints: BoxConstraints(),
                                        onPressed: () async {
                                          // Show confirmation dialog
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              title: Row(
                                                children: [
                                                  Icon(Icons.warning, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text('Delete Skill'),
                                                ],
                                              ),
                                              content: Text('Are you sure you want to delete this skill? This action cannot be undone.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            try {
                                              await database.deleteSkill(skillId);
                                              if (mounted) {
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
                                                  ),
                                                );
                                                refresh();
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
