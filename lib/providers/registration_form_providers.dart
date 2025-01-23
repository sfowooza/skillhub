import 'package:flutter/foundation.dart';

class RegistrationFormProvider with ChangeNotifier {
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _email;
  String? _datetime;
  String? _image;
  String? _description;
  String? _createdBy;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _location;
  String? _participants;
  bool? _inSoleBusiness;

  final Map<String, List<String>> _subcategories = {
    'Engineering': [
  'Civil Engineering', 
  'Mechanical', 
  'Electrical',
  'Architecture',
  'Plumbing',
  'Interior Design',
  'Exterior Design',
  'Building & Construction'
],
    'IT': ['Software Engineering', 'Data Science', 'AI'],
    'Design': ['Graphic Design', 'Illustration', 'Animation'],
    'Medicine': ['General Medicine', 'Pediatrics', 'Cardiology'],
    'Leisure & Hospitality': ['Tours & Travel', 'Hotels', 'Rest Gardens', 'Game Parks', 'Game Reserves', 'Beaches', 'Camp Sites'],
    'Transport': ['Buses', 'Car Hire & Rental', 'Boat Ride', ],
    'Health & Beauty': ['Hair Salons', 'Saunas', 'Beauty Parlour', 'Pedicure', 'Manicure'],
    'Fashion': ['Mens Ware', 'Womens Ware'],
    'Farming & Agriculture': ['Poultry', 'Piggery', 'Goat Keeping', 'Cattle Keeping', 'Acquaculture', 'Bee Farming', 'Fish Farming', 'Bananas', 'Maize', 'Beans'],
  };

  // Define mapping between user-friendly display names and Enum values
  Map<String, String> subcategoryEnumMapping = {
    'Civil Engineering': 'CivilEngineering',
  'General Medicine': 'GeneralMedicine',
  'Graphic Design': 'GraphicDesign',
  'Data Science': 'DataScience',
  'Interior Design': 'InteriorDesign',
  'Exterior Design': 'ExteriorDesign',
  'Mechanical': 'Mechanical',
  'Electrical': 'Electrical',
  'Architecture': 'Architecture',
  'Plumbing': 'Plumbing',
  'Building & Construction': 'BuildingConstruction',
  'AI': 'AI',
  'Software': 'Software',
  'Animation': 'Animation',
  'Illustration': 'Illustration',
  'Painting': 'Painting',
  'Cardiology': 'Cardiology',
  'Pediatrics': 'Pediatrics',
  'Tours & Travel': 'ToursTravel',
  'Hotels': 'Hotels',
  'Rest Gardens': 'RestGardens',
  'Game Parks': 'GameParks',
  'Game Reserves': 'GameReserves',
  'Beaches': 'Beaches',
  'Camp Sites': 'CampSites',
  'Car Hire & Rental': 'CarHireRental',
  'Buses': 'Buses',
  'Boat Ride': 'BoatRide',
  'Hair Salons': 'HairSalons',
  'Saunas': 'Saunas',
  'Beauty Parlour': 'BeautyParlour',
  'Pedicure': 'Pedicure',
  'Manicure': 'Manicure',
  'Mens Ware': 'MensWare',
  'Womens Ware': 'WomesWare',
  'Poultry': 'Poultry',
  'Piggery': 'Piggery',
  'Goat Keeping': 'GoatFarming',
  'Cattle Keeping': 'CattleFarming',
  'Bee Farming': 'BeeFarming',
  'Fish Farming': 'FishFarming',
  'Bananas': 'Bananas',
  'Maize': 'Maize',
   'Beans': 'Beans',
  };

  String? get firstName => _firstName;
  set firstName(String? value) {
    _firstName = value;
    notifyListeners();
  }

  String? get lastName => _lastName;
  set lastName(String? value) {
    _lastName = value;
    notifyListeners();
  }

  String? get phoneNumber => _phoneNumber;
  set phoneNumber(String? value) {
    _phoneNumber = value;
    notifyListeners();
  }

  String? get email => _email;
  set email(String? value) {
    _email = value;
    notifyListeners();
  }

   String? get datetime => _datetime;
  set datetime(String? value) {
    _datetime = value;
    notifyListeners();
  }

  String? get description => _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  String? get selectedCategory => _selectedCategory;
  set selectedCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  String? get selectedSubcategory => _selectedSubcategory;
  set selectedSubcategory(String? value) {
    _selectedSubcategory = value;
    notifyListeners();
  }


 String? get createdBy => _createdBy;
  set createdBy(String? value) {
    _createdBy = value;
    notifyListeners();
  }

  String? get image => _image;
  set image(String? value) {
    _image = value;
    notifyListeners();
  }

  String? get participants => _participants;
  set participants(String? value) {
    _participants = value;
    notifyListeners();
  }
  bool? get inSoleBusiness => _inSoleBusiness;
  set inSoleBusiness (bool? value) {
    _inSoleBusiness = value;
    notifyListeners();
  }


    String? get location => _location;
  set location(String? value) {
    _location = value;
    notifyListeners();
  }
  Map<String, List<String>> get subcategories => _subcategories;

  // You don't need a setter for subcategories since it's not mutable outside the class.
}
