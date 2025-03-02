import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/providers/registration_form_providers.dart';
import 'package:skillhub/pages/Auth_screens/login_page.dart'; // Add this import
import 'package:skillhub/pages/Auth_screens/register_page.dart'; // Add this import

class SubCategoryMapper {
  static String toEnumValue(String displayName) {
    if (displayToEnum.containsKey(displayName)) {
      return displayToEnum[displayName]!;
    }
    return displayName.replaceAll(' ', '');
  }

  static String toDisplayName(String enumValue) {
    if (enumToDisplay.containsKey(enumValue)) {
      return enumToDisplay[enumValue]!;
    }
    return enumValue.replaceAllMapped(
      RegExp(r'(?!^)([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
  }

  static final Map<String, String> displayToEnum = {
    'General Medicine': 'GeneralMedicine',
    'Graphic Design': 'GraphicDesign',
    'Data Science': 'DataScience',
    'Civil': 'Civil',
    'Mechanical': 'Mechanical',
    'Electrical': 'Electrical',
    'Architecture': 'Architecture',
    'Painting': 'Painting',
    'Plumbing': 'Plumbing',
    'Exterior Design': 'ExteriorDesign',
    'Building & Construction': 'BuildingConstruction',
    'Interior Design': 'InteriorDesign',
    'AI': 'AI',
    'Software': 'Software',
    'Animation': 'Animation',
    'Illustration': 'Illustration',
    'Cardiology': 'Cardiology',
    'Pediatrics': 'Pediatrics',
    'Tours & Travel': 'ToursTravel',
    'Hotels': 'Hotels',
    'Rest Gardens': 'RestGardens',
    'Game Parks': 'GameParks',
    'Game Reserves': 'GameReserves',
    'Beaches': 'Beaches',
    'Camp Sites': 'CampSites',
    'Buses': 'Buses',
    'Car Hire & Rental': 'CarHireRental',
    'Boat Ride': 'BoatRide',
    'Hair Salons': 'HairSalons',
    'Saunas': 'Saunas',
    'Beauty Parlour': 'BeautyParlour',
    'Pedicure': 'Pedicure',
    'Manicure': 'Manicure',
    'Mens Ware': 'MensWare',
    'Womens Ware': 'WomesWare', // Note: Typo retained from original
    'Poultry': 'Poultry',
    'Piggery': 'Piggery',
    'Goat Keeping': 'GoatFarming',
    'Cattle Keeping': 'CattleFarming',
    'Bee Farming': 'BeeFarming',
    'Fish Farming': 'FishFarming',
    'Bananas': 'Bananas',
    'Maize': 'Maize',
    'Beans': 'Beans',
  };

  static final Map<String, String> enumToDisplay = Map.fromEntries(
    displayToEnum.entries.map((e) => MapEntry(e.value, e.key)),
  );
}

class SubCategoryHomePage extends StatefulWidget {
  const SubCategoryHomePage({Key? key}) : super(key: key);

  @override
  _SubCategoryHomePageState createState() => _SubCategoryHomePageState();
}

class _SubCategoryHomePageState extends State<SubCategoryHomePage> {
  Map<String, List<Document>> groupedMessages = {};
  String searchQuery = '';
  List<String> filteredSubcategories = [];

  Client client = Client();
  late final Account account;
  late final Databases databases;
  late final AuthAPI auth;
  late final DatabaseAPI database;

  @override
  void initState() {
    super.initState();
    auth = AuthAPI(client: client);
    databases = Databases(client);
    account = Account(client);
    database = DatabaseAPI(auth: auth);
    loadMessages();
  }

  void loadMessages() async {
    try {
      final value = await database.getAllSkills();
      final grouped = groupMessagesBySubCategory(value);
      setState(() {
        groupedMessages = grouped;
      });
    } catch (e) {
      print(e);
    }
  }

  Map<String, List<Document>> groupMessagesBySubCategory(List<Document> messages) {
    final Map<String, List<Document>> subCategoryMap = {};

    for (var message in messages) {
      final enumValue = message.data['selectedSubcategory'] as String;
      final displayName = SubCategoryMapper.toDisplayName(enumValue);

      if (!subCategoryMap.containsKey(displayName)) {
        subCategoryMap[displayName] = [];
      }
      subCategoryMap[displayName]!.add(message);
    }

    return subCategoryMap;
  }

  String getImageUrlForSubCategory(String displayName) {
    final enumValue = SubCategoryMapper.toEnumValue(displayName);

    Map<String, String> imageUrls = {
      'Mechanical': 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Electrical': 'https://images.pexels.com/photos/9242271/pexels-photo-9242271.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Civil': 'https://images.pexels.com/photos/8488034/pexels-photo-8488034.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Architecture': 'https://images.pexels.com/photos/14330135/pexels-photo-14330135.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Painting': 'https://images.pexels.com/photos/994164/pexels-photo-994164.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Plumbing': 'https://images.pexels.com/photos/8486978/pexels-photo-8486978.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'ExteriorDesign': 'https://images.pexels.com/photos/11953905/pexels-photo-11953905.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'InteriorDesign': 'https://images.pexels.com/photos/2029694/pexels-photo-2029694.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'AI': 'https://images.pexels.com/photos/256219/pexels-photo-256219.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'DataScience': 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'GeneralMedicine': 'https://images.pexels.com/photos/4173230/pexels-photo-4173230.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'GraphicDesign': 'https://images.pexels.com/photos/1029757/pexels-photo-1029757.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Animation': 'https://images.pexels.com/photos/56759/pexels-photo-56759.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Illustration': 'https://images.pexels.com/photos/1097930/pexels-photo-1097930.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Software': 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Pediatrics': 'https://images.pexels.com/photos/4173230/pexels-photo-4173230.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'Cardiology': 'https://images.pexels.com/photos/4332678/pexels-photo-4332678.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
      'ToursTravel': 'https://images.pexels.com/photos/30272159/pexels-photo-30272159.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Hotels': 'https://images.pexels.com/photos/2259226/pexels-photo-2259226.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'RestGardens': 'https://images.pexels.com/photos/2907196/pexels-photo-2907196.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'GameParks': 'https://images.pexels.com/photos/26761636/pexels-photo-26761636.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'GameReserves': 'https://images.pexels.com/photos/26893480/pexels-photo-26893480.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Beaches': 'https://images.pexels.com/photos/1450360/pexels-photo-1450360.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'CampSites': 'https://images.pexels.com/photos/28123902/pexels-photo-28123902.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Buses': 'https://images.pexels.com/photos/3511679/pexels-photo-3511679.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'CarHireRental': 'https://images.pexels.com/photos/5648413/pexels-photo-5648413.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'BoatRide': 'https://images.pexels.com/photos/30324372/pexels-photo-30324372.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'HairSalons': 'https://images.pexels.com/photos/705255/pexels-photo-705255.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Saunas': 'https://images.pexels.com/photos/269110/pexels-photo-269110.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'BeautyParlour': 'https://images.pexels.com/photos/7446686/pexels-photo-7446686.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Pedicure': 'https://images.pexels.com/photos/13726059/pexels-photo-13726059.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'MensWare': 'https://images.pexels.com/photos/3651597/pexels-photo-3651597.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'WomensWare': 'https://images.pexels.com/photos/30289347/pexels-photo-30289347.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Poultry': 'https://images.pexels.com/photos/1769279/pexels-photo-1769279.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Piggery': 'https://images.pexels.com/photos/30300426/pexels-photo-30300426.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'GoatFarming': 'https://images.pexels.com/photos/914300/pexels-photo-914300.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'CattleFarming': 'https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'BeeFarming': 'https://images.pexels.com/photos/460961/pexels-photo-460961.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'FishFarming': 'https://images.pexels.com/photos/3731945/pexels-photo-3731945.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Bananas': 'https://images.pexels.com/photos/802783/pexels-photo-802783.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Maize': 'https://images.pexels.com/photos/872483/pexels-photo-872483.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
      'Beans': 'https://images.pexels.com/photos/176169/pexels-photo-176169.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
    };

    return imageUrls[enumValue] ?? 'https://images.pexels.com/photos/5222/snow-mountains-forest-winter.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
  }

  void _viewMessage(Document message, String displayName) {
    final enumValue = SubCategoryMapper.toEnumValue(displayName);
    print('Viewing message for category: $displayName (enum: $enumValue)');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobOffersStaggeredPage(
          title: displayName,
          selectedSubCategory: enumValue,
        ),
      ),
    );
  }

