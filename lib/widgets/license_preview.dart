import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/widgets/start_drive.dart';

class LicencePreview extends StatefulWidget {
  final File imageFile;
  final String eventId;
  final String leadId;
  const LicencePreview(
      {super.key,
      required this.imageFile,
      required this.eventId,
      required this.leadId});

  @override
  State<LicencePreview> createState() => _LicencePreviewState();
}

class _LicencePreviewState extends State<LicencePreview> {
  bool _isUploading = false;

  Future<String> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    final token = await Storage.getToken();
    final uri = Uri.parse(
        'https://dev.smartassistapp.in/api/events/${widget.eventId}/upload-license');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile(
          'file',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("✅ File uploaded successfully.");
        print("Response: ${response.body}");

        return 'success';
      } else {
        print("❌ Upload failed: ${response.statusCode}");
        print("Response: ${response.body}");
        return 'error';
      }
    } catch (e) {
      print("❌ Upload error: $e");
      return 'error';
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display image with reduced height
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    widget.imageFile,
                    height: MediaQuery.of(context).size.height * 0.70,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Retake Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Retake", style: AppFont.buttons(context)),
                    ),
                    const SizedBox(width: 16),
                    // Start Drive Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorsBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final result =
                                  await _uploadImage(widget.imageFile);
                              if (result == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartDriveMap(
                                      eventId: widget.eventId,
                                      leadId: widget.leadId,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Upload failed. Please try again.')),
                                );
                              }
                            },
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : Text("Start drive",
                              style: AppFont.buttons(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;

// import 'package:smart_assist/utils/storage.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:smart_assist/widgets/start_drive.dart';

// class LicencePreview extends StatefulWidget {
//   final File imageFile;
//   final String eventId;
//   final String leadId;
//   const LicencePreview(
//       {super.key,
//       required this.imageFile,
//       required this.eventId,
//       required this.leadId});

//   @override
//   State<LicencePreview> createState() => _LicencePreviewState();
// }

// class _LicencePreviewState extends State<LicencePreview> {
//   bool _isUploading = false;

//   Future<String> _uploadImage(File imageFile) async {
//     setState(() {
//       _isUploading = true;
//     });

//     final token = await Storage.getToken();
//     final uri = Uri.parse(
//         'https://dev.smartassistapp.in/api/events/${widget.eventId}/upload-license');

//     final request = http.MultipartRequest('POST', uri)
//       ..headers['Authorization'] = 'Bearer $token'
//       ..files.add(
//         http.MultipartFile(
//           'file',
//           imageFile.readAsBytes().asStream(),
//           imageFile.lengthSync(),
//           filename: path.basename(imageFile.path),
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       );

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         print("✅ File uploaded successfully.");
//         print("Response: ${response.body}");

//         return 'success';
//       } else {
//         print("❌ Upload failed: ${response.statusCode}");
//         print("Response: ${response.body}");
//         return 'error';
//       }
//     } catch (e) {
//       print("❌ Upload error: $e");
//       return 'error';
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   // Future<void> _uploadImage(File imageFile) async {
//   //   setState(() {
//   //     _isUploading = true;
//   //   });

//   //   final token = await Storage.getToken();

//   //   final uri =
//   //       Uri.parse('https://dev.smartassistapp.in/api/events/upload-license');

//   //   final request = http.MultipartRequest('POST', uri)
//   //     ..headers['Authorization'] = 'Bearer $token'
//   //     ..files.add(
//   //       http.MultipartFile(
//   //         'file',
//   //         imageFile.readAsBytes().asStream(),
//   //         imageFile.lengthSync(),
//   //         filename: path.basename(imageFile.path),
//   //         contentType: MediaType('image', 'jpeg'),
//   //       ),
//   //     );

//   //   try {
//   //     final streamedResponse = await request.send();
//   //     final response = await http.Response.fromStream(streamedResponse);

//   //     if (response.statusCode == 200) {
//   //       print("✅ File uploaded successfully.");
//   //       print("Response: ${response.body}");
//   //       // Navigate or show success
//   //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//   //         content: Text('Image uploaded and drive started!'),
//   //       ));
//   //     } else {
//   //       print("❌ Upload failed: ${response.statusCode}");
//   //       print("Response: ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     print("❌ Upload error: $e");
//   //   } finally {
//   //     setState(() {
//   //       _isUploading = false;
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('', style: AppFont.appbarfontgrey(context)),
//       //   leading: IconButton(
//       //     icon: const Icon(Icons.close_rounded, color: AppColors.iconGrey),
//       //     onPressed: () => Navigator.pop(context, true),
//       //   ),
//       //   elevation: 0,
//       // ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ClipRRect(
//                 // borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   widget.imageFile,
//                   height: MediaQuery.sizeOf(context).height * 0.80,
//                   // width: MediaQuery.sizeOf(context).width * 0.90,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         // padding: EdgeInsets.zero,
//                         backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5))),
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Retake",
//                         textAlign: TextAlign.center,
//                         style: AppFont.buttons(context)),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         // padding: EdgeInsets.zero,
//                         backgroundColor: AppColors.colorsBlue,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5))),
//                     onPressed: _isUploading
//                         ? null
//                         : () async {
//                             final result = await _uploadImage(widget.imageFile);

//                             if (result == 'success') {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StartDriveMap(
//                                       eventId: widget.eventId,
//                                       leadId: widget
//                                           .leadId), // Replace with your target screen
//                                 ),
//                               );
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text(
//                                         'Upload failed. Please try again.')),
//                               );
//                             }
//                           },
//                     child: _isUploading
//                         ? const CircularProgressIndicator()
//                         : Text("Start drive", style: AppFont.buttons(context)),
//                   ),

//                   // TextButton(
//                   //     onPressed: () {
//                   //       Navigator.push(
//                   //           context,
//                   //           MaterialPageRoute(
//                   //               builder: (context) => StartDriveMap(
//                   //                     eventId: widget.eventId,
//                   //                   )));
//                   //     },
//                   //     child: Text('start test drive'))
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
