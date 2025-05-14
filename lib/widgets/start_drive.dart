import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/feedback.dart';
import 'package:smart_assist/widgets/testdrive_overview.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
// Remove permission_handler import since we're going to use only Geolocator's permission system

class StartDriveMap extends StatefulWidget {
  final String eventId;
  final String leadId;
  const StartDriveMap({super.key, required this.eventId, required this.leadId});

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
  IO.Socket? socket;
  bool isDriveEnded = false;
  bool isLoading = true;
  String error = '';
  double totalDistance = 0;
  int driveDuration = 0;
  StreamSubscription<Position>? positionStreamSubscription;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now(); // Track when drive started
    _screenshotController = ScreenshotController();
    _determinePosition();

    routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: Colors.blue,
      width: 5,
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
        setState(() {
          error =
              'Location permissions are denied. Please allow access to your location.';
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        error =
            'Location permissions are permanently denied. Please enable them in app settings.';
        isLoading = false;
      });
      return;
    }

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
        _updatePolyline();

        isLoading = false;
      });

      // Now that we have location, initialize socket and start the drive
      _initializeSocket();
      _startTestDrive(currentLocation);
    }
  }

  void _updatePolyline() {
    routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: Colors.blue,
      width: 5,
    );
  }

  // Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(point1.latitude, point1.longitude,
            point2.latitude, point2.longitude) /
        1000; // Convert to km
  }

  // Initialize the Socket.IO connection
  void _initializeSocket() {
    try {
      socket = IO.io('wss://dev.smartassistapp.in', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      socket!.onConnect((_) {
        print('Connected to socket');
        socket!.emit('joinTestDrive', {'eventId': widget.eventId});
      });

      socket!.onConnectError((data) {
        print('Connection error: $data');
        // Try reconnecting if socket fails
        if (socket != null && !socket!.connected) {
          socket!.connect();
        }
      });

      socket!.onError((data) {
        print('Socket error: $data');
      });

      socket!.on('disconnect', (_) {
        print('Socket disconnected');
        // Try reconnecting if not already ended
        if (!isDriveEnded && socket != null) {
          socket!.connect();
        }
      });

      // Listen for live location updates from backend
      socket!.on('locationUpdated', (data) {
        if (mounted) {
          if (data == null || data['newCoordinates'] == null) {
            print('Received invalid location update data');
            return;
          }

          try {
            setState(() {
              LatLng newCoordinates = LatLng(
                data['newCoordinates']['latitude'],
                data['newCoordinates']['longitude'],
              );

              // Update user marker
              userMarker = Marker(
                markerId: const MarkerId('user'),
                position: newCoordinates,
                infoWindow: const InfoWindow(title: 'User'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
              );

              // Calculate distance for this segment
              if (routePoints.isNotEmpty) {
                LatLng lastPoint = routePoints.last;
                double segmentDistance =
                    _calculateDistance(lastPoint, newCoordinates);
                totalDistance += segmentDistance;
              }

              // Add point to route
              routePoints.add(newCoordinates);
              _updatePolyline();

              // Update total distance if provided by server
              if (data['totalDistance'] != null) {
                totalDistance = data['totalDistance'].toDouble();
              }

              // Move camera to follow user
              if (mapController != null) {
                mapController
                    .animateCamera(CameraUpdate.newLatLng(newCoordinates));
              }
            });
          } catch (e) {
            print('Error processing location update: $e');
          }
        }
      });

      // Listen for test drive ended event
      socket!.on('testDriveEnded', (data) {
        if (mounted) {
          double finalDistance = data['totalDistance'] != null
              ? data['totalDistance'].toDouble()
              : totalDistance;

          int finalDuration = data['duration'] != null
              ? data['duration']
              : _calculateDuration();

          _handleDriveEnded(finalDistance, finalDuration);
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

  int _calculateDuration() {
    if (startTime == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(startTime!);
    return (difference.inSeconds / 60).round(); // Convert to minutes
  }

  // Make the API call to start the test drive with dynamic coordinates
  Future<void> _startTestDrive(LatLng currentLocation) async {
    try {
      final url = Uri.parse(
          'https://dev.smartassistapp.in/api/events/${widget.eventId}/start-drive');
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

      print('Starting test drive for event: ${widget.eventId}');

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

      positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        final LatLng newLocation =
            LatLng(position.latitude, position.longitude);

        // Update locally first
        if (mounted && userMarker != null) {
          setState(() {
            // Update user marker position
            userMarker = Marker(
              markerId: const MarkerId('user'),
              position: newLocation,
              infoWindow: const InfoWindow(title: 'User'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            );

            // Calculate distance for this segment
            if (routePoints.isNotEmpty) {
              LatLng lastPoint = routePoints.last;
              double segmentDistance =
                  _calculateDistance(lastPoint, newLocation);
              totalDistance += segmentDistance;
            }

            // Add new point to route
            routePoints.add(newLocation);
            _updatePolyline();
          });
        }

        // Then send to server
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
        },
        'totalDistance': totalDistance // Also send current calculated distance
      });
    } else {
      print('Socket not connected, trying to reconnect...');
      if (socket != null) {
        socket!.connect();
      }
    }
  }

  // Handle when drive ends
  void _handleDriveEnded(double distance, int duration) {
    if (mounted) {
      setState(() {
        if (userMarker != null) {
          endMarker = Marker(
            markerId: const MarkerId('end'),
            position: userMarker!.position,
            infoWindow: const InfoWindow(title: 'End'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        }

        isDriveEnded = true;
        totalDistance = distance > 0 ? distance : totalDistance;
        driveDuration = duration > 0 ? duration : _calculateDuration();

        // Ensure we clean up location tracking
        if (positionStreamSubscription != null) {
          positionStreamSubscription!.cancel();
        }
      });
    }
  }

// New method to upload drive summary instead of image
  // Future<void> _uploadDriveSummary() async {
  //   try {
  //     final url = Uri.parse(
  //         'https://dev.smartassistapp.in/api/events/${widget.eventId}/drive-summary');
  //     final token = await Storage.getToken();

  //     // Convert route points to a simpler format for the API
  //     List<Map<String, double>> routeCoordinates = routePoints
  //         .map((point) => {
  //               'latitude': point.latitude,
  //               'longitude': point.longitude,
  //             })
  //         .toList();

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode({
  //         'startPoint': {
  //           'latitude': startMarker?.position.latitude,
  //           'longitude': startMarker?.position.longitude,
  //         },
  //         'endPoint': {
  //           'latitude': userMarker?.position.latitude,
  //           'longitude': userMarker?.position.longitude,
  //         },
  //         'totalDistance': totalDistance,
  //         'duration': _calculateDuration(),
  //         'routePoints': routeCoordinates,
  //         'timestamp': DateTime.now().toIso8601String(),
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Drive summary data uploaded successfully');
  //     } else {
  //       print('Failed to upload drive summary: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error uploading drive summary: $e');
  //     // Just log the error but don't throw - we want to continue with the workflow
  //   }
  // }

// Improved end drive function with more resilient error handling
  Future<void> _handleEndDrive() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First upload the drive summary - most reliable method
      // await _uploadDriveSummary();

      // Then try the screenshot but don't block on failure
      bool screenshotSuccess = false;
      try {
        await _captureAndUploadImage().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print("Screenshot operation timed out");
            return;
          },
        );
        screenshotSuccess = true;
      } catch (e) {
        print("Screenshot process failed: $e");
        // Continue with the process
      }

      // Finally end the drive with API call
      await _endTestDrive();

      // Clean up resources
      _cleanupResources();

      // Show feedback to user about screenshot if it failed
      if (!screenshotSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Map image could not be captured, but drive data was saved successfully')),
        );
      }

      // Navigate to feedback screen
      if (mounted) {
        // Add a small delay to let any UI updates complete
        await Future.delayed(Duration(milliseconds: 300));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Feedbackscreen(
              leadId: widget.leadId,
              eventId: widget.eventId,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error in end drive process: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ending test drive: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }

      _cleanupResources();
    }
  }

  // Future<void> _handleEndDrive() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     // Try screenshot but don't let failure block the process
  //     try {
  //       await _captureAndUploadImage().timeout(
  //         const Duration(seconds: 5),
  //         onTimeout: () {
  //           print("Screenshot operation timed out");
  //           throw TimeoutException("Screenshot timed out");
  //         },
  //       );
  //     } catch (e) {
  //       print("Screenshot failed: $e");
  //       // Continue with the process regardless of screenshot failure
  //     }

  //     // End the drive with API call - the most important part
  //     await _endTestDrive();

  //     // Clean up resources
  //     _cleanupResources();

  //     // Navigate to feedback screen
  //     if (mounted) {
  //       // Add a small delay to let any UI updates complete
  //       await Future.delayed(Duration(milliseconds: 200));

  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(
  //           builder: (context) => Feedbackscreen(
  //             leadId: widget.leadId,
  //             eventId: widget.eventId,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error in end drive process: $e");

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error ending test drive: $e')),
  //       );
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }

  //     _cleanupResources();
  //   }
  // }

// Dedicated method for resource cleanup
  void _cleanupResources() {
    try {
      if (socket != null) {
        socket!.disconnect();
        socket = null;
      }
      if (positionStreamSubscription != null) {
        positionStreamSubscription!.cancel();
        positionStreamSubscription = null;
      }
      if (mapController != null) {
        // No need to explicitly dispose mapController as it's handled by the GoogleMap widget
      }
    } catch (e) {
      print("Error during resource cleanup: $e");
    }
  }

  // Handle Google Map creation
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // End the test drive with API call

// Modify your _endTestDrive function
  Future<void> _endTestDrive() async {
    try {
      final url = Uri.parse(
          'https://dev.smartassistapp.in/api/events/${widget.eventId}/end-drive');
      final token = await Storage.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'totalDistance': totalDistance,
          'duration': _calculateDuration(),
        }),
      );

      if (response.statusCode == 200) {
        print('Test drive ended successfully');
        print('Duration: ${_calculateDuration()}');
        _handleDriveEnded(totalDistance, _calculateDuration());
      } else {
        throw Exception('Failed to end drive: ${response.statusCode}');
      }
    } catch (e) {
      print('Error ending drive: $e');
      throw e; // Re-throw to be caught by caller
    }
  }

  @override
  void dispose() {
    // Clean up resources
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }

    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
    }

    super.dispose();
  }

  ScreenshotController _screenshotController = ScreenshotController();

  // Update your screenshot capture function
  // Future<void> _captureAndUploadImage() async {
  //   // Small delay before capture to let the UI stabilize
  //   await Future.delayed(Duration(milliseconds: 100));

  //   try {
  //     final image = await _screenshotController.capture();
  //     if (image == null) {
  //       throw Exception("Screenshot capture returned null");
  //     }

  //     final directory = await getTemporaryDirectory();
  //     final filePath = '${directory.path}/map_image.png';
  //     final file = File(filePath)..writeAsBytesSync(image);

  //     await _uploadImage(file);
  //   } catch (e) {
  //     print("Error capturing or uploading screenshot: $e");
  //     throw e; // Re-throw to be caught by caller
  //   }
  // }

  // Improved screenshot capture function with better error handling
  Future<void> _captureAndUploadImage() async {
    // Longer delay before capture to ensure UI is fully rendered
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        print("Screenshot capture returned null - trying alternative method");
        // Try alternative capture method - use UI only
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/map_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath)..writeAsBytesSync(image);

      await _uploadImage(file);
    } catch (e) {
      print("Error in screenshot capture: $e");
      // Fall back to drive summary upload
      // Don't rethrow - we've handled it with the fallback
    }
  }

  // Improved upload image function with better error handling
  Future<bool> _uploadImage(File file) async {
    final url = Uri.parse(
        'https://dev.smartassistapp.in/api/events/${widget.eventId}/upload-map');
    final token = await Storage.getToken();

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'png'), // Changed to PNG
        ));

      // Add a timeout to the request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Image upload timed out");
        },
      );

      // Get the response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        print('Response: ${response.body}');
        return true;
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }

  // Future<void> _uploadImage(File file) async {
  //   final url = Uri.parse(
  //       'https://dev.smartassistapp.in/api/events/${widget.eventId}/upload-map');
  //   final token = await Storage.getToken();
  //   try {
  //     var request = http.MultipartRequest('POST', url)
  //       ..headers['Authorization'] = 'Bearer $token'
  //       ..files.add(await http.MultipartFile.fromPath(
  //         'file', // This should be the field name expected by the API (e.g., 'file' or 'image')
  //         file.path,
  //         contentType: MediaType('image', 'jpeg'), // Set the correct MIME type
  //       ));

  //     // Send the request
  //     var streamedResponse = await request.send();

  //     // Get the response
  //     final response = await http.Response.fromStream(streamedResponse);

  //     if (response.statusCode == 200) {
  //       print('Image uploaded successfully');
  //       print('Response: ${response.body}');
  //     } else {
  //       print('Failed to upload image: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLightGrey,
        title: Text('Test Drive', style: AppFont.appbarfontgrey(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppColors.iconGrey),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        elevation: 0,
      ),
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
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration:
                          BoxDecoration(color: AppColors.backgroundLightGrey),
                      child: SafeArea(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SizedBox(
                                    height: 400,
                                    width: 400,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Screenshot(
                                        controller: _screenshotController,
                                        // child: GoogleMap(
                                        //   onMapCreated: _onMapCreated,
                                        //   initialCameraPosition: CameraPosition(
                                        //     target: startMarker?.position ??
                                        //         const LatLng(0, 0),
                                        //     zoom: 16,
                                        //   ),
                                        //   myLocationEnabled: true,
                                        //   myLocationButtonEnabled: true,
                                        //   zoomControlsEnabled: true,
                                        //   markers: {
                                        //     if (startMarker != null)
                                        //       startMarker!,
                                        //     if (userMarker != null) userMarker!,
                                        //     if (isDriveEnded &&
                                        //         endMarker != null)
                                        //       endMarker!,
                                        //   },
                                        //   polylines: {routePolyline},
                                        // ),

                                        child: GoogleMap(
                                          onMapCreated: _onMapCreated,
                                          initialCameraPosition: CameraPosition(
                                            target: startMarker?.position ??
                                                const LatLng(0, 0),
                                            zoom: 16,
                                          ),
                                          myLocationEnabled: true,
                                          myLocationButtonEnabled: true,
                                          zoomControlsEnabled: true,
                                          markers: {
                                            if (startMarker != null)
                                              startMarker!,
                                            if (userMarker != null) userMarker!,
                                            if (isDriveEnded &&
                                                endMarker != null)
                                              endMarker!,
                                          },
                                          polylines: {routePolyline},
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (!isDriveEnded)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Distance: ${totalDistance.toStringAsFixed(2)} km',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Duration: ${_calculateDuration()} mins',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (!isDriveEnded)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      // Update the button onPressed handler
                                      onPressed: () async {
                                        try {
                                          // First try to capture and upload the image
                                          try {
                                            await _captureAndUploadImage();
                                          } catch (e) {
                                            // Log but don't block the flow if screenshot fails
                                            print(
                                                "Screenshot capture/upload failed: $e");
                                            // Maybe show a toast notification
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Could not capture map image: $e')),
                                            );
                                          }

                                          // Continue with ending the drive regardless of screenshot success
                                          await _handleEndDrive();
                                          ;
                                        } catch (e) {
                                          // Handle errors with the end drive API call
                                          print("Error ending drive: $e");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Error ending drive: $e')),
                                          );
                                        }
                                      },
                                      // onPressed: () {
                                      //   _endTestDrive();
                                      //   _captureAndUploadImage();
                                      // },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor:
                                            AppColors.colorsBlueButton,
                                      ),
                                      child: Text(
                                          'End Test Drive & Submit Feedback Now',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white)),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TestdriveOverview(
                                            eventId: widget.eventId,
                                            leadId: widget.leadId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      'End Test Drive & Submit Feedback Later',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
