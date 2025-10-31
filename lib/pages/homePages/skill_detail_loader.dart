import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:skillhub/colors.dart';

class SkillDetailLoader extends StatefulWidget {
  final String skillId;

  const SkillDetailLoader({Key? key, required this.skillId}) : super(key: key);

  @override
  State<SkillDetailLoader> createState() => _SkillDetailLoaderState();
}

class _SkillDetailLoaderState extends State<SkillDetailLoader> {
  bool isLoading = true;
  Map<String, dynamic>? skillData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSkillData();
  }

  Future<void> _loadSkillData() async {
    try {
      final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);
      
      // Fetch skill by ID
      final skill = await databaseAPI.getSkillById(widget.skillId);
      
      if (mounted) {
        setState(() {
          skillData = skill;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading skill: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load skill details';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading skill details...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null || skillData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                errorMessage ?? 'Skill not found',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return SkillDetails(data: skillData!);
  }
}
