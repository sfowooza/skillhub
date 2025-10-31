import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:skillhub/pages/homePages/search_page.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/pages/homePages/home_cards/category_homePage.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/utils/category_mappers.dart' as CategoryMapperUtil;
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

class ExploreSkillsPage extends StatefulWidget {
  const ExploreSkillsPage({Key? key}) : super(key: key);

  @override
  State<ExploreSkillsPage> createState() => _ExploreSkillsPageState();
}

class _ExploreSkillsPageState extends State<ExploreSkillsPage> {
  List<Map<String, dynamic>> allSkills = [];
  List<Map<String, dynamic>> filteredSkills = [];
  bool isLoading = true;
  
  String selectedCategory = 'All';
  String selectedSubcategory = 'All';
  
  // Location-based search
  bool searchNearby = false;
  LocationData? currentLocation;
  Location location = Location();
  double maxDistance = 10.0; // Default: 10 km radius
  
  // All available categories
  final List<String> categories = [
    'All',
    'Engineering',
    'IT',
    'Design',
    'Medicine',
    'Health & Beauty',
    'Farming & Agriculture',
    'Fashion',
    'Leisure & Hospitality',
    'Transport'
  ];
  
  // Subcategories map - matches actual app subcategories
  Map<String, List<String>> subcategoriesMap = {
    'All': ['All'],
    'Engineering': ['All', 'Civil', 'Mechanical', 'Electrical', 'Architecture', 'Painting', 'Plumbing', 'Interior Design', 'Exterior Design', 'Building & Construction'],
    'IT': ['All', 'Software', 'Data Science', 'AI'],
    'Design': ['All', 'Graphic Design', 'Illustration', 'Animation'],
    'Medicine': ['All', 'General Medicine', 'Pediatrics', 'Cardiology'],
    'Health & Beauty': ['All', 'Hair Salons', 'Saunas', 'Beauty Parlour', 'Pedicure', 'Manicure'],
    'Farming & Agriculture': ['All', 'Poultry', 'Piggery', 'Goat Keeping', 'Cattle Keeping', 'Acquaculture', 'Bee Farming', 'Fish Farming', 'Bananas', 'Maize', 'Beans'],
    'Fashion': ['All', 'Mens Ware', 'Womens Ware'],
    'Leisure & Hospitality': ['All', 'Tours & Travel', 'Hotels', 'Rest Gardens', 'Game Parks', 'Game Reserves', 'Beaches', 'Camp Sites'],
    'Transport': ['All', 'Buses', 'Car Hire & Rental', 'Boat Ride']
  };

  @override
  void initState() {
    super.initState();
    _loadAllSkills();
  }

