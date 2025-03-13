import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider if you're using it
import 'login_screen.dart'; // Import your LoginScreen
import 'fetch_model.dart'; // Import your FetcherModel
import 'home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FetcherModel(), // Initialize your model here
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(), // Set LoginScreen as the home
      ),
    );
  }
}