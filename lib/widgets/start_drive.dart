import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';

class StartDriveMap extends StatefulWidget {
  final String eventId;

  const StartDriveMap({super.key, required this.eventId});

  @override
  State<StartDriveMap> createState() => _StartDriveMapState();
}

class _StartDriveMapState extends State<StartDriveMap> {
  late GoogleMapController mapController;
  Marker? startMarker;
  Marker? userMarker;
  Marker? endMarker;
  late Polyline routePolyline;
  List<LatLng> routePoints = [];
  IO.Socket? socket; // Made nullable to handle initialization errors
  bool isDriveEnded = false;
  bool isLoading = true;
  String error = '';
  double totalDistance = 0;
  int driveDuration = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Use Geolocator's permission handling directly

    routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: Colors.blue,
      width: 5,
    );
  }

  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      setState(() {
        error =
            'Location services are disabled. Please enable location services in your device settings.';
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        setState(() {
          error =
              'Location permissions are denied. Please allow access to your location.';
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      setState(() {
        error =
            'Location permissions are permanently denied. Please enable them in app settings.';
        isLoading = false;
      });
      return;
    }

    // When we reach here, permissions are granted
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _handleLocationObtained(position);
    } catch (e) {
      setState(() {
        error = 'Error getting location: $e';
        isLoading = false;
      });
    }
  }

  void _handleLocationObtained(Position position) {
    final LatLng currentLocation =
        LatLng(position.latitude, position.longitude);

    if (mounted) {
      setState(() {
        // Initialize start marker at current location
        startMarker = Marker(
          markerId: const MarkerId('start'),
          position: currentLocation,
          infoWindow: const InfoWindow(title: 'Start'),
        );

        // Initialize user marker at current location
        userMarker = Marker(
          markerId: const MarkerId('user'),
          position: currentLocation,
          infoWindow: const InfoWindow(title: 'User'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );

        // Add the first point to route
        routePoints.add(currentLocation);

        // Update the polyline
        routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        );

        isLoading = false;
      });

      // Now that we have location, initialize socket and start the drive
      _initializeSocket();
      _startTestDrive(currentLocation);
    }
  }

  // Initialize the Socket.IO connection
  void _initializeSocket() {
    try {
      socket = IO.io('wss://api.smartassistapp.in', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
      });

      socket!.onConnect((_) {
        print('Connected to socket');
        socket!.emit('joinTestDrive', {'eventId': widget.eventId});
      });

      socket!.onConnectError((data) {
        print('Connection error: $data');
      });

      socket!.onError((data) {
        print('Socket error: $data');
      });

      // Listen for live location updates from backend
      socket!.on('locationUpdated', (data) {
        if (mounted) {
          setState(() {
            LatLng newCoordinates = LatLng(data['newCoordinates']['latitude'],
                data['newCoordinates']['longitude']);

            userMarker = Marker(
              markerId: const MarkerId('user'),
              position: newCoordinates,
              infoWindow: const InfoWindow(title: 'User'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            );

            routePoints.add(newCoordinates);
            routePolyline = Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: Colors.blue,
              width: 5,
            );

            // Update total distance if provided
            if (data['totalDistance'] != null) {
              totalDistance = data['totalDistance'].toDouble();
            }

            // Move camera to follow user if controller is available
            if (this.mapController != null) {
              mapController
                  .animateCamera(CameraUpdate.newLatLng(newCoordinates));
            }
          });
        }
      });

      // Listen for test drive ended event
      socket!.on('testDriveEnded', (data) {
        if (mounted) {
          _handleDriveEnded(
              data['totalDistance'] != null
                  ? data['totalDistance'].toDouble()
                  : totalDistance,
              data['duration'] != null ? data['duration'] : driveDuration);
        }
      });

      socket!.connect();
    } catch (e) {
      print('Socket initialization error: $e');
      if (mounted) {
        setState(() {
          error = 'Error connecting to server: $e';
        });
      }
    }
  }

  // Make the API call to start the test drive with dynamic coordinates
  Future<void> _startTestDrive(LatLng currentLocation) async {
    try {
      final url = Uri.parse(
          'https://api.smartassistapp.in/api/events/${widget.eventId}/start-drive');
      final token = await Storage.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'startCoordinates': {
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
          },
        }),
      );

      print('this is the api for the test drive latitide and longitude');

      if (response.statusCode == 200) {
        print('Test drive started successfully');
        // Start location tracking
        _startLocationTracking();
      } else {
        print('Failed to start test drive: ${response.statusCode}');
        if (mounted) {
          setState(() {
            error = 'Failed to start test drive: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      print('Error starting test drive: $e');
      if (mounted) {
        setState(() {
          error = 'Error starting test drive: $e';
        });
      }
    }
  }

  // Listen for location changes and update backend
  void _startLocationTracking() {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update location every 10 meters
      );

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        final LatLng newLocation =
            LatLng(position.latitude, position.longitude);
        _sendLocationUpdate(newLocation);
      });
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  // Update location to backend
  void _sendLocationUpdate(LatLng location) {
    if (socket != null && socket!.connected) {
      socket!.emit('updateLocation', {
        'eventId': widget.eventId,
        'newCoordinates': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      });
    }
  }

  // Handle when drive ends
  void _handleDriveEnded(double distance, int duration) {
    if (userMarker != null && mounted) {
      setState(() {
        endMarker = Marker(
          markerId: const MarkerId('end'),
          position: userMarker!.position,
          infoWindow: const InfoWindow(title: 'End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        isDriveEnded = true;
        totalDistance = distance;
        driveDuration = duration;
      });

      // Show summary dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Drive Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Distance: ${distance.toStringAsFixed(2)} km'),
              Text('Duration: $duration minutes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {},
              // onPressed: () {
              //   Navigator.pop(context); // Close dialog
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) =>
              //           FeedbackScreen(eventId: widget.eventId),
              //     ),
              //   );
              // },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      );
    }
  }

  // Handle Google Map creation
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Drive Map')),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          error,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _determinePosition,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      width: 400,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: startMarker?.position ?? const LatLng(0, 0),
                            zoom: 16,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          markers: {
                            if (startMarker != null) startMarker!,
                            if (userMarker != null) userMarker!,
                            if (isDriveEnded && endMarker != null) endMarker!,
                          },
                          polylines: {routePolyline},
                        ),
                      ),
                    ),
                    if (!isDriveEnded)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('End Drive & Submit Feedback',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
    );
  }
}

 


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';

