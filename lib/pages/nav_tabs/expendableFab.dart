import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/pages/Auth_screens/rsvp_events.dart';
import 'package:skillhub/pages/Auth_screens/manage_skills.dart';
import 'package:skillhub/pages/Auth_screens/account_page.dart';
import 'package:skillhub/pages/Auth_screens/add_skill_page.dart';
import 'package:skillhub/pages/homePages/explore_skills_page.dart';

class ExpandableFab extends StatefulWidget {
  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isExpanded) ...[
              ScaleTransition(
                scale: _animation,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    showUploadVideoDialog(context);
                  },
                  tooltip: 'RSVP Endorsements',
                  child: Icon(Icons.phone_callback_outlined),
                  heroTag: 'RSVP Endorsements',
                ),
              ),
             SizedBox(height: 16),
              ScaleTransition(
                scale: _animation,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    showSignOutDialog(context);
                  },
                  tooltip: 'Logout',
                  child: Icon(Icons.logout_outlined),
                  heroTag: 'signOut',
                ),
              ),
              SizedBox(height: 16),
              ScaleTransition(
                scale: _animation,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    showUploadImageDialog(context);
                  },
                  tooltip: 'Upload Image',
                  child: Icon(Icons.update_outlined),
                  heroTag: 'uploadImage',
                ),
              ),
              SizedBox(height: 16),
              ScaleTransition(
                scale: _animation,
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    showAddTextDialog(context);
                  },
                  tooltip: 'Add Text',
                  child: Icon(Icons.text_fields),
                  heroTag: 'addText',
                ),
              ),
              SizedBox(height: 16),
            ],
            FloatingActionButton(
              onPressed: _toggle,
              tooltip: 'Expand',
              backgroundColor: Colors.deepPurple,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
//signOut Function 
 void showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Logout'),
            onPressed: () async {
              try {
                final authAPI = Provider.of<AuthAPI>(context, listen: false);
                await authAPI.signOut();
                Navigator.of(context).pop(); // Close dialog
                // Navigate to home page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ExploreSkillsPage()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully!')),
                );
              } catch (e) {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  void showUploadVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('RSVP Skills'),
          content: Text('Please Click to View RSVP Skills'),
          actions: <Widget>[
            TextButton(
              child: Center(child: Text('RSVP Skills')),
              onPressed: () {
                 Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RSVPEvents()),
            );
              },
            ),
          ],
        );
      },
    );
  }

  void showUploadImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manage Skills'),
          content: Text('Please Click Button Below to Manage skills'),
          actions: <Widget>[
            TextButton(
              child: Text('Manage Skills'),
              onPressed: () {
                   Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageSkills()),
            );
              },
            ),
          ],
        );
      },
    );
  }

  void showAddTextDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Your Skill'),
          content: Text('Please add the mandatory required fields'),
          actions: <Widget>[
            TextButton(
              child: Center(child: Text('Add Skill')),
              onPressed: () {
               Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSkillPage()),
            );
              },
            ),
          ],
        );
      },
    );
  }
}
