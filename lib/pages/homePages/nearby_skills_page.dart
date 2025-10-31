import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'dart:math' show cos, sqrt, asin;

class NearbySkillsPage extends StatefulWidget {
  final String subcategory;
  final String category;

  const NearbySkillsPage({
    Key? key,
    required this.subcategory,
    required this.category,
  }) : super(key: key);

  @override
  State<NearbySkillsPage> createState() => _NearbySkillsPageState();
}

class _NearbySkillsPageState extends State<NearbySkillsPage> {
  Position? currentPosition;
  bool isLoadingLocation = true;
  bool locationPermissionGranted = false;
  List<Map<String, dynamic>> nearbySkills = [];
  bool isLoadingSkills = false;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
        locationPermissionGranted = true;
        isLoadingLocation = false;
      });

      // Load nearby skills
      await _loadNearbySkills();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _loadNearbySkills() async {
    if (currentPosition == null) return;

    setState(() {
      isLoadingSkills = true;
    });

    try {
      final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);
      
      // Get all skills for the subcategory
      final allSkills = await databaseAPI.getSkillsBySubCategory(widget.subcategory);

      // Calculate distance for each skill and filter
      List<Map<String, dynamic>> skillsWithDistance = [];

      for (var skill in allSkills) {
        final lat = skill['lat'] as double?;
        final long = skill['long'] as double?;

        if (lat != null && long != null) {
          final distance = _calculateDistance(
            currentPosition!.latitude,
            currentPosition!.longitude,
            lat,
            long,
          );

          // Only include skills within 50km
          if (distance <= 50) {
            skill['distance'] = distance;
            skillsWithDistance.add(skill);
          }
        }
      }

      // Sort by distance
      skillsWithDistance.sort((a, b) => 
        (a['distance'] as double).compareTo(b['distance'] as double)
      );

      // Create markers for map
      Set<Marker> newMarkers = {};
      for (var i = 0; i < skillsWithDistance.length; i++) {
        final skill = skillsWithDistance[i];
        final lat = skill['lat'] as double;
        final long = skill['long'] as double;
        
        newMarkers.add(
          Marker(
            markerId: MarkerId(skill['\$id'] ?? 'marker_$i'),
            position: LatLng(lat, long),
            infoWindow: InfoWindow(
              title: skill['text'] ?? 'Service Provider',
              snippet: '${skill['distance'].toStringAsFixed(1)} km away',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkillDetails(data: skill),
                ),
              );
            },
          ),
        );
      }

      setState(() {
        nearbySkills = skillsWithDistance;
        markers = newMarkers;
        isLoadingSkills = false;
      });
    } catch (e) {
      print('Error loading nearby skills: $e');
      setState(() {
        isLoadingSkills = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading nearby providers: $e')),
        );
      }
    }
  }

  // Calculate distance between two points using Haversine formula (in km)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services to find nearby service providers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text('Location permission is required to find nearby service providers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text('Location permission was permanently denied. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby ${widget.subcategory}'),
        backgroundColor: BaseColors().customTheme.primaryColor,
      ),
      body: isLoadingLocation
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : !locationPermissionGranted
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Location access required',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Enable location to find service providers near you',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _requestLocationPermission,
                        icon: Icon(Icons.location_on),
                        label: Text('Enable Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BaseColors().customTheme.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : isLoadingSkills
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Finding nearby providers...'),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Map view
                        Container(
                          height: 300,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                currentPosition!.latitude,
                                currentPosition!.longitude,
                              ),
                              zoom: 12,
                            ),
                            markers: markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (controller) {
                              mapController = controller;
                            },
                          ),
                        ),
                        
                        // List header
                        Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.grey[100],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${nearbySkills.length} providers found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Within 50 km',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Skills list
                        Expanded(
                          child: nearbySkills.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No providers found nearby',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search area',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(8),
                                  itemCount: nearbySkills.length,
                                  itemBuilder: (context, index) {
                                    final skill = nearbySkills[index];
                                    return _buildSkillCard(skill);
                                  },
                                ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    final distance = skill['distance'] as double;
    final priceRange = skill['priceRange'] as String? ?? 'Contact for pricing';
    final businessName = skill['businessName'] as String?;
    final firstName = skill['firstName'] as String? ?? 'Provider';
    final rating = skill['averageRating'] ?? 0.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillDetails(data: skill),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Distance badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: BaseColors().customTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: BaseColors().customTheme.primaryColor,
                      size: 24,
                    ),
                    Text(
                      '${distance.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: BaseColors().customTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        fontSize: 10,
                        color: BaseColors().customTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              
              // Skill info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (businessName != null && businessName.isNotEmpty)
                      Text(
                        businessName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      firstName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            priceRange,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (rating > 0) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
