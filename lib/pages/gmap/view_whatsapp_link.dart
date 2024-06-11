import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewWhatsappLink extends StatefulWidget {
  @override
  _ViewWhatsappLinkState createState() => _ViewWhatsappLinkState();
}

class _ViewWhatsappLinkState extends State<ViewWhatsappLink> {
  late Future<String?> _whatsappLink;
  late Databases databases;
  late Client client;
  late Account account;

  @override
  void initState() {
    super.initState();

    // Initialize the databases variable before the _whatsappLink variable
    client = Client()
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned(status: true);
    account = Account(client);
    databases = Databases(client);

    _whatsappLink = getWhatsappLink();
  }

  Future<String?> getWhatsappLink() async {
    final response = await databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID, // Replace with your database ID
      collectionId: COLLECTION_DB_ID, // Replace with your collection ID
    );

    // Log the complete response for debugging
    print('Response: ${response.toMap()}');

    // Check if there are any documents returned
    if (response.documents.isNotEmpty) {
      for (var document in response.documents) {
        print('Document data: ${document.data}');
        final link = document.data['link'];
        print('Link value: $link');
        print('Link data type: ${link.runtimeType}');
        if (link != null && link is String && link.isNotEmpty) {
          return link;
        }
      }
      return null;
    } else {
      return null;
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View WhatsApp Link'),
      ),
      body: FutureBuilder<String?>(
        future: _whatsappLink,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No WhatsApp link found'));
          } else {
            final String link = snapshot.data!;

            return Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(link),
                child: Text('Open WhatsApp Catalogue'),
              ),
            );
          }
        },
      ),
    );
  }
}
