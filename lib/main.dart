import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos_riverpod/screens/main_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCzCkuk5RMwcmmEUvBEgxS7_KSGdBIfNj4",
        authDomain: "vrix-7240b.firebaseapp.com",
        projectId: "vrix-7240b",
        storageBucket: "vrix-7240b.appspot.com",
        messagingSenderId: "329885876123",
        appId: "1:329885876123:web:139e625ad6903adc4e6b3e",
      ),
    );
  } else {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: kIsWeb ? const HomeScreen() : const MainScreen(),
    );
  }
}
