import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/colors.dart';
import 'package:skillhub/models/registration_fields.dart';
import 'package:skillhub/pages/Staggered/job_offers.dart';
import 'package:skillhub/pages/homePages/job_offers.dart';
import 'package:skillhub/pages/nav_tabs/expendableFab.dart';
import 'package:skillhub/providers/registration_form_providers.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({Key? key}) : super(key: key);

  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  late Client client;
  late DatabaseAPI database;
  late Storage storage;
  TextEditingController messageTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  final TextEditingController _datetimeController = TextEditingController();
  final TextEditingController _gmaplocationController = TextEditingController();
   final TextEditingController _whatsappLinkController = TextEditingController();
  AuthStatus authStatus = AuthStatus.uninitialized;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  late String selectedCategory;
  late String selectedSubcategory;
  
//late String? _whatsappLink;

  FilePickerResult? _filePickerResult;
  bool _isSoleBusiness = true;
  String userName = "User";
  late AuthAPI auth;
  String userId = "";
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    final AuthAPI appwrite = context.read<AuthAPI>();
    authStatus = appwrite.status;
    userName = SavedData.getUserName().split(" ")[0];
    userId = SavedData.getUserId();
    auth = appwrite;
    client = appwrite.client;
    storage = Storage(client);
    database = DatabaseAPI(auth: auth);
     // _whatsappLink = database.getWhatsappLink() as String?;
  }

  @override
  void dispose() {
    super.dispose();
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
        PlatformFile file = _filePickerResult!.files.first;
        final fileBytes = await File(file.path!).readAsBytes();
        final inputFile = InputFile.fromBytes(bytes: fileBytes, filename: file.name);

        final response = await storage.createFile(
          bucketId: '665a5bb500243dbb9967',
          fileId: ID.unique(),
          file: inputFile,
        );
        print(response.$id);
        return response.$id; // Return the file ID or URL as provided by the storage service
      } else {
        print("Something went wrong");
        return null;
      }
    } catch (e) {
      print(e);
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

  showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
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

  void uploadEventImageAndCreateSkill() {
    uploadEventImage().then((value) {
      if (value != null) {
        database.createSkill(
          message: messageTextController.text,
          description: descriptionTextController.text,
          gmaplocation: _gmaplocationController.text,
          whatsappLinkController: _whatsappLinkController.text,
         
          registrationFields: RegistrationFields(
            selectedCategory: context.read<RegistrationFormProvider>().selectedCategory!,
            selectedSubcategory: context.read<RegistrationFormProvider>().selectedSubcategory!,
            firstName: context.read<RegistrationFormProvider>().firstName!,
            lastName: context.read<RegistrationFormProvider>().lastName!,
            phoneNumber: context.read<RegistrationFormProvider>().phoneNumber!,
            email: context.read<RegistrationFormProvider>().email!,
            description: descriptionTextController.text,
            createdBy: userId,
            datetime: context.read<RegistrationFormProvider>().datetime!,
            location: context.read<RegistrationFormProvider>().location!,
            participants: [],
            inSoleBusiness: _isSoleBusiness,
            image: value, // Assign the uploaded file ID or URL to the registrationFields
          ),
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        ).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Skill Created !!")),
          );
          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Business Skill Added'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobOffersStaggeredPage(title: ''),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed")),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationFormProvider>(context);
    return Scaffold(
      floatingActionButton: ExpandableFab(),
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
                  authStatus == AuthStatus.authenticated
                      ? Column(
                          children: [
                            GestureDetector(
                              onTap: () => _openFilePicker(),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * .3,
                                decoration: BoxDecoration(
                                  color: BaseColors().kLightGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _filePickerResult != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image(
                                          image: FileImage(File(_filePickerResult!.files.first.path!)),
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 42,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "Upload Logo Or Biz Image",
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: provider.selectedCategory,
                              hint: const Text('Select Category'),
                              onChanged: (value) {
                                provider.selectedCategory = value;
                                provider.selectedSubcategory = null;
                              },
                              items: provider.subcategories.keys.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            if (provider.selectedCategory != null)
                              DropdownButtonFormField<String>(
                                value: provider.selectedSubcategory,
                                hint: const Text('Select Subcategory'),
                                onChanged: (value) {
                                  provider.selectedSubcategory = value;
                                },
                                items: provider.selectedCategory != null
                                    ? provider.subcategories[provider.selectedCategory!]!.map((String subcategory) {
                                        return DropdownMenuItem<String>(
                                          value: subcategory,
                                          child: Text(subcategory),
                                        );
                                      }).toList()
                                    : [],
                              ),
                            TextFormField(
                              initialValue: userName,
                              decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.people_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<RegistrationFormProvider>().firstName = value;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.people_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<RegistrationFormProvider>().lastName = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Email',  prefixIcon: Icon(Icons.email_outlined),),
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
                                context.read<RegistrationFormProvider>().email = value;
                              },
                            ),
                            const SizedBox(height: 8),
                            IntlPhoneField(
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_rounded),
                                border: OutlineInputBorder(),
                              ),
                              initialCountryCode: 'UG',
                              onChanged: (phone) {
                                context.read<RegistrationFormProvider>().phoneNumber = phone.completeNumber;
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
                              decoration: const InputDecoration(
                                labelText: 'Physical Location',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Physical Location';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<RegistrationFormProvider>().location = value;
                              },
                            ),
                            GestureDetector(
                              onTap: _openMapScreen,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _gmaplocationController,
                                  decoration: InputDecoration(labelText: 'Google Map Precise Location',  prefixIcon: Icon(Icons.location_on_outlined),),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a Gmap location';
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
                                Text("In a Sole Business",
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                                Spacer(),
                                Switch(
                                  value: _isSoleBusiness,
                                  onChanged: (value) {
                                    setState(() {
                                      _isSoleBusiness = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final registrationFormProvider = context.read<RegistrationFormProvider>();
                                if (registrationFormProvider.firstName!.isEmpty ||
                                    registrationFormProvider.lastName!.isEmpty ||
                                    registrationFormProvider.phoneNumber!.isEmpty ||
                                    registrationFormProvider.email!.isEmpty ||
                                    registrationFormProvider.selectedCategory!.isEmpty ||
                                    registrationFormProvider.selectedSubcategory!.isEmpty ||
                                    descriptionTextController.text.isEmpty ||
                                    registrationFormProvider.datetime!.isEmpty ||
                                    registrationFormProvider.location!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "First Name, Last Name, Phone Number, Email, Category, Subcategory, Description, Date & Time, and Location are required."),
                                    ),
                                  );
                                } else if (_formKey.currentState!.validate()) {
                                  uploadEventImageAndCreateSkill();
                                }
                              },
                              child: const Text('Submit'),
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