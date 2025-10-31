import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/models/registration_fields.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/pages/homePages/job_offers.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/providers/registration_form_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skillhub/utils/category_mappers.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/storage_api.dart';
import 'package:skillhub/appwrite/auth_api.dart';

class AddSkillPage extends StatefulWidget {
  const AddSkillPage({Key? key}) : super(key: key);

  @override
  _AddSkillPageState createState() => _AddSkillPageState();
}

class _AddSkillPageState extends State<AddSkillPage> {
  TextEditingController messageTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  final TextEditingController _datetimeController = TextEditingController();
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController phoneNumberTextController = TextEditingController();
  TextEditingController locationTextController = TextEditingController();
  final TextEditingController _gmaplocationController = TextEditingController();
  final TextEditingController _whatsappLinkController = TextEditingController();
  String? selectedPriceRange;
  final TextEditingController _openingTimesController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _tiktokUrlController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();
  final TextEditingController _discountConditionsController = TextEditingController();
  bool isNegotiable = false;
  bool isAuthenticated = false;
  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  double? latitude;
  double? longitude;

  FilePickerResult? _filePickerResult;
  List<File> _photoGallery = [];
  String productOrService = "Service";
  bool inSoleBusiness = true;
  String userName = "User";
  String userId = "";

@override
void initState() {
  super.initState();
  
  // Check authentication status
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authAPI = Provider.of<AuthAPI>(context, listen: false);
    setState(() {
      isAuthenticated = authAPI.status == AuthStatus.authenticated;
      userName = authAPI.currentUser?.name ?? "User";
      userId = authAPI.userid ?? "";
      isLoading = false;
    });
  });
}

  @override
  void dispose() {
    super.dispose();
    messageTextController.dispose();
    descriptionTextController.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    emailTextController.dispose();
    phoneNumberTextController.dispose();
    locationTextController.dispose();
    _datetimeController.dispose();
    _gmaplocationController.dispose();
    _whatsappLinkController.dispose();
    // Price range is now dropdown, no controller to dispose
    _openingTimesController.dispose();
    _businessNameController.dispose();
    _tiktokUrlController.dispose();
    _websiteUrlController.dispose();
    _discountConditionsController.dispose();
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = result;
    });
  }

  void _openPhotoGalleryPicker() async {
    if (_photoGallery.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 photos allowed')),
      );
      return;
    }
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    
    if (result != null) {
      setState(() {
        // Add selected photos up to max 4
        for (var file in result.files) {
          if (_photoGallery.length < 4 && file.path != null) {
            _photoGallery.add(File(file.path!));
          }
        }
      });
    }
  }

  void _removePhotoFromGallery(int index) {
    setState(() {
      _photoGallery.removeAt(index);
    });
  }

  Future<String?> uploadEventImage() async {
    setState(() {
      isUploading = true;
    });
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        final storageAPI = Provider.of<StorageAPI>(context, listen: false);
        final file = File(_filePickerResult!.files.first.path!);
        // Upload to original bucket where existing images are stored
        final fileId = await storageAPI.uploadFile(file);
        print('Main image uploaded to original bucket: $fileId');
        return fileId;
      } else {
        print("No file selected");
        return null;
      }
    } catch (e) {
      print('Error uploading main image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<List<String>> uploadPhotoGallery() async {
    List<String> photoIds = [];
    try {
      if (_photoGallery.isNotEmpty) {
        final storageAPI = Provider.of<StorageAPI>(context, listen: false);
        
        for (var photo in _photoGallery) {
          // Upload to photos bucket
          final photoId = await storageAPI.uploadFileToPhotosBucket(photo);
          if (photoId != null) {
            photoIds.add(photoId);
          }
        }
      }
      return photoIds;
    } catch (e) {
      print('Error uploading photo gallery: $e');
      return photoIds;
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _datetimeController.text = selectedDateTime.toIso8601String();
          context.read<RegistrationFormProvider>().datetime = selectedDateTime.toIso8601String();
        });
      }
    }
  }

  void _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (result != null) {
      setState(() {
        _gmaplocationController.text = result;
        // Extract the latitude and longitude from the result
        List<String> coordinates = result.split(', ');
        latitude = double.parse(coordinates[0]);
        longitude = double.parse(coordinates[1]);
      });
    }
  }

