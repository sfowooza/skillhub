// Removed Appwrite imports for simplified app
// import package:appwrite/models.dart - using stubs
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/controllers/events_container.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/utils/category_mappers.dart';

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
    refresh();
  }

  void refresh() {
    setState(() {
      isLoading = true;
    });
    // Simulate loading real data from database
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        // Sample skills data that matches different subcategories
        final allSkills = [
          {
            'firstName': 'John',
            'lastName': 'Doe',
            'selectedCategory': 'IT',
            'selectedSubcategory': 'Mobile Development',
            'description': 'Expert Flutter Developer with 5+ years experience. I specialize in building beautiful, performant mobile applications.',
            'location': 'Kampala, Uganda',
            'phoneNumber': '+256701234567',
            'email': 'john.doe@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
            'participants': [],
            'averageRating': 4.8,
            'text': 'Expert Flutter Developer with 5+ years experience',
            'inSoleBusiness': true,
            'image': 'default_image',
            'user_id': 'sample_user_1',
            '\$id': 'sample_1',
          },
          {
            'firstName': 'Sarah',
            'lastName': 'Johnson',
            'selectedCategory': 'Design',
            'selectedSubcategory': 'Graphic Design',
            'description': 'Creative graphic designer specializing in logo design, brand identity, and marketing materials.',
            'location': 'Nairobi, Kenya',
            'phoneNumber': '+256702345678',
            'email': 'sarah.design@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
            'participants': [],
            'averageRating': 4.5,
            'text': 'Professional Graphic Designer - Logo & Branding',
            'inSoleBusiness': false,
            'image': 'default_image',
            'user_id': 'sample_user_2',
            '\$id': 'sample_2',
          },
          {
            'firstName': 'Michael',
            'lastName': 'Brown',
            'selectedCategory': 'Engineering',
            'selectedSubcategory': 'Civil',
            'description': 'Licensed civil engineer with expertise in construction project management, structural design, and infrastructure development.',
            'location': 'Dar es Salaam, Tanzania',
            'phoneNumber': '+256703456789',
            'email': 'michael.engineer@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
            'participants': [],
            'averageRating': 4.2,
            'text': 'Certified Civil Engineer - Construction & Project Management',
            'inSoleBusiness': true,
            'image': 'default_image',
            'user_id': 'sample_user_3',
            '\$id': 'sample_3',
          },
          {
            'firstName': 'Emma',
            'lastName': 'Wilson',
            'selectedCategory': 'Health & Beauty',
            'selectedSubcategory': 'Beauty Therapy',
            'description': 'Professional beauty therapist offering hair styling, makeup, manicure/pedicure, and skincare treatments.',
            'location': 'Kigali, Rwanda',
            'phoneNumber': '+256704567890',
            'email': 'emma.beauty@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
            'participants': [],
            'averageRating': 4.7,
            'text': 'Beauty Therapist & Hair Stylist - Salon Services',
            'inSoleBusiness': false,
            'image': 'default_image',
            'user_id': 'sample_user_4',
            '\$id': 'sample_4',
          },
          {
            'firstName': 'David',
            'lastName': 'Lee',
            'selectedCategory': 'IT',
            'selectedSubcategory': 'Web Development',
            'description': 'Experienced full-stack developer specializing in MongoDB, Express.js, React.js, and Node.js.',
            'location': 'Lagos, Nigeria',
            'phoneNumber': '+256705678901',
            'email': 'david.web@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'participants': [],
            'averageRating': 4.9,
            'text': 'Full-Stack Web Developer - MERN Stack Expert',
            'inSoleBusiness': true,
            'image': 'default_image',
            'user_id': 'sample_user_5',
            '\$id': 'sample_5',
          },
          {
            'firstName': 'Grace',
            'lastName': 'Okafor',
            'selectedCategory': 'Fashion',
            'selectedSubcategory': 'Fashion Design',
            'description': 'Creative fashion designer specializing in custom clothing, wedding dresses, and traditional attire.',
            'location': 'Accra, Ghana',
            'phoneNumber': '+256706789012',
            'email': 'grace.fashion@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
            'participants': [],
            'averageRating': 4.6,
            'text': 'Fashion Designer - Custom Clothing & Tailoring',
            'inSoleBusiness': false,
            'image': 'default_image',
            'user_id': 'sample_user_6',
            '\$id': 'sample_6',
          },
          {
            'firstName': 'Dr. James',
            'lastName': 'Smith',
            'selectedCategory': 'Medicine',
            'selectedSubcategory': 'General Practice',
            'description': 'Licensed medical doctor providing general healthcare services, consultations, and medical advice.',
            'location': 'Addis Ababa, Ethiopia',
            'phoneNumber': '+256707890123',
            'email': 'dr.smith@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
            'participants': [],
            'averageRating': 4.8,
            'text': 'Medicine Doctor - General Practitioner',
            'inSoleBusiness': true,
            'image': 'default_image',
            'user_id': 'sample_user_7',
            '\$id': 'sample_7',
          },
          {
            'firstName': 'Peter',
            'lastName': 'Nkosi',
            'selectedCategory': 'Farming & Agriculture',
            'selectedSubcategory': 'Crop Farming',
            'description': 'Agricultural expert providing consulting services for crop farming, livestock management, and sustainable farming practices.',
            'location': 'Harare, Zimbabwe',
            'phoneNumber': '+256708901234',
            'email': 'peter.agri@example.com',
            'datetime': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
            'participants': [],
            'averageRating': 4.3,
            'text': 'Agriculture Consultant - Crop Farming & Livestock',
            'inSoleBusiness': true,
            'image': 'default_image',
            'user_id': 'sample_user_8',
            '\$id': 'sample_8',
          },
        ];

        // Filter skills by subcategory if one is selected
        if (selectedSubCategory != 'All') {
          // Convert display name to enum value for comparison
          final enumValue = SubCategoryMapper.toEnumValue(selectedSubCategory);
          skills = allSkills.where((skill) =>
              skill['selectedSubcategory'] == enumValue ||
              skill['selectedSubcategory'] == selectedSubCategory).toList();
        } else {
          skills = allSkills;
        }

        isLoading = false;
      });
    });
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
    final isAuthenticated = Provider.of<AuthAPI>(context).status == AuthStatus.authenticated;

    final subCategories = ['All', ...SubCategoryMapper.displayToEnum.keys].toList();
    subCategories.removeWhere((element) => element == 'All');
    subCategories.sort();
    subCategories.insert(0, 'All');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Adds the back button on the left
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Aligns content to the right
          children: [
            Text(
              isAuthenticated ? "Hi $userName \u{1F44B}\u{FE0F}" : "Hi",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8), // Small spacing between "Hi" and "Login"
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
                          child: EventContainer(data: skillData),
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
                      value: selectedSubCategory,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubCategory = newValue!;
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
                  child: EventContainer(data: getFilteredItems()[index]),
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