// class Startdrive extends StatefulWidget {
//   const Startdrive({super.key});

//   @override
//   State<Startdrive> createState() => _StartdriveState();
// }

// class _StartdriveState extends State<Startdrive> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppColors.backgroundLightGrey,
//           title: Text('Test Drive', style: AppFont.appbarfontgrey(context)),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_outlined,
//                 color: AppColors.iconGrey),
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//           ),
//           elevation: 0,
//         ),
//         // body: ,
//         body: Stack(children: [
//           Scaffold(
//             body: Container(
//               width: double.infinity, // ✅ Ensures full width
//               height: double.infinity,
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundLightGrey,
//               ),
//               child: SafeArea(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       children: [
//                         // Main Container with Flexbox Layout
//                         Container(
//                           padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             children: [],
//                           ),
//                         ),

//                         TextButton(
//                             onPressed: () {},
//                             child: Text(
//                               textAlign: TextAlign.center,
//                               'End drive & submit feedback',
//                               style: GoogleFonts.poppins(
//                                   backgroundColor: Colors.red,
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500),
//                             )),
//                         TextButton(
//                             onPressed: () {},
//                             child: Text(
//                               textAlign: TextAlign.center,
//                               'End drive & Send feedback form to customer',
//                               style: GoogleFonts.poppins(
//                                   backgroundColor: Colors.red,
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500),
//                             ))
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ]));
//   }
// } 
