import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:skillhub/constants/constants.dart';

class ViewLocation extends StatefulWidget {
  final String documentId;

  const ViewLocation({Key? key, required this.documentId}) : super(key: key);

  @override
  _ViewLocationState createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  late Future<Map<String, dynamic>> _locationData;
  late Databases databases;
  late Client client;
  late Account account;

  @override
  void initState() {
    super.initState();

    client = Client()
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned(status: true);
    account = Account(client);
    databases = Databases(client);

    _locationData = getLocationData();
  }

  Future<Map<String, dynamic>> getLocationData() async {
    try {
      final response = await databases.getDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: widget.documentId,
      );

      final document = response.data;
      final firstName = document['firstName'] ?? 'Unknown';
      final latRaw = document['lat'];
      final longRaw = document['long'];

      double? latitude;
      double? longitude;

      if (latRaw != null) {
        if (latRaw is String) {
          latitude = double.tryParse(latRaw);
        } else if (latRaw is num) {
          latitude = latRaw.toDouble();
        } else {
          latitude = null;
        }
      }

      if (longRaw != null) {
        if (longRaw is String) {
          longitude = double.tryParse(longRaw);
        } else if (longRaw is num) {
          longitude = longRaw.toDouble();
        } else {
          longitude = null;
        }
      }

      if (latitude == null || longitude == null) {
        throw Exception('Latitude or Longitude is null');
      }

      return {'firstName': firstName, 'lat': latitude, 'long': longitude};
    } catch (e) {
      throw Exception('Failed to fetch location data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Location'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _locationData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No location data available'));
          } else {
            final String firstName = snapshot.data!['firstName'];
            final double latitude = snapshot.data!['lat'];
            final double longitude = snapshot.data!['long'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Business Name: $firstName',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Latitude: $latitude',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Longitude: $longitude',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('location'),
                        position: LatLng(latitude, longitude),
                        infoWindow: InfoWindow(title: firstName),
                      ),
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
