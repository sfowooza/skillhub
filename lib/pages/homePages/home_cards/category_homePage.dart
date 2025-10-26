// Removed Appwrite imports for simplified app
import 'package:flutter/material.dart';
// import package:appwrite/models.dart - using stubs
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart';
import 'package:skillhub/pages/Auth_screens/register_page.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/pages/Staggered/subCategory_homePag.dart';
import 'package:skillhub/pages/homePages/skills_page.dart';
import 'package:skillhub/providers/registration_form_providers.dart';

class CategoryMapper {
  static String toEnumValue(String displayName) {
    if (displayToEnum.containsKey(displayName)) {
      return displayToEnum[displayName]!;
    }
    return displayName.replaceAll(' & ', '').replaceAll(' ', '');
  }

  static String toDisplayName(String enumValue) {
    if (enumToDisplay.containsKey(enumValue)) {
      return enumToDisplay[enumValue]!;
    }
    return enumValue;
  }

  static final Map<String, String> displayToEnum = {
    'Engineering': 'Engineering',
    'IT': 'IT',
    'Design': 'Design',
    'Medicine': 'Medicine',
    'Health & Beauty': 'HealthBeauty',
    'Farming & Agriculture': 'FarmingAgriculture',
    'Fashion': 'Fashion',
    'Leisure & Hospitality': 'LeisureHospitality',
    'Transport': 'Transport'
  };

  static final Map<String, String> enumToDisplay = Map.fromEntries(
    displayToEnum.entries.map((e) => MapEntry(e.value, e.key)),
  );
}

class CategoryHomePage extends StatefulWidget {
  const CategoryHomePage({Key? key}) : super(key: key);

  @override
  _CategoryHomePageState createState() => _CategoryHomePageState();
}

class _CategoryHomePageState extends State<CategoryHomePage> {
  Map<String, List<Map<String, dynamic>>> groupedMessages = {};
  String searchQuery = '';
  bool isLoggedIn = false;
  List<String> allCategories = [
    'Engineering',
    'IT',
    'Design',
    'Medicine',
    'Health & Beauty',
    'Farming & Agriculture',
    'Fashion',
    'Leisure & Hospitality',
    'Transport'
  ];
  List<String> filteredCategories = [];

  // Removed Appwrite dependencies for simplified app

  @override
  void initState() {
    super.initState();
    loadMessages();
    filteredCategories = allCategories;
  }

  void loadMessages() async {
    try {
      // Load sample data for simplified app
      final value = [
        {
          'selectedCategory': 'Programming',
          'firstName': 'Sample Programmer',
          'description': 'Expert in mobile development'
        },
        {
          'selectedCategory': 'Design', 
          'firstName': 'Sample Designer',
          'description': 'Professional graphic designer'
        }
      ];
      final grouped = groupMessagesByCategory(value);
      setState(() {
        groupedMessages = grouped;
        filteredCategories = allCategories;
      });
    } catch (e) {
      print(e);
    }
  }

  Map<String, List<Map<String, dynamic>>> groupMessagesByCategory(List<Map<String, dynamic>> messages) {
    final Map<String, List<Map<String, dynamic>>> categoryMap = {};

    for (var message in messages) {
      final category = message['selectedCategory'] as String;
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = [];
      }
      categoryMap[category]!.add(message);
    }

    return categoryMap;
  }

  String getImageUrlForCategory(String category) {
    switch (category) {
      case 'Engineering':
        return 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'IT':
        return 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Design':
        return 'https://images.pexels.com/photos/936722/pexels-photo-936722.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Medicine':
        return 'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Health & Beauty':
        return 'https://images.pexels.com/photos/1591374/pexels-photo-1591374.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260';
      case 'Farming & Agriculture':
        return 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260';
      case 'Fashion':
        return 'https://images.pexels.com/photos/3769022/pexels-photo-3769022.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260';
      case 'Leisure & Hospitality':
        return 'https://images.pexels.com/photos/30339550/pexels-photo-30339550.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260';
      case 'Transport':
        return 'https://images.pexels.com/photos/5648413/pexels-photo-5648413.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260';
      default:
        return 'https://images.pexels.com/photos/5222/snow-mountains-forest-winter.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
    }
  }

  void filterCategories(String query) {
    setState(() {
      searchQuery = query;
      filteredCategories = allCategories
          .where((category) => category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<RegistrationFormProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Choose Category')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterCategories,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredCategories.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final imageUrl = getImageUrlForCategory(category);
                      return ProductCard(
                        productItem: ProductItem(
                          messageImageUrl: imageUrl,
                          category: category,
                        ),
                        onViewMessage: () {
                          formProvider.selectedCategory = category;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubCategoryStaggeredHomePage(title: 'Skillhub'),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('No matching categories found')),
          ),
        ],
      ),
    );
  }

  void _showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }
}

class ProductItem {
  final String messageImageUrl;
  final String category;

  ProductItem({required this.messageImageUrl, required this.category});
}

class ProductCard extends StatelessWidget {
  final ProductItem productItem;
  final VoidCallback onViewMessage;

  const ProductCard({
    required this.productItem,
    required this.onViewMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: GestureDetector( // Wrap the entire card with GestureDetector
        onTap: onViewMessage, // Trigger navigation on tap
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                productItem.messageImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container( // Removed GestureDetector from here
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productItem.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}