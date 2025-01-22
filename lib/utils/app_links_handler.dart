// lib/utils/app_links_handler.dart
import 'package:app_links/app_links.dart';

class AppLinksHandler {
  static final AppLinks _appLinks = AppLinks();

  static Future<void> setup(BuildContext context) async {
    // Handle initial URI
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      _handleLink(uri, context);
    }

    // Handle URI while app is running
    _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        _handleLink(uri, context);
      }
    });
  }

  static void _handleLink(Uri uri, BuildContext context) {
    if (uri.path.contains('/verification')) {
      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully! You can now log in.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}