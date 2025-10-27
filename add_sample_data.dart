import 'dart:io';
import 'package:appwrite/appwrite.dart';

void main() async {
  // Initialize Appwrite client
  final client = Client()
      .setEndpoint('https://skillhub.avodahsystems.com/v1')
      .setProject('68fbf8c7000da2a66231')
      .setKey('standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401'); // API Secret

  final databases = Databases(client);

  // Sample data
  final sampleSkills = [
    {
      'text': 'Expert Flutter Developer with 5+ years experience',
      'description': 'I specialize in building beautiful, performant mobile applications using Flutter. I have extensive experience with state management, API integration, and creating responsive UI designs.',
      'firstName': 'John',
      'lastName': 'Doe',
      'phoneNumber': '+256701234567',
      'location': 'Kampala, Uganda',
      'email': 'john.doe@example.com',
      'selectedCategory': 'IT',
      'selectedSubcategory': 'Mobile Development',
      'participants': [],
      'createdBy': 'John Doe',
      'inSoleBusiness': true,
      'image': 'default_image',
      'gmaplocation': '0.3476,32.5825',
      'lat': 0.3476,
      'long': 32.5825,
      'link': 'https://wa.me/256701234567',
      'datetime': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'user_id': 'sample_user_1',
    },
    {
      'text': 'Professional Graphic Designer - Logo & Branding',
      'description': 'Creative graphic designer specializing in logo design, brand identity, and marketing materials. I help businesses establish a strong visual presence.',
      'firstName': 'Sarah',
      'lastName': 'Johnson',
      'phoneNumber': '+256702345678',
      'location': 'Nairobi, Kenya',
      'email': 'sarah.design@example.com',
      'selectedCategory': 'Design',
      'selectedSubcategory': 'Graphic Design',
      'participants': [],
      'createdBy': 'Sarah Johnson',
      'inSoleBusiness': false,
      'image': 'default_image',
      'gmaplocation': '-1.2864,36.8172',
      'lat': -1.2864,
      'long': 36.8172,
      'link': 'https://wa.me/256702345678',
      'datetime': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'user_id': 'sample_user_2',
    },
    {
      'text': 'Certified Civil Engineer - Construction & Project Management',
      'description': 'Licensed civil engineer with expertise in construction project management, structural design, and infrastructure development.',
      'firstName': 'Michael',
      'lastName': 'Brown',
      'phoneNumber': '+256703456789',
      'location': 'Dar es Salaam, Tanzania',
      'email': 'michael.engineer@example.com',
      'selectedCategory': 'Engineering',
      'selectedSubcategory': 'Civil',
      'participants': [],
      'createdBy': 'Michael Brown',
      'inSoleBusiness': true,
      'image': 'default_image',
      'gmaplocation': '-6.7924,39.2083',
      'lat': -6.7924,
      'long': 39.2083,
      'link': 'https://wa.me/256703456789',
      'datetime': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      'user_id': 'sample_user_3',
    },
    {
      'text': 'Beauty Therapist & Hair Stylist - Salon Services',
      'description': 'Professional beauty therapist offering hair styling, makeup, manicure/pedicure, and skincare treatments in a relaxing salon environment.',
      'firstName': 'Emma',
      'lastName': 'Wilson',
      'phoneNumber': '+256704567890',
      'location': 'Kigali, Rwanda',
      'email': 'emma.beauty@example.com',
      'selectedCategory': 'Health & Beauty',
      'selectedSubcategory': 'Beauty Therapy',
      'participants': [],
      'createdBy': 'Emma Wilson',
      'inSoleBusiness': false,
      'image': 'default_image',
      'gmaplocation': '-1.9706,30.1044',
      'lat': -1.9706,
      'long': 30.1044,
      'link': 'https://wa.me/256704567890',
      'datetime': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      'user_id': 'sample_user_4',
    },
    {
      'text': 'Full-Stack Web Developer - MERN Stack Expert',
      'description': 'Experienced full-stack developer specializing in MongoDB, Express.js, React.js, and Node.js. I build scalable web applications and APIs.',
      'firstName': 'David',
      'lastName': 'Lee',
      'phoneNumber': '+256705678901',
      'location': 'Lagos, Nigeria',
      'email': 'david.web@example.com',
      'selectedCategory': 'IT',
      'selectedSubcategory': 'Web Development',
      'participants': [],
      'createdBy': 'David Lee',
      'inSoleBusiness': true,
      'image': 'default_image',
      'gmaplocation': '6.5244,3.3792',
      'lat': 6.5244,
      'long': 3.3792,
      'link': 'https://wa.me/256705678901',
      'datetime': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'user_id': 'sample_user_5',
    },
    {
      'text': 'Fashion Designer - Custom Clothing & Tailoring',
      'description': 'Creative fashion designer specializing in custom clothing, wedding dresses, and traditional attire. I bring your fashion dreams to life.',
      'firstName': 'Grace',
      'lastName': 'Okafor',
      'phoneNumber': '+256706789012',
      'location': 'Accra, Ghana',
      'email': 'grace.fashion@example.com',
      'selectedCategory': 'Fashion',
      'selectedSubcategory': 'Fashion Design',
      'participants': [],
      'createdBy': 'Grace Okafor',
      'inSoleBusiness': false,
      'image': 'default_image',
      'gmaplocation': '5.6037,-0.1870',
      'lat': 5.6037,
      'long': -0.1870,
      'link': 'https://wa.me/256706789012',
      'datetime': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
      'user_id': 'sample_user_6',
    },
    {
      'text': 'Medicine Doctor - General Practitioner',
      'description': 'Licensed medical doctor providing general healthcare services, consultations, and medical advice. Committed to patient care and wellness.',
      'firstName': 'Dr. James',
      'lastName': 'Smith',
      'phoneNumber': '+256707890123',
      'location': 'Addis Ababa, Ethiopia',
      'email': 'dr.smith@example.com',
      'selectedCategory': 'Medicine',
      'selectedSubcategory': 'General Practice',
      'participants': [],
      'createdBy': 'Dr. James Smith',
      'inSoleBusiness': true,
      'image': 'default_image',
      'gmaplocation': '9.1450,38.7379',
      'lat': 9.1450,
      'long': 38.7379,
      'link': 'https://wa.me/256707890123',
      'datetime': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
      'user_id': 'sample_user_7',
    },
    {
      'text': 'Agriculture Consultant - Crop Farming & Livestock',
      'description': 'Agricultural expert providing consulting services for crop farming, livestock management, and sustainable farming practices.',
      'firstName': 'Peter',
      'lastName': 'Nkosi',
      'phoneNumber': '+256708901234',
      'location': 'Harare, Zimbabwe',
      'email': 'peter.agri@example.com',
      'selectedCategory': 'Farming & Agriculture',
      'selectedSubcategory': 'Crop Farming',
      'participants': [],
      'createdBy': 'Peter Nkosi',
      'inSoleBusiness': true,
      'image': 'default_image',
      'gmaplocation': '-17.8252,31.0335',
      'lat': -17.8252,
      'long': 31.0335,
      'link': 'https://wa.me/256708901234',
      'datetime': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
      'user_id': 'sample_user_8',
    },
  ];

  try {
    print('Starting to add sample data to Appwrite database...');

    for (var i = 0; i < sampleSkills.length; i++) {
      final skill = sampleSkills[i];
      print('Adding skill ${i + 1}/${sampleSkills.length}: ${skill['firstName']} ${skill['lastName']}');

      await databases.createDocument(
        databaseId: '68fbfa9400035f96086e', // userData database ID
        collectionId: '68fbfb01002ca99ab18e', // Skills Collection ID
        documentId: ID.unique(),
        data: skill,
      );

      print('✅ Skill ${i + 1} added successfully');
    }

    print('🎉 All sample data added successfully!');
    print('You can now test the app and see sample skills when clicking on subcategories.');

  } catch (e) {
    print('❌ Error adding sample data: $e');
  }
}
