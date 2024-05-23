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
    'Engineering': ['Civil Engineering', 'Mechanical', 'Electrical'],
    'IT': ['Software Engineering', 'Data Science', 'AI'],
    'Design': ['Graphic Design', 'Illustration', 'Animation'],
    'Medicine': ['General Medicine', 'Pediatrics', 'Cardiology'],
  };

  // Define mapping between user-friendly display names and Enum values
  Map<String, String> subcategoryEnumMapping = {
    'Graphic Design': 'GraphicDesign',
    'Illustration': 'Illustration',
    'Animation': 'Animation',
    'General Medicine': 'GeneralMedicine',
    'Pediatrics': 'Pediatrics',
    'Cardiology': 'Cardiology',
    'AI': 'AI',
    'Software Engineering': 'Software',
    'Civil Engineering': 'Civil',
    'Data Science': 'DataScience',
    'Electrical Engineering': 'Electrical',
    'Mechanical': 'Mechanical',
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
