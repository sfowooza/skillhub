import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';
import 'package:skillhub/utils/category_mappers.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final databaseAPI = Provider.of<DatabaseAPI>(context, listen: false);
      final allSkills = await databaseAPI.getAllSkills();
      
      final lowercaseQuery = query.toLowerCase();
      final results = allSkills.where((skill) {
        // Search in skill title/text
        final skillText = (skill['text'] ?? '').toString().toLowerCase();
        final description = (skill['description'] ?? '').toString().toLowerCase();
        final category = (skill['selectedCategory'] ?? '').toString().toLowerCase();
        final subcategory = (skill['selectedSubcategory'] ?? '').toString().toLowerCase();
        final firstName = (skill['firstName'] ?? '').toString().toLowerCase();
        final lastName = (skill['lastName'] ?? '').toString().toLowerCase();
        final location = (skill['location'] ?? '').toString().toLowerCase();
        final businessName = (skill['businessName'] ?? '').toString().toLowerCase();
        
        // Search across all relevant fields
        return skillText.contains(lowercaseQuery) ||
               description.contains(lowercaseQuery) ||
               category.contains(lowercaseQuery) ||
               subcategory.contains(lowercaseQuery) ||
               firstName.contains(lowercaseQuery) ||
               lastName.contains(lowercaseQuery) ||
               location.contains(lowercaseQuery) ||
               businessName.contains(lowercaseQuery);
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BaseColors().customTheme.primaryColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search skills, categories, providers...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Debounce search - wait for user to stop typing
            Future.delayed(Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body: _isSearching
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: BaseColors().customTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text('Searching...'),
                ],
              ),
            )
          : _searchQuery.isEmpty
              ? _buildSearchSuggestions()
              : _searchResults.isEmpty
                  ? _buildNoResults()
                  : _buildSearchResults(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BaseColors().customTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildSuggestionCard(
            'Search by Skill',
            'e.g., "Plumbing", "Web Development", "Catering"',
            Icons.work,
          ),
          _buildSuggestionCard(
            'Search by Category',
            'e.g., "Engineering", "Technology", "Food Services"',
            Icons.category,
          ),
          _buildSuggestionCard(
            'Search by Location',
            'e.g., "Kampala", "Entebbe", "Jinja"',
            Icons.location_on,
          ),
          _buildSuggestionCard(
            'Search by Provider',
            'e.g., "John", "Mary\'s Catering", "Tech Solutions"',
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String example, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: BaseColors().customTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(example),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Results count header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.search, color: BaseColors().customTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BaseColors().customTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final skill = _searchResults[index];
              return _buildSkillCard(skill);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    final firstName = skill['firstName'] ?? '';
    final lastName = skill['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final skillTitle = skill['text'] ?? 'Untitled Skill';
    final description = skill['description'] ?? '';
    final location = skill['location'] ?? '';
    final category = skill['selectedCategory'] ?? '';
    final subcategory = skill['selectedSubcategory'] ?? '';
    final businessName = skill['businessName'] ?? '';
    final productOrService = skill['productOrService'] ?? 'Service';
    final rating = (skill['averageRating'] ?? 0.0).toDouble();
    final likesCount = (skill['likesCount'] ?? 0);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and offering type
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
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: productOrService == 'Product'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: productOrService == 'Product'
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    child: Text(
                      productOrService,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: productOrService == 'Product'
                            ? Colors.blue[700]
                            : Colors.green[700],
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
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
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
              SizedBox(height: 8),
              // Rating and likes
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.favorite, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text(
                    '$likesCount',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
