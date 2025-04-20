// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_launcher_icons/xml_templates.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';

// import 'package:smart_assist/utils/storage.dart';
// import 'package:smart_assist/widgets/license_preview.dart';

// class LicenseVarification extends StatefulWidget {
//   final String eventId;
//   final String leadId;
//   const LicenseVarification(
//       {super.key, required this.eventId, required this.leadId});

//   @override
//   State<LicenseVarification> createState() => _LicenseVarificationState();
// }

// class _LicenseVarificationState extends State<LicenseVarification> {
//   List<CameraDescription> cameras = [];
//   CameraController? cameraController;
//   File? _capturedImage;
//   bool _isCameraInitialized = false;
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupCameraController();
//   }

//   Future<void> _setupCameraController() async {
//     List<CameraDescription> _cameras = await availableCameras();
//     if (_cameras.isNotEmpty) {
//       cameraController =
//           CameraController(_cameras.first, ResolutionPreset.high);
//       await cameraController!.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     }
//   }

//   Future<void> _captureImage() async {
//     if (!(cameraController?.value.isInitialized ?? false)) return;

//     final XFile file = await cameraController!.takePicture();
//     final Directory appDir = await getApplicationDocumentsDirectory();
//     final String imagePath = path.join(appDir.path, '${DateTime.now()}.png');
//     final File newImage = await File(file.path).copy(imagePath);

//     setState(() {
//       _capturedImage = newImage;
//     });

//     // Navigate to preview screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LicencePreview(
//           imageFile: newImage,
//           eventId: widget.eventId,
//           leadId: widget.leadId,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     cameraController?.dispose();
//     super.dispose();
//   }

//    Future<void> submitFeedback() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? spId = prefs.getString('user_id');
//       final url = Uri.parse(
//           'https://api.smartassistapp.in/api/events/update/${widget.eventId}');
//       final token = await Storage.getToken();

//       // Create the request body
//       final requestBody = {
//         'sp_id': spId,
//         'skip_license': skip['Overall Ambience'],

//       };

//       // Print the data to console for debugging
//       print('Submitting feedback data:');
//       print(requestBody);

//       final response = await http.put(url,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//           body: json.encode(requestBody));

//       // Print the response
//       print('API Response status: ${response.statusCode}');
//       print('API Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // Success handling
//         print('Feedback submitted successfully');
//         Get.snackbar(
//           'Success',
//           'Feedback submitted successfully',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => FollowupsDetails(leadId: widget.leadId)));
//       } else {
//         // Error handling
//         print('Failed to submit feedback');
//         Get.snackbar(
//           'Error',
//           'Failed to submit feedback',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       // Exception handling
//       print('Exception occurred: ${e.toString()}');
//       Get.snackbar(
//         'Error',
//         'An error occurred: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       // appBar: AppBar(title: const Text("License Verification")),
//       body: _isCameraInitialized
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.sizeOf(context).height * 0.06,
//                   ),

//                   SizedBox(
//                     child: FittedBox(
//                       fit: BoxFit
//                           .cover, // Try BoxFit.fill if cover doesn't work as expected
//                       child: SizedBox(
//                         width: cameraController!.value.previewSize!.height,
//                         height: cameraController!.value.previewSize!.width,
//                         child: CameraPreview(cameraController!),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),
//                   // ElevatedButton(
//                   //   onPressed: _isUploading ? null : _captureImage,
//                   //   child: _isUploading
//                   //       ? const CircularProgressIndicator()
//                   //       : const Icon(Icons.camera),
//                   // ),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // ElevatedButton(
//                       //     style: ElevatedButton.styleFrom(
//                       //         padding: EdgeInsets.zero,
//                       //         backgroundColor: Colors.transparent),
//                       //     onPressed: () {},
//                       //     child: Container(
//                       //       margin: const EdgeInsets.all(5),
//                       //       decoration: BoxDecoration(
//                       //           border: Border.all(
//                       //               color: Colors.yellow, strokeAlign: 5)),
//                       //       child: const Icon(
//                       //         Icons.circle,
//                       //         size: 50,
//                       //         color: Colors.white,
//                       //       ),
//                       //     )),
//                       IconButton(
//                           onPressed: () {
//                             _isUploading ? null : {_captureImage()};
//                             // _isUploading;
//                           },
//                           icon: Icon(
//                             Icons.camera,
//                             size: MediaQuery.sizeOf(context).height * 0.07,
//                             color: Colors.white,
//                           )),

//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.colorsBlue,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                             ),
//                             onPressed: _showSkipDialog,
//                             child: Row(
//                               children: [
//                                 Text('Skip',
//                                     style: AppFont.smallTextWhite(context)),
//                                 const Icon(
//                                   Icons.skip_next,
//                                   color: Colors.white,
//                                 )
//                               ],
//                             )),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }

