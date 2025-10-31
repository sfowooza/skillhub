// Removed Appwrite imports for simplified app
// import package:appwrite/models.dart - using stubs
import 'package:carousel_slider/carousel_slider.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/controllers/events_container.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/widgets/skill_display_card.dart';
import 'package:skillhub/utils/category_mappers.dart';
import 'package:skillhub/widgets/skill_display_card.dart';

class JobOffersPage extends StatefulWidget {
  final String title;
  final String? selectedSubCategory;

  const JobOffersPage({
    super.key,
    required this.title,
    this.selectedSubCategory,
  });

  @override
  State<JobOffersPage> createState() => _JobOffersPageState();
}

class _JobOffersPageState extends State<JobOffersPage> {
  // Removed Appwrite dependencies for simplified app
  List<Map<String, dynamic>> skills = [];
  bool isLoading = true;
  late String selectedSubCategory;
  String _selectedView = 'All Skills';
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    selectedSubCategory = widget.selectedSubCategory ?? 'All';
    if (SavedData.isLoggedIn()) {
      userName = SavedData.getUserName().split(" ")[0];
    }
    // Call refresh after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void refresh() async {
    setState(() {
      isLoading = true;
    });

    try {
      final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);

      if (selectedSubCategory != 'All') {
        // Fetch skills by subcategory
        final enumValue = SubCategoryMapper.toEnumValue(selectedSubCategory);
        skills = await databaseAPI.getSkillsBySubCategory(enumValue);
      } else {
        // Fetch all skills
        skills = await databaseAPI.getAllSkills();
      }
    } catch (e) {
      print('Error fetching skills: $e');
      // Fallback to empty list if there's an error
      skills = [];
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> getFilteredItems() {
    if (_selectedView == 'Popular Skills') {
      return skills.take(5).toList(); // Replace with actual logic if needed
    } else if (_selectedView == 'New') {
      return skills.reversed.toList(); // Replace with actual logic if needed
    } else {
      return skills;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAPI = Provider.of<AuthAPI>(context);
    final isAuthenticated = authAPI.status == AuthStatus.authenticated;
    
    // Get username from AuthAPI or SavedData
    String displayName = 'User';
    if (isAuthenticated) {
      // Try to get from current user first
      if (authAPI.currentUser?.name != null && authAPI.currentUser!.name.isNotEmpty) {
        displayName = authAPI.currentUser!.name.split(' ')[0];
      } else if (SavedData.isLoggedIn()) {
        displayName = SavedData.getUserName().split(' ')[0];
      }
    }

    final subCategories = ['All', ...SubCategoryMapper.displayToEnum.keys].toList();
    subCategories.removeWhere((element) => element == 'All');
    subCategories.sort();
    subCategories.insert(0, 'All');
    
    // Convert enum value to display name for dropdown
    final displaySubCategory = selectedSubCategory == 'All' 
        ? 'All' 
        : SubCategoryMapper.toDisplayName(selectedSubCategory);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Adds the back button on the left
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Aligns content to the right
          children: [
            if (isAuthenticated)
              Text(
                "Hi $displayName 👋",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (isAuthenticated) const SizedBox(width: 8),
            if (!isAuthenticated)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text("Login"),
              ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center( // Wrap Text in Center widget
                    child: Text(
                      "Explore Services & Products Around You",
                      style: TextStyle(
                        color: BaseColors().baseTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!isLoading && skills.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.99,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: skills.map<Widget>((skill) {
                        final skillData = skill as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            print("Tapped skill: ${skillData['firstName'] ?? 'Unknown'}");
                            // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(skill: skill)));
                          },
                          child: SkillDisplayCard(skillData: skillData),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: displaySubCategory,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          // Convert display name back to enum value for filtering
                          selectedSubCategory = newValue == 'All' 
                              ? 'All' 
                              : SubCategoryMapper.toEnumValue(newValue!);
                          isLoading = true;
                        });
                        refresh();
                      },
                      items: subCategories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavigationLinks(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2, top: 8, left: 6, right: 6),
              child: Text(
                _selectedView,
                style: TextStyle(
                  color: BaseColors().customTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (getFilteredItems().isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No skills found for '$selectedSubCategory'",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Be the first to add a skill in this category!\nTap the + button to get started.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    final skill = getFilteredItems()[index];
                    print("Tapped skill: ${skill['firstName'] ?? 'Unknown'}");
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(skill: skill)));
                  },
                  child: SkillDisplayCard(skillData: getFilteredItems()[index]),
                ),
                childCount: getFilteredItems().length,
              ),
            ),
        ],
      ),
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
    );
  }

  Widget _buildNavigationLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavigationLink('All Skills'),
        _buildNavigationLink('Popular Skills'),
        _buildNavigationLink('New'),
      ],
    );
  }

  Widget _buildNavigationLink(String view) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedView = view;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          view,
          style: TextStyle(
            color: _selectedView == view ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}