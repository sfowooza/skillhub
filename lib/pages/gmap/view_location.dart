import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:appwrite/appwrite.dart';

class ViewLocation extends StatefulWidget {
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

    // Initialize the Appwrite client
    client = Client()
        .setEndpoint('https://skillhub.avodahsystems.com/v1') // Replace with your Appwrite endpoint
        .setProject('665a50350038457d0eb9') // Replace with your project ID
        .setSelfSigned(status: true); // Only use for self-signed certificates

    account = Account(client);
    databases = Databases(client);

    // Fetch location data
    _locationData = getLocationData();
  }

  Future<Map<String, dynamic>> getLocationData() async {
    try {
      print("Fetching location data...");
      final response = await databases.listDocuments(
        databaseId: '665a51130023590b5e21', // Replace with your database ID
        collectionId: '665a5516000b61b3093f', // Replace with your collection ID
      );
      print("Response: ${response.documents}");

      if (response.documents.isNotEmpty) {
        // Assuming the location data is stored in the 'firstName', 'lat', and 'long' fields
        final document = response.documents.first.data;
        print("Document data: $document");
        final firstName = document['firstName'] ?? 'Unknown';
        final latitude = document['lat']?.toDouble() ?? 0.0;
        final longitude = document['long']?.toDouble() ?? 0.0;
        return {'firstName': firstName, 'lat': latitude, 'long': longitude};
      } else {
        throw Exception('No documents found in the collection');
      }
    } catch (e) {
      print("Error fetching location data: $e");
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
            // Extract firstName, latitude, and longitude from the Map<String, dynamic>
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
                // Display Google Map with the extracted latitude and longitude
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
