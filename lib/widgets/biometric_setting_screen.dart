// biometric_settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/biometric_prefrence.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if device supports biometrics
      final LocalAuthentication auth = LocalAuthentication();
      _isBiometricAvailable = await auth.canCheckBiometrics;

      // Get current preference
      _isBiometricEnabled = await BiometricPreference.getUseBiometric();
    } catch (e) {
      print("Error loading biometric settings: $e");
      _isBiometricAvailable = false;
      _isBiometricEnabled = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      await BiometricPreference.setUseBiometric(value);
      if (mounted) {
        setState(() {
          _isBiometricEnabled = value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Biometric authentication enabled'
                  : 'Biometric authentication disabled',
              style: AppFont.dropDowmLabel(context),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error toggling biometric: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Biometric Settings',
          style: AppFont.popupTitleWhite(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Settings',
                    style: AppFont.dropDowmLabel(context),
                  ),
                  SizedBox(height: 20.h),
                  if (!_isBiometricAvailable)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                          const  Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Biometric authentication is not available on this device.',
                                style: AppFont.dropDowmLabel(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Use Biometric Authentication',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Unlock app using fingerprint or face ID',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isBiometricEnabled,
                              onChanged: _toggleBiometric,
                              activeColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
