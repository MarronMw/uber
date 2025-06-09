import 'package:google_maps_flutter/google_maps_flutter.dart';

//NEW
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ensure dotenv is correctly configured for your API key
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'dart:async'; // Import for Timer

class EnterLocationPage extends StatefulWidget {
  const EnterLocationPage({super.key});

  @override
  _EnterLocationPageState createState() => _EnterLocationPageState();
}

class _EnterLocationPageState extends State<EnterLocationPage> {
  LatLng? currentPosition;
  GoogleMapController? mapController;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  Timer? _debounce; // For debouncing the search input

  @override
  void initState() {
    super.initState();
    // It's generally better to load dotenv earlier, e.g., in main.dart
    // await dotenv.load(fileName: ".env");
    _initGooglePlace();
    _determinePosition();
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel any active debounce timer
    searchController.dispose(); // Dispose the TextEditingController
    mapController?.dispose(); // Dispose the map controller if you hold it
    super.dispose();
  }

  void _initGooglePlace() {
    // It's recommended to load API keys securely, e.g., from .env file
    // final apiKey = dotenv.env['Maps_API_KEY'];
    final apiKey =
        "myAPI_KEY"; // Replace with your actual API key loaded securely
    if (apiKey == null || apiKey.isEmpty) {
      print(
        "Error: Google Maps API key not found. Please add it to your .env file.",
      );
      // Potentially show an error message to the user or handle gracefully
      return;
    }
    googlePlace = GooglePlace(apiKey);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Consider showing a SnackBar or AlertDialog to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Consider showing a SnackBar or AlertDialog to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permissions denied. Cannot get current location.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // You can adjust accuracy
      );
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
      // If mapController is already initialized, animate to current position
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(currentPosition!));
      }
    } catch (e) {
      print("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void autoCompleteSearch(String value) {
    // Cancel the previous debounce timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        try {
          var result = await googlePlace.autocomplete.get(value);
          if (result != null && result.predictions != null && mounted) {
            setState(() {
              predictions = result.predictions!;
            });
          }
        } catch (e) {
          print("Autocomplete API error: $e");
          // Optionally, show a user-friendly error message
        }
      } else {
        setState(() {
          predictions = [];
        });
      }
    });
  }

  void selectPrediction(AutocompletePrediction prediction) async {
    // Clear the search predictions immediately upon selection
    setState(() {
      predictions = [];
    });

    try {
      var details = await googlePlace.details.get(prediction.placeId!);
      if (details != null &&
          details.result != null &&
          details.result!.geometry != null) {
        final loc = details.result!.geometry!.location!;
        final LatLng pos = LatLng(loc.lat!, loc.lng!);

        // Ensure mapController is not null before animating
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(pos, 15),
          ); // Add zoom level
        }

        setState(() {
          currentPosition = pos;
          searchController.text = prediction.description!;
        });
      }
    } catch (e) {
      print("Place details API error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get place details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          currentPosition == null
              ? Center(child: CircularProgressIndicator(color: Colors.red))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentPosition!,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  mapController = controller;
                },
                // Consider adding a marker at the currentPosition or selected location
                markers:
                    currentPosition != null
                        ? {
                          Marker(
                            markerId: MarkerId('selected_location'),
                            position: currentPosition!,
                            infoWindow: InfoWindow(
                              title:
                                  searchController.text.isNotEmpty
                                      ? searchController.text
                                      : 'Selected Location',
                            ),
                          ),
                        }
                        : {},
              ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      controller: searchController,
                      onChanged: autoCompleteSearch, // Debounced here
                      decoration: InputDecoration(
                        hintText: 'Where from?',
                        prefixIcon: Icon(Icons.search, color: Colors.red),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  if (predictions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(predictions[index].description ?? ""),
                            onTap: () => selectPrediction(predictions[index]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (currentPosition != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Location sent: ${currentPosition!.latitude}, ${currentPosition!.longitude}',
                  ),
                  backgroundColor: Colors.yellow,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              // Here you would typically pass the currentPosition back
              // to the previous screen using Navigator.pop(context, currentPosition);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a location first.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Send Location',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