//   // Show skip confirmation dialog
//   Future<void> _showSkipDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap button to close dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(5),
//           ),
//           backgroundColor: Colors.white,
//           insetPadding: EdgeInsets.all(10),
//           contentPadding: EdgeInsets.zero,
//           title: Text(
//             'Select reason to skip',
//             style: AppFont.smallText(context),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       'License previously verufied - trusted client.',
//                       style: AppFont.mediumText14(context),
//                     )),
//                 TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       'Test drive under sales associate supervision - license on file.',
//                       style: AppFont.mediumText14(context),
//                     )),
//                 TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       ' Exception approved by management - premium client.',
//                       style: AppFont.mediumText14(context),
//                     )),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';

import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/license_preview.dart';
import 'package:smart_assist/widgets/start_drive.dart';

class LicenseVarification extends StatefulWidget {
  final String eventId;
  final String leadId;
  const LicenseVarification(
      {super.key, required this.eventId, required this.leadId});

  @override
  State<LicenseVarification> createState() => _LicenseVarificationState();
}

class _LicenseVarificationState extends State<LicenseVarification> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  File? _capturedImage;
  bool _isCameraInitialized = false;
  bool _isUploading = false;

  // Define a map to store skip reasons
  Map<String, String> skip = {
    'Overall Ambience': '',
  };

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameraController =
          CameraController(_cameras.first, ResolutionPreset.high);
      await cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (!(cameraController?.value.isInitialized ?? false)) return;

    final XFile file = await cameraController!.takePicture();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = path.join(appDir.path, '${DateTime.now()}.png');
    final File newImage = await File(file.path).copy(imagePath);

    setState(() {
      _capturedImage = newImage;
    });

    // Navigate to preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LicencePreview(
          imageFile: newImage,
          eventId: widget.eventId,
          leadId: widget.leadId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> submitFeedback(String skipReason) async {
    setState(() {
      _isUploading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? spId = prefs.getString('user_id');
      final url = Uri.parse(
          'https://api.smartassistapp.in/api/events/update/${widget.eventId}');
      final token = await Storage.getToken();

      // Update the skip reason
      skip['Overall Ambience'] = skipReason;

      // Create the request body
      final requestBody = {
        'sp_id': spId,
        'skip_license': skip['Overall Ambience'],
      };

      // Print the data to console for debugging
      print('Submitting feedback data:');
      print(requestBody);

      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestBody));

      // Print the response
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Success handling
        print('Feedback submitted successfully');
        Get.snackbar(
          'Success',
          'License verification skipped successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to FollowupsDetails screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StartDriveMap(
                      leadId: widget.leadId,
                      eventId: widget.eventId,
                    )));
      } else {
        // Error handling
        print('Failed to submit feedback');
        Get.snackbar(
          'Error',
          'Failed to skip license verification',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Exception handling
      print('Exception occurred: ${e.toString()}');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.06,
                  ),
                  SizedBox(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: cameraController!.value.previewSize!.height,
                        height: cameraController!.value.previewSize!.width,
                        child: CameraPreview(cameraController!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            if (!_isUploading) {
                              _captureImage();
                            }
                          },
                          icon: Icon(
                            Icons.camera,
                            size: MediaQuery.sizeOf(context).height * 0.07,
                            color: Colors.white,
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorsBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: _showSkipDialog,
                            child: Row(
                              children: [
                                Text('Skip',
                                    style: AppFont.smallTextWhite(context)),
                                const Icon(
                                  Icons.skip_next,
                                  color: Colors.white,
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // Show skip confirmation dialog
  Future<void> _showSkipDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  textAlign: TextAlign.center,
                  'Select reason to skip',
                  style: AppFont.mediumText14(context),
                ),
              ),
              const SizedBox(
                height: 10,
              )
              // Divider(color: Colors.grey.shade300),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Divider(height: 1, color: Colors.grey.shade200),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submitFeedback(
                          "License previously verified - trusted client");
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'License previously verified - trusted client.',
                        style: AppFont.mediumText14(context),
                        textAlign: TextAlign.left,
                      ),
                    )),
                Divider(height: 1, color: Colors.grey.shade200),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submitFeedback(
                          "Test drive under sales associate supervision - license on file");
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Test drive under sales associate supervision - license on file.',
                        style: AppFont.mediumText14(context),
                        textAlign: TextAlign.left,
                      ),
                    )),
                Divider(height: 1, color: Colors.grey.shade200),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      submitFeedback(
                          "Exception approved by management - premium client");
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Exception approved by management - premium client.',
                        style: AppFont.mediumText14(context),
                        textAlign: TextAlign.left,
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.colorsBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}