  Future<void> _loadAllSkills() async {
    setState(() {
      isLoading = true;
    });

    try {
      final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);
      final skills = await databaseAPI.getAllSkills();
      
      setState(() {
        allSkills = skills;
        filteredSkills = skills;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading skills: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load skills: $e')),
        );
      }
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2));
    
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }
  
  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180.0);
  }
  
  double sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location service is disabled')),
          );
        }
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }

    // Get current location
    try {
      final locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
        searchNearby = true;
      });
      _applyFilters();
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      filteredSkills = allSkills.where((skill) {
        // Category filter
        if (selectedCategory != 'All') {
          final skillCategory = CategoryMapperUtil.CategoryMapper.toDisplayName(skill['selectedCategory'] ?? '');
          if (skillCategory != selectedCategory) {
            return false;
          }
        }
        
        // Subcategory filter
        if (selectedSubcategory != 'All') {
          final skillSubcategory = skill['selectedSubcategory'] ?? '';
          if (skillSubcategory != selectedSubcategory) {
            return false;
          }
        }
        
        // Location-based filter
        if (searchNearby && currentLocation != null) {
          final skillLat = (skill['lat'] as num?)?.toDouble();
          final skillLon = (skill['long'] as num?)?.toDouble();
          
          if (skillLat != null && skillLon != null) {
            final distance = _calculateDistance(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
              skillLat,
              skillLon,
            );
            
            if (distance > maxDistance) {
              return false;
            }
          } else {
            // Exclude skills without location data when searching nearby
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Sort by distance if searching nearby
      if (searchNearby && currentLocation != null) {
        filteredSkills.sort((a, b) {
          final distA = _calculateDistance(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
            (a['lat'] as num?)?.toDouble() ?? 0.0,
            (a['long'] as num?)?.toDouble() ?? 0.0,
          );
          final distB = _calculateDistance(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
            (b['lat'] as num?)?.toDouble() ?? 0.0,
            (b['long'] as num?)?.toDouble() ?? 0.0,
          );
          return distA.compareTo(distB);
        });
      }
    });
  }

  List<String> _getAvailableSubcategories() {
    return subcategoriesMap[selectedCategory] ?? ['All'];
  }

  @override
  Widget build(BuildContext context) {
    final authAPI = Provider.of<AuthAPI>(context);
    final isAuthenticated = authAPI.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: BaseColors().customTheme.primaryColor,
        elevation: 2,
        title: Row(
          children: [
            Icon(Icons.explore, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Explore Services & Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.category, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryHomePage()),
              );
            },
            tooltip: 'Browse Categories',
          ),
        ],
      ),
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
      body: Column(
        children: [
          // Filters section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Category dropdown
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BaseColors().customTheme.primaryColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: BaseColors().customTheme.primaryColor),
                            style: TextStyle(color: Colors.black87, fontSize: 14),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: category == 'All' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                                selectedSubcategory = 'All'; // Reset subcategory
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Subcategory dropdown
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BaseColors().customTheme.primaryColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSubcategory,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: BaseColors().customTheme.primaryColor),
                            style: TextStyle(color: Colors.black87, fontSize: 14),
                            items: _getAvailableSubcategories().map((String subcategory) {
                              return DropdownMenuItem<String>(
                                value: subcategory,
                                child: Text(
                                  subcategory,
                                  style: TextStyle(
                                    fontWeight: subcategory == 'All' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSubcategory = newValue!;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Nearby search toggle
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: searchNearby ? BaseColors().customTheme.primaryColor : Colors.grey[300]!,
                      width: searchNearby ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: searchNearby ? BaseColors().customTheme.primaryColor : Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search Nearby Providers',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: searchNearby ? BaseColors().customTheme.primaryColor : Colors.grey[700],
                              ),
                            ),
                          ),
                          Switch(
                            value: searchNearby,
                            onChanged: (value) {
                              if (value) {
                                _requestLocationPermission();
                              } else {
                                setState(() {
                                  searchNearby = false;
                                  currentLocation = null;
                                });
                                _applyFilters();
                              }
                            },
                            activeColor: BaseColors().customTheme.primaryColor,
                          ),
                        ],
                      ),
                      if (searchNearby && currentLocation != null) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.social_distance, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Radius: ${maxDistance.toStringAsFixed(0)} km',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: maxDistance,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: '${maxDistance.toStringAsFixed(0)} km',
                          activeColor: BaseColors().customTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              maxDistance = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _applyFilters();
                          },
                        ),
                        Text(
                          'Location: ${currentLocation!.latitude!.toStringAsFixed(4)}, ${currentLocation!.longitude!.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Quick subcategory search
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Quick Filter by Subcategory',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getAvailableSubcategories().where((sub) => sub != 'All').map((subcategory) {
                        final isSelected = selectedSubcategory == subcategory;
                        return FilterChip(
                          label: Text(
                            subcategory,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedSubcategory = selected ? subcategory : 'All';
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: BaseColors().customTheme.primaryColor,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? BaseColors().customTheme.primaryColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Results count
                Row(
                  children: [
                    Text(
                      '${filteredSkills.length} skill${filteredSkills.length != 1 ? 's' : ''} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (searchNearby && currentLocation != null) ...[
                      Spacer(),
                      Icon(Icons.location_on, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Sorted by distance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Skills list
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: BaseColors().customTheme.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text('Loading skills...'),
                      ],
                    ),
                  )
                : filteredSkills.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'No skills found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAllSkills,
                        color: BaseColors().customTheme.primaryColor,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: filteredSkills.length,
                          itemBuilder: (context, index) {
                            final skill = filteredSkills[index];
                            return _buildSkillCard(skill);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    final firstName = skill['firstName'] ?? '';
    final lastName = skill['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final skillTitle = skill['text'] ?? 'Untitled Skill';
    final description = skill['description'] ?? '';
    final location = skill['location'] ?? '';
    final category = CategoryMapperUtil.CategoryMapper.toDisplayName(skill['selectedCategory'] ?? '');
    final subcategory = skill['selectedSubcategory'] ?? '';
    final businessName = skill['businessName'] ?? '';
    final productOrService = skill['productOrService'] ?? 'Service';
    final rating = (skill['averageRating'] ?? 0.0).toDouble();
    final likesCount = (skill['likesCount'] ?? 0);
    final imageId = skill['image'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillDetails(data: skill),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (imageId != null && imageId.toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  '${Constants.endpoint}/storage/buckets/${Constants.bucketId}/files/$imageId/view?project=${Constants.projectId}',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [BaseColors().customTheme.primaryColor, BaseColors().kLightGreen],
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.white70),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: BaseColors().customTheme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and offering type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          skillTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: BaseColors().customTheme.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: productOrService == 'Product'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: productOrService == 'Product' ? Colors.blue : Colors.green,
                          ),
                        ),
                        child: Text(
                          productOrService,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: productOrService == 'Product' ? Colors.blue[700] : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Provider name
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (businessName.isNotEmpty) ...[
                        Text(' • ', style: TextStyle(color: Colors.grey)),
                        Flexible(
                          child: Text(
                            businessName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  // Category and subcategory
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (subcategory.isNotEmpty) ...[
                        Text(' • ', style: TextStyle(color: Colors.grey)),
                        Text(
                          subcategory,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  if (location.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                  SizedBox(height: 12),
                  // Rating and likes
                  Row(
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.favorite, size: 18, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      // Show distance if nearby search is active
                      if (searchNearby && currentLocation != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.green[700]),
                              SizedBox(width: 4),
                              Text(
                                '${_calculateDistance(
                                  currentLocation!.latitude!,
                                  currentLocation!.longitude!,
                                  (skill['lat'] as num?)?.toDouble() ?? 0.0,
                                  (skill['long'] as num?)?.toDouble() ?? 0.0,
                                ).toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Icon(Icons.arrow_forward_ios, size: 16, color: BaseColors().customTheme.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
