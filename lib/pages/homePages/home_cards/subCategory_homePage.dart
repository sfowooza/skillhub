
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';

import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/providers/registration_form_providers.dart';


class SubCategoryHomePage extends StatefulWidget {
  const SubCategoryHomePage({Key? key}) : super(key: key);

  @override
  _SubCategoryHomePageState createState() => _SubCategoryHomePageState();
}

class _SubCategoryHomePageState extends State<SubCategoryHomePage> {
  //final database = DatabaseAPI();
  Map<String, List<Document>> groupedMessages = {};
  String searchQuery = '';

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
      final subCategory = message.data['selectedSubcategory'] as String;
      if (!subCategoryMap.containsKey(subCategory)) {
        subCategoryMap[subCategory] = [];
      }
      subCategoryMap[subCategory]!.add(message);
    }

    return subCategoryMap;
  }

  String getImageUrlForSubCategory(String subCategory) {
    switch (subCategory) {
      case 'Mechanical':
        return 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Electrical':
        return 'https://images.pexels.com/photos/258875/pexels-photo-258875.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Civil':
        return 'https://images.pexels.com/photos/167075/pexels-photo-167075.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'AI':
        return 'https://images.pexels.com/photos/256219/pexels-photo-256219.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'DataScience':
        return 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'GeneralMedicine':
        return 'https://images.pexels.com/photos/4173230/pexels-photo-4173230.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'GraphicDesign':
        return 'https://images.pexels.com/photos/1029757/pexels-photo-1029757.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Animation':
        return 'https://images.pexels.com/photos/56759/pexels-photo-56759.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Illustration':
        return 'https://images.pexels.com/photos/1097930/pexels-photo-1097930.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Software':
        return 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Pediatrics':
        return 'https://images.pexels.com/photos/4173230/pexels-photo-4173230.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      case 'Cardiology':
        return 'https://images.pexels.com/photos/4332678/pexels-photo-4332678.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
      default:
        return 'https://images.pexels.com/photos/5222/snow-mountains-forest-winter.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'; // Default image
    }
  }

  // void _deleteMessage(String id) async {
  //   try {
  //     await database.deleteMessage(id: id);
  //     setState(() {
  //       for (var subCategory in groupedMessages.keys) {
  //         groupedMessages[subCategory]!.removeWhere((element) => element.$id == id);
  //         if (groupedMessages[subCategory]!.isEmpty) {
  //           groupedMessages.remove(subCategory);
  //         }
  //       }
  //     });
  //     const snackbar = SnackBar(content: Text('Message deleted!'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //   } catch (e) {
  //     _showAlert(title: 'Error', text: e.toString());
  //   }
  // }

  // void _showAlert({required String title, required String text}) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(text),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Ok'),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  void _viewMessage(Document message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JobOffersStaggeredPage(title: '',),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<RegistrationFormProvider>(context);
    final selectedCategory = formProvider.selectedCategory;
    final subcategories = formProvider.subcategories[selectedCategory] ?? [];

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
            child: subcategories.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = subcategories[index];
                      final subCategoryEnum = formProvider.subcategoryEnumMapping[subCategory];
                      final imageUrl = getImageUrlForSubCategory(subCategoryEnum ?? '');
                      final messages = groupedMessages[subCategory] ?? [];

                      return ProductCard(
                        productItem: ProductItem(
                          messageImageUrl: imageUrl,
                          category: subCategory,
                        ),
                        // onDeletePressed: () {
                        //   for (var message in messages) {
                        //     _deleteMessage(message.$id);
                        //   }
                        // },
                        onViewMessage: () {
                          if (messages.isNotEmpty) {
                            _viewMessage(messages.first);
                          }
                        },
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigation(
      //   onLoginPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const LoginPage()),
      //     );
      //   },
      //   onSignUpPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const RegisterPage()),
      //     );
      //   },
      // ),
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
