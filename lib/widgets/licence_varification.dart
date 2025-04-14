 

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/license_preview.dart';

class PassportVarification extends StatefulWidget {
  final String eventId;
  const PassportVarification({super.key, required this.eventId});

  @override
  State<PassportVarification> createState() => _PassportVarificationState();
}

class _PassportVarificationState extends State<PassportVarification> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  File? _capturedImage;
  bool _isCameraInitialized = false;
  bool _isUploading = false;

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
        builder: (context) => LicencePreview(imageFile: newImage , eventId: widget.eventId,),
      ),
    );
  }

  // Future<void> _uploadImage(File imageFile) async {
  //   final token = await Storage.getToken(); // Get your auth token

  //   final uri =
  //       Uri.parse('https://api.smartassistapp.in/api/events/upload-license');

  //   final request = http.MultipartRequest('POST', uri)
  //     ..headers['Authorization'] = 'Bearer $token'
  //     ..files.add(
  //       http.MultipartFile(
  //         'file', // 👈 Use the field name your backend expects (e.g. 'file', 'document')
  //         imageFile.readAsBytes().asStream(),
  //         imageFile.lengthSync(),
  //         filename: path.basename(imageFile.path),
  //         contentType:
  //             MediaType('image', 'jpeg'), // or 'png' depending on your file
  //       ),
  //     );

  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     if (response.statusCode == 200) {
  //       print("✅ File uploaded successfully.");
  //       print("Response: ${response.body}");
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => LicencePreview(imageFile: imageFile),
  //         ),
  //       );
  //     } else {
  //       print("❌ Upload failed: ${response.statusCode}");
  //       print("Response: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("❌ Upload error: $e");
  //   }
  // }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Passport Verification")),
      body: _isCameraInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //     height: MediaQuery.sizeOf(context).height * 0.30,
                  //     width: MediaQuery.sizeOf(context).width * 0.90,
                  //     child: CameraPreview(cameraController!)),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.30,
                    width: MediaQuery.sizeOf(context).width * 0.90,
                    child: FittedBox(
                      fit: BoxFit
                          .cover, // Try BoxFit.fill if cover doesn't work as expected
                      child: SizedBox(
                        width: cameraController!.value.previewSize!.height,
                        height: cameraController!.value.previewSize!.width,
                        child: CameraPreview(cameraController!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _captureImage,
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : const Text("Capture & Upload"),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
