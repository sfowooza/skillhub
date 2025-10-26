import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewLocation extends StatefulWidget {
  final String documentId;

  const ViewLocation({Key? key, required this.documentId}) : super(key: key);

  @override
  _ViewLocationState createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  late Future<Map<String, dynamic>> _locationData;

  @override
  void initState() {
    super.initState();
    _locationData = getLocationData();
  }

  Future<Map<String, dynamic>> getLocationData() async {
    // Return sample location data for now
    return {
      'firstName': 'Sample Business',
      'lat': 37.7749,
      'long': -122.4194
    };
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