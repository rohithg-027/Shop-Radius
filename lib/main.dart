import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase fails to initialize, print the error and continue.
    debugPrint("Failed to initialize Firebase: $e");
  }
  runApp(
    const ProviderScope(child: ShopRadiusApp()),
  );
}
