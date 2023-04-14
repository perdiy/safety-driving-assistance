// ignore_for_file: use_build_context_synchronously

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userName = '';
  String? email = '';

  logout() async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      title: 'Ingin logout?',
      message: 'Konfirmasi jika kamu ingin logout.',
      context: context,
    );

    if (result == OkCancelResult.ok) {
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Berhasil logout!'),
        behavior: SnackBarBehavior.floating,
      ));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
    }
  }

  initData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName');
      email = prefs.getString('email');
    });
  }

  @override
  void initState() {
    initData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/man.png",
                  width: 130,
                ),
                const SizedBox(height: 24),
                Text(
                  userName ?? 'Nama Pengguna',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Text(
                  email ?? 'Email Pengguna',
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                  ),
                  icon: Icon(Icons.logout),
                  onPressed: () => logout(),
                  label: Text('Logout'),
                ),
              ],
            ),
          ),
        ));
  }
}
