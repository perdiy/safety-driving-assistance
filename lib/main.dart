import 'package:flutter/material.dart';
import 'package:safe/home.dart';
import 'package:safe/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  final prefs = await SharedPreferences.getInstance();
  final String userId = prefs.getString('userId') ?? '';

  Widget? home;

  if (userId.isEmpty) {
    home = const Welcome();
  } else {
    home = Home();
  }

  runApp(MyApp(home: home));
}

class MyApp extends StatelessWidget {
  final Widget? home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}
