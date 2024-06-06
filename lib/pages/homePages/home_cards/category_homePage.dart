import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
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

class CategoryHomePage extends StatefulWidget {
  const CategoryHomePage({Key? key}) : super(key: key);

  @override
  _CategoryHomePageState createState() => _CategoryHomePageState();
}

class _CategoryHomePageState extends State<CategoryHomePage> {
  Map<String, List<Document>> groupedMessages = {};
  String searchQuery = '';
  bool isLoggedIn = false;

  Client client = Client();
  late final Account account;
  late final Databases databases;
  late final AuthAPI auth;
  late final DatabaseAPI database;

  @override
  void initState() {
    super.initState();
   auth = AuthAPI(client: client);  // assuming that AuthAPI takes a Client as a parameter
    databases = Databases(client);
    account = Account(client);
    database = DatabaseAPI(auth: auth);
    loadMessages();
  }

void loadMessages() async {
  try {
    final value = await database.getAllSkills();
    final grouped = groupMessagesByCategory(value);  // <-- here
    setState(() {
      groupedMessages = grouped;
    });
  } catch (e) {
    print(e);
  }
}


  Map<String, List<Document>> groupMessagesByCategory(List<Document> messages) {
    final Map<String, List<Document>> categoryMap = {};

    for (var message in messages) {
      final category = message.data['selectedCategory'] as String;
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
      default:
        return 'https://images.pexels.com/photos/5222/snow-mountains-forest-winter.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'; // Default image
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<RegistrationFormProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Choose Category')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: groupedMessages.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      final category = groupedMessages.keys.elementAt(index);
                      final messages = groupedMessages[category]!;
                      final imageUrl = getImageUrlForCategory(category);
                      return ProductCard(
                        productItem: ProductItem(
                          messageImageUrl: imageUrl,
                          category: category,
                        ),
                        // onDeletePressed: () {
                        //   for (var message in messages) {
                        //     _deleteMessage(message.$id);
                        //   }
                        // },
                        onViewMessage: () {
                          formProvider.selectedCategory = category;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubCategoryStaggeredHomePage(title: 'Skillhub',),
                            ),
                          );
                        }, // View the first message in the category
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  // void _deleteMessage(String id) async {
  //   try {
  //     await database.deleteMessage(id: id);
  //     setState(() {
  //       for (var category in groupedMessages.keys) {
  //         groupedMessages[category]!.removeWhere((element) => element.$id == id);
  //         if (groupedMessages[category]!.isEmpty) {
  //           groupedMessages.remove(category);
  //         }
  //       }
  //     });
  //     const snackbar = SnackBar(content: Text('Message deleted!'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //   } catch (e) {
  //     _showAlert(title: 'Error', text: e.toString());
  //   }
  // }

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
  //final VoidCallback onDeletePressed;
  final VoidCallback onViewMessage;

  const ProductCard({
    required this.productItem,
    //required this.onDeletePressed,
    required this.onViewMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
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
              child: GestureDetector(
                onTap: onViewMessage,
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
            ),
            // Positioned(
            //   top: 8,
            //   right: 8,
            //   child: IconButton(
            //     icon: const Icon(Icons.delete, color: Colors.white),
            //     onPressed: onDeletePressed,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