Future<void> _addSkill(String imageFileId) async {
  final registrationFormProvider = context.read<RegistrationFormProvider>();
  final databaseAPI = context.read<DatabaseAPI>();

  // Convert display names to enum values for storage
  final categoryEnum = CategoryMapper.toEnumValue(registrationFormProvider.selectedCategory!);
  final subcategoryEnum = SubCategoryMapper.toEnumValue(registrationFormProvider.selectedSubcategory!);

  try {
    // Upload photo gallery
    print('Uploading photo gallery...');
    final photoIds = await uploadPhotoGallery();
    print('Photo gallery uploaded: ${photoIds.length} photos');

    // Create RegistrationFields object
    final registrationFields = RegistrationFields(
      firstName: firstNameTextController.text,
      lastName: lastNameTextController.text,
      email: emailTextController.text,
      phoneNumber: phoneNumberTextController.text,
      location: locationTextController.text,
      selectedCategory: categoryEnum,
      selectedSubcategory: subcategoryEnum,
      participants: [],
      createdBy: '${firstNameTextController.text} ${lastNameTextController.text}',
      inSoleBusiness: inSoleBusiness,
      image: imageFileId,
      datetime: DateTime.now().toIso8601String(),
      description: descriptionTextController.text,
    );

    // Add skill to database with new fields
    await databaseAPI.createSkillNew(
      messageTextController.text,
      descriptionTextController.text,
      latitude,
      longitude,
      _gmaplocationController.text,
      _whatsappLinkController.text,
      registrationFields,
      priceRange: selectedPriceRange,
      openingTimes: _openingTimesController.text,
      businessStartDate: _datetimeController.text,
      productOrService: productOrService,
      photos: photoIds,
      businessName: _businessNameController.text.isNotEmpty ? _businessNameController.text : null,
      tiktokUrl: _tiktokUrlController.text.isNotEmpty ? _tiktokUrlController.text : null,
      websiteUrl: _websiteUrlController.text.isNotEmpty ? _websiteUrlController.text : null,
      isNegotiable: isNegotiable,
      discountConditions: isNegotiable && _discountConditionsController.text.isNotEmpty ? _discountConditionsController.text : null,
    );

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill added successfully!')),
      );
      // Navigate back to previous screen
      Navigator.pop(context, true);
    }
  } catch (e) {
    print('Error adding skill: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding skill: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationFormProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Add Your Skill")),
      floatingActionButton: isAuthenticated ? ExpandableFab() : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (isAuthenticated)
                    Column(
                          children: [
                            // Product/Service Selector at the very top
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What are you offering?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: BaseColors().customTheme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.shopping_bag, color: Colors.blue, size: 20),
                                                SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    'Product',
                                                    style: TextStyle(fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: 'Product',
                                            groupValue: productOrService,
                                            onChanged: (value) {
                                              setState(() {
                                                productOrService = value!;
                                              });
                                            },
                                            activeColor: BaseColors().customTheme.primaryColor,
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.work, color: Colors.green, size: 20),
                                                SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    'Service',
                                                    style: TextStyle(fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: 'Service',
                                            groupValue: productOrService,
                                            onChanged: (value) {
                                              setState(() {
                                                productOrService = value!;
                                              });
                                            },
                                            activeColor: BaseColors().customTheme.primaryColor,
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Profile Photo title
                            Text(
                              'Profile Photo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: BaseColors().customTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            
                            // Main image upload
                            GestureDetector(
                              onTap: () => _openFilePicker(),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * .3,
                                decoration: BoxDecoration(
                                    color: BaseColors().kLightGreen,
                                    borderRadius: BorderRadius.circular(8)),
                                child: _filePickerResult != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image(
                                          image: FileImage(
                                              File(_filePickerResult!.files.first.path!)),
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Tap to add main image',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Photo Gallery Upload Section
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Gallery Photos (Max 4)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_photoGallery.length}/4',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    if (_photoGallery.isEmpty)
                                      GestureDetector(
                                        onTap: _openPhotoGalleryPicker,
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.grey[50],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Add Photos',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: [
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                              childAspectRatio: 1,
                                            ),
                                            itemCount: _photoGallery.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.file(
                                                      _photoGallery[index],
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () => _removePhotoFromGallery(index),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        padding: EdgeInsets.all(4),
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          if (_photoGallery.length < 4) ...[
                                            SizedBox(height: 12),
                                            OutlinedButton.icon(
                                              onPressed: _openPhotoGalleryPicker,
                                              icon: Icon(Icons.add),
                                              label: Text('Add More Photos'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: BaseColors().customTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8,),
        DropdownButtonFormField<String>(
  value: provider.selectedCategory,
  decoration: const InputDecoration(
    labelText: 'Category',
    border: OutlineInputBorder(),
  ),
  items: CategoryMapper.displayToEnum.keys.map((String displayName) {
    return DropdownMenuItem<String>(
      value: displayName,
      child: Text(displayName),
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        provider.selectedCategory = value;
        provider.selectedSubcategory = null;
      });
    }
  },
  validator: (value) => value == null ? 'Please select a category' : null,
),
const SizedBox(height: 20),

if (provider.selectedCategory != null)
  DropdownButtonFormField<String>(
    value: provider.selectedSubcategory,
    decoration: const InputDecoration(
      labelText: 'Subcategory',
      prefixIcon: Icon(Icons.subdirectory_arrow_right),
      border: OutlineInputBorder(),
    ),
    items: provider.subcategories[provider.selectedCategory]?.map((String subcategory) {
      final displayName = SubCategoryMapper.toDisplayName(subcategory);
      return DropdownMenuItem<String>(
        value: displayName,
        child: Text(displayName),
      );
    }).toList() ?? [],
    onChanged: (value) {
      if (value != null) {
        setState(() {
          provider.selectedSubcategory = value;
        });
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a subcategory';
      }
      return null;
    },
  ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _businessNameController,
                              decoration: const InputDecoration(
                                labelText: 'Business Name (Optional)',
                                hintText: 'e.g., Frank\'s Electronics',
                                prefixIcon: Icon(Icons.business),
                              ),
                              // No validator - this field is optional
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: firstNameTextController,
                              decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.people_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                provider.firstName = value;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: lastNameTextController,
                              decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.people_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                provider.lastName = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: emailTextController,
                              decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                final emailRegex = RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                provider.email = value;
                              },
                            ),
                            const SizedBox(height: 8),
                            IntlPhoneField(
                              controller: phoneNumberTextController,
                              decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone)),
                              initialCountryCode: 'UG',
                              onChanged: (phone) {
                                // Handle East African phone numbers (UG, KE, RW, TZ)
                                String phoneNumber = phone.number;
                                String countryCode = phone.countryCode;
                                
                                // For East African countries, ensure 8 digits
                                if (['256', '254', '250', '255'].contains(countryCode)) {
                                  // Remove leading 0 if phone has 9 digits
                                  if (phoneNumber.length == 9 && phoneNumber.startsWith('0')) {
                                    phoneNumber = phoneNumber.substring(1);
                                  }
                                }
                                
                                // Store complete number with country code
                                String completeNumber = '+$countryCode$phoneNumber';
                                provider.phoneNumber = completeNumber;
                                phoneNumberTextController.text = phoneNumber;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: messageTextController,
                              decoration: const InputDecoration(
                                hintText: 'Type a Skill Bio',
                                prefixIcon: Icon(Icons.event_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Type your Message';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              maxLines: 4,
                              controller: descriptionTextController,
                              decoration: const InputDecoration(
                                hintText: 'Type a Business Description',
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Type a Short Business Or Skill Description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                             controller: locationTextController,
                              decoration: const InputDecoration(
                                  labelText: 'Physical Location',
                                  prefixIcon: Icon(Icons.location_on)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Physical location';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                provider.location = value;
                              },
                            ),
                            GestureDetector(
                              onTap: _openMapScreen,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _gmaplocationController,
                                  decoration: InputDecoration(labelText: 'Google Map Location', prefixIcon: Icon(Icons.location_on)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a Google Map location';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _datetimeController,
                              decoration: const InputDecoration(
                                labelText: 'Business Start Date',
                                hintText: 'When did you start this business/service?',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business start date';
                                }
                                return null;
                              },
                              onTap: () {
                                _selectDateTime(context);
                              },
                              readOnly: true,
                            ),
                                           SizedBox(height: 20),
                              TextFormField(
                controller: _whatsappLinkController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp Business Link',
                  hintText: 'wa.me/256712345678 or https://wa.me/256712345678',
                  helperText: 'Enter your WhatsApp business link',
                  prefixIcon: Icon(Icons.chat),
                ),
                onChanged: (value) {
                  // Auto-format WhatsApp link
                  if (value.isNotEmpty) {
                    String formattedLink = value.trim();
                    // Add https:// if not present
                    if (!formattedLink.startsWith('http://') && !formattedLink.startsWith('https://')) {
                      formattedLink = 'https://$formattedLink';
                    }
                    // Store formatted link
                    if (formattedLink != value) {
                      _whatsappLinkController.value = TextEditingValue(
                        text: formattedLink,
                        selection: TextSelection.collapsed(offset: formattedLink.length),
                      );
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your WhatsApp Business link';
                  }
                  if (!value.contains('wa.me') && !value.contains('whatsapp.com')) {
                    return 'Please enter a valid WhatsApp link (wa.me/...)';
                  }
                  return null;
                },
              ),
                            const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedPriceRange,
                decoration: InputDecoration(
                  labelText: 'Price Range (Ug Shs)',
                  helperText: 'Select the price range for your service/product',
                  prefixIcon: Icon(Icons.payments),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Below 50,000', child: Text('Below Ug Shs 50,000')),
                  DropdownMenuItem(value: '50,000 - 100,000', child: Text('Ug Shs 50,000 - 100,000')),
                  DropdownMenuItem(value: '100,000 - 200,000', child: Text('Ug Shs 100,000 - 200,000')),
                  DropdownMenuItem(value: '200,000 - 500,000', child: Text('Ug Shs 200,000 - 500,000')),
                  DropdownMenuItem(value: '500,000 - 1,000,000', child: Text('Ug Shs 500,000 - 1M')),
                  DropdownMenuItem(value: '1,000,000 - 5,000,000', child: Text('Ug Shs 1M - 5M')),
                  DropdownMenuItem(value: 'Above 5,000,000', child: Text('Above Ug Shs 5M')),
                  DropdownMenuItem(value: 'Negotiable', child: Text('Negotiable')),
                  DropdownMenuItem(value: 'Free', child: Text('Free')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriceRange = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a price range';
                  }
                  return null;
                },
              ),
                            const SizedBox(height: 20),
              TextFormField(
                controller: _openingTimesController,
                decoration: InputDecoration(
                  labelText: 'Business Hours',
                  hintText: 'e.g., Mon-Fri: 8AM-6PM, Sat: 9AM-5PM',
                  helperText: 'When are you available for business?',
                  suffixIcon: Icon(Icons.access_time),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business hours';
                  }
                  return null;
                },
              ),
                            const SizedBox(height: 20),
              // TikTok URL (Optional)
              TextFormField(
                controller: _tiktokUrlController,
                decoration: InputDecoration(
                  labelText: 'TikTok URL (Optional)',
                  hintText: 'e.g., https://www.tiktok.com/@yourhandle',
                  prefixIcon: Icon(Icons.video_library),
                ),
              ),
                            const SizedBox(height: 20),
              // Website URL (Optional)
              TextFormField(
                controller: _websiteUrlController,
                decoration: InputDecoration(
                  labelText: 'Website URL (Optional)',
                  hintText: 'e.g., https://www.yourwebsite.com',
                  prefixIcon: Icon(Icons.language),
                ),
              ),
                            const SizedBox(height: 20),
              // Negotiation/Discount Toggle
              Row(
                children: [
                  Icon(Icons.local_offer, color: BaseColors().customTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Open to Negotiation/Discount",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: isNegotiable,
                    onChanged: (value) {
                      setState(() {
                        isNegotiable = value;
                      });
                    },
                    activeColor: BaseColors().customTheme.primaryColor,
                  ),
                ],
              ),
              if (isNegotiable) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _discountConditionsController,
                  decoration: InputDecoration(
                    labelText: 'Discount/Negotiation Conditions',
                    hintText: 'e.g., 10% off for bulk orders, negotiable for long-term contracts',
                    helperText: 'Describe your discount or negotiation terms',
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (isNegotiable && (value == null || value.isEmpty)) {
                      return 'Please describe your discount/negotiation conditions';
                    }
                    return null;
                  },
                ),
              ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text("In a Sole Business", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                                Spacer(),
                                Switch(value: inSoleBusiness, onChanged: (value) {
                                  setState(() {
                                    inSoleBusiness = value;
                                  });
                                  provider.inSoleBusiness = value;
                                }),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isUploading ? null : () async {
                                if (_formKey.currentState!.validate()) {
                                  // Check if user is authenticated
                                  final authAPI = Provider.of<AuthAPI>(context, listen: false);
                                  if (authAPI.status != AuthStatus.authenticated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please login to add a skill')),
                                    );
                                    return;
                                  }

                                  String? imageFileId;
                                  if (_filePickerResult != null) {
                                    imageFileId = await uploadEventImage();
                                    if (imageFileId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Image upload failed")),
                                      );
                                      return;
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please select an image")),
                                    );
                                    return;
                                  }
                                  
                                  await _addSkill(imageFileId);
                                }
                              },
                              child: isUploading 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Add Skill'),
                            ),
                          ],
                        )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Please login to add a skill',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'You need to be authenticated to create skills',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back),
                            label: Text('Go Back'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Location gmaplocation = Location(); // Create a Location instance
  Set<Marker> markers = {};
  LatLng? userLatLng; // Store user's location coordinates
  bool isLoading = true;

  bool _showCopyText = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _toggleCopyText();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (userLatLng != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng!, 14.0));
    }
  }

  Future<void> _getUserLocation() async {
    final userLocation = await gmaplocation.getLocation();
    userLatLng = LatLng(userLocation.latitude!, userLocation.longitude!);
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: userLatLng!,
        infoWindow: InfoWindow(title: 'Your Location'),
      ));
      isLoading = false;
    });
    if (mapController != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng!, 14.0));
    }
  }

  void _onMapTapped(LatLng tappedPoint) async {
    String? locationName = await _showDialog(context);
    if (locationName != null && locationName.isNotEmpty) {
      setState(() {
        markers.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: InfoWindow(title: locationName),
        ));
      });
      _copyCoordinatesToClipboard(tappedPoint);
    }
  }

  Future<String?> _showDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Location Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Location Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _copyCoordinatesToClipboard(LatLng latLng) {
    String coordinates = '${latLng.latitude}, ${latLng.longitude}';
    Clipboard.setData(ClipboardData(text: coordinates));
    Navigator.pop(context, coordinates);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coordinates copied to clipboard')),
    );
  }

  void _toggleCopyText() {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showCopyText = !_showCopyText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: userLatLng ?? LatLng(0, 0), // Default to user's location if available
                    zoom: 14.0,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  onTap: _onMapTapped,
                ),
                Positioned(
                  right: 16.0,
                  top: MediaQuery.of(context).size.height / 2 - 28.0,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        width: _showCopyText ? 145 : 0,
                        height: 40,
                        padding: EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Text(
                              'Copy Pin Point',
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.arrow_downward, color: Colors.white),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(137, 145, 11, 172),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: () {
                          if (userLatLng != null) {
                            _copyCoordinatesToClipboard(userLatLng!);
                          }
                        },
                        tooltip: 'Copy Coordinates',
                        child: Icon(Icons.copy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