  void filterSubcategories(String query, List<String> subcategories) {
    setState(() {
      searchQuery = query;
      filteredSubcategories = subcategories
          .where((subCategory) {
            final normalizedQuery = query.toLowerCase().trim();
            final normalizedCategory = subCategory.toLowerCase().trim();
            return normalizedCategory.contains(normalizedQuery);
          })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<RegistrationFormProvider>(context);
    final selectedCategory = formProvider.selectedCategory;
    final subcategories = formProvider.subcategories[selectedCategory] ?? [];

    if (filteredSubcategories.isEmpty && searchQuery.isEmpty) {
      filteredSubcategories = subcategories;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Choose Sub Category'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                filterSubcategories(value, subcategories);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredSubcategories.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredSubcategories.length,
                    itemBuilder: (context, index) {
                      final displayName = filteredSubcategories[index];
                      final enumValue = SubCategoryMapper.toEnumValue(displayName);
                      final imageUrl = getImageUrlForSubCategory(displayName);
                      final messages = groupedMessages[displayName] ?? [];

                      return ProductCard(
                        productItem: ProductItem(
                          messageImageUrl: imageUrl,
                          category: displayName,
                        ),
                        onViewMessage: () {
                          if (messages.isNotEmpty) {
                            _viewMessage(messages.first, displayName);
                          } else {
                            print('No messages found for category: $displayName (enum: $enumValue)');
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('No Items Available'),
                                  content: Text(
                                    'No items available for $displayName. Would you like to add your own?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Login'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Sign Up'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  )
                : const Center(child: Text('No matching subcategories found')),
          ),
        ],
      ),
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
      child: GestureDetector(
        onTap: onViewMessage,
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
                child: Container(
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