import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/models/registration_fields.dart';

class DatabaseAPI {
  late final AuthAPI auth;

  DatabaseAPI({required AuthAPI auth}) {
    this.auth = auth;
  }

  // Simplified methods that return sample data instead of making real API calls

  Future<List<Map<String, dynamic>>> getAllSkills() async {
    // Return sample skills data
    return [
      {
        'id': 'skill1',
        'firstName': 'John',
        'lastName': 'Doe',
        'description': 'Expert in Flutter development',
        'selectedCategory': 'Programming',
        'selectedSubcategory': 'Mobile Development',
        'location': 'New York',
        'phoneNumber': '+1234567890',
        'email': 'john@example.com',
        'datetime': DateTime.now().toIso8601String(),
        'participants': [],
        'averageRating': 4.5,
        'isAvailable': true,
        'portfolioImages': [],
      },
      {
        'id': 'skill2',
        'firstName': 'Jane',
        'lastName': 'Smith',
        'description': 'Professional graphic designer',
        'selectedCategory': 'Design',
        'selectedSubcategory': 'Graphic Design',
        'location': 'Los Angeles',
        'phoneNumber': '+1987654321',
        'email': 'jane@example.com',
        'datetime': DateTime.now().toIso8601String(),
        'participants': [],
        'averageRating': 4.8,
        'isAvailable': true,
        'portfolioImages': [],
      }
    ];
  }

  Future<List<Map<String, dynamic>>> getSkillsBySubCategory(String subCategory) async {
    final allSkills = await getAllSkills();
    return allSkills.where((skill) => skill['selectedSubcategory'] == subCategory).toList();
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    return await getAllSkills();
  }

  Future<Map<String, dynamic>> createSkill({
    required String message,
    required String description,
    required String gmaplocation,
    required RegistrationFields registrationFields,
    required double latitude,
    required double longitude,
    required String whatsappLinkController,
  }) async {
    // Return a sample created skill
    return {
      'id': 'new_skill_${DateTime.now().millisecondsSinceEpoch}',
      'text': message,
      'datetime': DateTime.now().toString(),
      'user_id': 'test_user_id',
      'description': description,
      'firstName': registrationFields.firstName,
      'lastName': registrationFields.lastName,
      'phoneNumber': registrationFields.phoneNumber,
      'location': registrationFields.location,
      'email': registrationFields.email,
      'selectedCategory': registrationFields.selectedCategory,
      'selectedSubcategory': registrationFields.selectedSubcategory,
      'participants': registrationFields.participants,
      'createdBy': registrationFields.createdBy,
      'inSoleBusiness': registrationFields.inSoleBusiness,
      'image': registrationFields.image,
      'gmap_location': gmaplocation,
      'lat': latitude,
      'long': longitude,
      'link': whatsappLinkController,
    };
  }

  Future<bool> deleteMessage({required String id}) async {
    print('Deleted skill with id: $id');
    return true;
  }

  Future<void> saveUserData(String userId, String username, String email) async {
    print('Saved user data: $userId, $username, $email');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return {
      'userId': 'test_user_id',
      'name': 'Test User',
      'email': 'test@example.com'
    };
  }

  Future<bool> rsvpEvent(List participants, String documentId) async {
    print('RSVP event: $documentId');
    return true;
  }

  Future<List<Map<String, dynamic>>> manageSkills() async {
    return await getAllSkills();
  }

  Future<void> updateSkill(
    String message,
    String description,
    double? latitude,
    double? longitude,
    String gmaplocation,
    String whatsappLinkController,
    RegistrationFields registrationFields,
    String docID,
  ) async {
    print('Updated skill: $docID');
  }

  Future<void> deleteSkill(String docID) async {
    print('Deleted skill: $docID');
  }

  Stream<Map<String, dynamic>> getSkillRatings(String skillId) {
    return Stream.value({
      'id': skillId,
      'averageRating': 4.5,
      'ratings': {'test_user_id': 4.5}
    });
  }

  Future<void> updateRating(String skillId, double rating) async {
    print('Updated rating for skill $skillId: $rating');
  }

  Future<Map<String, dynamic>> getSkillById(String skillId) async {
    final skills = await getAllSkills();
    return skills.firstWhere(
      (skill) => skill['id'] == skillId,
      orElse: () => skills.first,
    );
  }
}
