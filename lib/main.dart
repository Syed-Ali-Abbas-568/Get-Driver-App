import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_driver_app/screens/login_screen.dart';
import 'package:get_driver_app/screens/profile_creation.dart';
import 'package:get_driver_app/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:get_driver_app/providers/auth_providers.dart';
import 'package:get_driver_app/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Inter",
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      // const ProfileCreation(),
      //const NavBar(),
    );
  }
}
