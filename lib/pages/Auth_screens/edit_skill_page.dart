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

class EditSkillsPage extends StatefulWidget {
  final String image, firstName, lastName, email, phoneNumber, message, selectedCategory, selectedSubcategory, location, description, datetime, docID,link, gmaplocation;
  final bool inSoleBusiness;
  const EditSkillsPage({Key? key, required this.image, required this.gmaplocation, required this.link, required this.firstName, required this.lastName, required this.email, required this.phoneNumber, required this.message, required this.selectedCategory, required this.selectedSubcategory, required this.description, required this.datetime, required this.docID, required this.inSoleBusiness, required this.location}) : super(key: key);

  @override
  _EditSkillsPageState createState() => _EditSkillsPageState();
}

class _EditSkillsPageState extends State<EditSkillsPage> {
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
  bool isAuthenticated = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  late String selectedCategory;
  late String selectedSubcategory;
  late String firstName;
  late String lastName;
  late String email;
  late String phoneNumber;
  late String location;
  late bool docID;
  double? latitude;
  double? longitude;

  FilePickerResult? _filePickerResult;
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
    });
  });

  _datetimeController.text = widget.datetime;
  messageTextController.text = widget.message;
  descriptionTextController.text = widget.description;
  firstNameTextController.text = widget.firstName;
  lastNameTextController.text = widget.lastName;
  emailTextController.text = widget.email;
  phoneNumberTextController.text = widget.phoneNumber;
  locationTextController.text = widget.location;
  _gmaplocationController.text = widget.gmaplocation;
  _whatsappLinkController.text = widget.link;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<RegistrationFormProvider>(context, listen: false);
    // Convert from stored enum value to display name
    provider.selectedCategory = CategoryMapper.toDisplayName(widget.selectedCategory);
    provider.selectedSubcategory = SubCategoryMapper.toDisplayName(widget.selectedSubcategory);
    provider.inSoleBusiness = widget.inSoleBusiness;
    provider.firstName = widget.firstName;
    provider.lastName = widget.lastName;
    provider.email = widget.email;
    provider.phoneNumber = widget.phoneNumber;
    provider.location = widget.location;
    provider.image = widget.image;
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
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = result;
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
        final fileId = await storageAPI.uploadFile(file);
        return fileId;
      } else {
        print("No file selected");
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
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

Future<void> _updateSkill(String imageFileId) async {
  final registrationFormProvider = context.read<RegistrationFormProvider>();
  final databaseAPI = context.read<DatabaseAPI>();

  // Convert display names to enum values for storage
  final categoryEnum = CategoryMapper.toEnumValue(registrationFormProvider.selectedCategory!);
  final subcategoryEnum = SubCategoryMapper.toEnumValue(registrationFormProvider.selectedSubcategory!);

  try {
    // Create RegistrationFields object
    final registrationFields = RegistrationFields(
      firstName: firstNameTextController.text,
      lastName: lastNameTextController.text,
      email: emailTextController.text,
      phoneNumber: phoneNumberTextController.text,
      location: locationTextController.text,
      selectedCategory: categoryEnum,
      selectedSubcategory: subcategoryEnum,
      participants: widget.inSoleBusiness ? [] : (widget.message as List? ?? []),
      createdBy: '${firstNameTextController.text} ${lastNameTextController.text}',
      inSoleBusiness: inSoleBusiness,
      image: imageFileId,
      datetime: widget.datetime,
      description: descriptionTextController.text,
    );

    // Update skill in database
    await databaseAPI.updateSkill(
      messageTextController.text,
      descriptionTextController.text,
      latitude,
      longitude,
      _gmaplocationController.text,
      _whatsappLinkController.text,
      registrationFields,
      widget.docID,
    );

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill updated successfully!')),
      );
      Navigator.pop(context, true);
    }
  } catch (e) {
    print('Error updating skill: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating skill: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationFormProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Update Skills")),
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
                  isAuthenticated
                      ? Column(
                          children: [
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
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          "https://skillhub.avodahsystems.com/v1/storage/buckets/665a5bb500243dbb9967/files/${widget.image}/view?project=665a50350038457d0eb9",
                                          fit: BoxFit.fill,
                                        ),
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
                                provider.phoneNumber = phone.completeNumber;
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
                                labelText: 'Date Of Birth',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter DOB';
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
                decoration: InputDecoration(labelText: 'WhatsApp Catalogue Link'), // WhatsApp link input field
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your WhatsApp Catalogue link';
                  }
                  return null;
                },
              ),
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
                                  String imageFileId = widget.image;
                                  
                                  // If user selected a new image, upload it
                                  if (_filePickerResult != null) {
                                    final newImageId = await uploadEventImage();
                                    if (newImageId != null) {
                                      imageFileId = newImageId;
                                      // Delete old image if it exists and is not default
                                      if (widget.image.isNotEmpty && widget.image != 'default_image') {
                                        final storageAPI = Provider.of<StorageAPI>(context, listen: false);
                                        await storageAPI.deleteFile(widget.image);
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Image upload failed")),
                                      );
                                      return;
                                    }
                                  }
                                  
                                  await _updateSkill(imageFileId);
                                }
                              },
                              child: isUploading 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Update Skill'),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Danger Zone",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 243, 138, 136),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20),
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: MaterialButton(
                                color: Color.fromARGB(255, 243, 138, 136),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          "Are you Sure ?",
                                          style: TextStyle(color: Color.fromARGB(255, 131, 84, 175)),
                                        ),
                                        content: Text(
                                          "Your skill will be deleted",
                                          style: TextStyle(color: BaseColors().baseTextColor),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                try {
                                                  final databaseAPI = context.read<DatabaseAPI>();
                                                  final storageAPI = context.read<StorageAPI>();
                                                  
                                                  // Delete skill from database
                                                  await databaseAPI.deleteSkill(widget.docID);
                                                  
                                                  // Delete image from storage if it exists
                                                  if (widget.image.isNotEmpty && widget.image != 'default_image') {
                                                    await storageAPI.deleteFile(widget.image);
                                                  }
                                                  
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Skill Deleted Successfully.")),
                                                    );
                                                    Navigator.pop(context); // Close dialog
                                                    Navigator.pop(context, true); // Go back with refresh flag
                                                  }
                                                } catch (e) {
                                                  print('Error deleting skill: $e');
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Error deleting skill: $e')),
                                                    );
                                                    Navigator.pop(context);
                                                  }
                                                }
                                              },
                                              child: Text("Yes")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No")),
                                        ],
                                      ));
                                },
                                child: Text(
                                  "Delete Skill",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(),
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