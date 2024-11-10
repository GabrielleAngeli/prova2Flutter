import 'package:flutter/material.dart';
import 'screens/tennisList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os bindings do Flutter estão inicializados antes de chamar Firebase.initializeApp().
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lista de Tênis',
      home: TennisList(),
    );
  }
}
