// ignore_for_file: use_build_context_synchronously

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout!'),
          behavior: SnackBarBehavior.floating,
        )
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => logout(),
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 14
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}
