class RegistrationFields {
  String firstName;
  String lastName;
  String phoneNumber;
  String email;
  String datetime;
  String description;
  String selectedCategory;
  String selectedSubcategory;
  String location;
  List<dynamic> participants;
  String createdBy;
  bool inSoleBusiness;
  String image;

  RegistrationFields({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.datetime,
    required this.description,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.location,
    required this.image,
    required this.participants,
    required this.createdBy,
    required this.inSoleBusiness,
  });

  Map<String, dynamic> toJson(RegistrationFields registrationFields) {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'datetime': datetime,
      'description': description,
      'selectedCategory': selectedCategory,
      'selectedSubcategory': selectedSubcategory,
      'participants': participants,
      'location': location,
      'createdBy': createdBy,
      'InSoleBusiness': inSoleBusiness,
      'image': image,
    };
  }
}
