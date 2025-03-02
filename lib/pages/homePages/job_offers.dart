import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
  late Client client;
  late AuthAPI auth;
  late DatabaseAPI database;

  String userName = "User";
  List<Document> skills = [];
  bool isLoading = true;
  late String selectedSubCategory;
  String _selectedView = 'All Skills';

  @override
  void initState() {
    super.initState();
    client = Client();
    auth = AuthAPI(client: client);
    database = DatabaseAPI(auth: auth);
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

    if (selectedSubCategory == 'All') {
      database.getAllSkills().then((value) {
        setState(() {
          skills = value;
          isLoading = false;
        });
      });
    } else {
      final enumValue = SubCategoryMapper.toEnumValue(selectedSubCategory);
      database.getSkillsBySubCategory(enumValue).then((value) {
        setState(() {
          skills = value;
          isLoading = false;
        });
      });
    }
  }

  List<Document> getFilteredItems() {
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
                      items: skills.map((skill) {
                        return GestureDetector(
                          onTap: () {
                            print("Tapped skill: ${skill.data['title']}");
                            // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(skill: skill)));
                          },
                          child: EventContainer(data: skill),
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
            const SliverToBoxAdapter(
              child: Center(
                child: Text("No items found"),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    final skill = getFilteredItems()[index];
                    print("Tapped skill: ${skill.data['title']}");
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