import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewWhatsappLink extends StatefulWidget {
  @override
  _ViewWhatsappLinkState createState() => _ViewWhatsappLinkState();
}

class _ViewWhatsappLinkState extends State<ViewWhatsappLink> {
  late Future<String?> _whatsappLink;

  @override
  void initState() {
    super.initState();
    _whatsappLink = _fetchWhatsappLink();
  }

  Future<String?> _fetchWhatsappLink() async {
    // Return a placeholder WhatsApp link for now
    return 'https://wa.me/1234567890?text=Hello%20from%20SkillHub!';
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
