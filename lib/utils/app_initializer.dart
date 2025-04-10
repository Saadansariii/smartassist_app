import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_assist/services/notifacation_srv.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    try {
      await Firebase.initializeApp();
      print("✅ Firebase initialized successfully!");
    } catch (e) {
      print("❌ Firebase initialization failed: $e");
      throw e; // Rethrow to handle in main
    }

    // Initialize Hive
    await Hive.initFlutter();

    // Initialize Notifications
    await NotificationService.instance.initialize();
  }
}
