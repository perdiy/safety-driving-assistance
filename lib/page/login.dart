// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/home.dart';
import 'package:safe/page/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  bool loading = false;
  String errorText = '';

  handleSubmit() async {
    if (email.isEmpty && password.isEmpty) {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi data terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        )
      );
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((result) async {
        // save user id on shared preferences
        final prefs = await SharedPreferences.getInstance();
        FirebaseFirestore.instance.collection('users').doc(result.user!.uid).get().then((userData) {
          if (userData.exists) {
            setState(() {
              loading = false;
            });

            prefs.setString('userId', result.user!.uid);
            prefs.setString('userName', userData.data()?['name']);
            prefs.setString('email', userData.data()?['email']);
            
            if (userData.data()?['is_admin'] != null) {
              prefs.setBool('isAdmin', userData.data()?['is_admin']);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil login. Selamat datang!'),
                behavior: SnackBarBehavior.floating,
              )
            );

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          } else {
            setState(() {
              loading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pengguna tidak ditemukan!'),
                behavior: SnackBarBehavior.floating,
              )
            );
          }
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;

        if (e.code == 'invalid-email') {
          errorText = 'Email tidak valid';
        } else if (e.code == 'user-not-found') {
          errorText = 'Pengguna tidak ditemukan';
        } else if (e.code == 'wrong-password') {
          errorText = 'Password salah';
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/aaa.jpg"), fit: BoxFit.fill),
          ),
          padding: const EdgeInsets.all(32),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Let's get started.",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        hintText: 'Email',
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    errorText.isNotEmpty ? Text(
                      errorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14
                      ),
                    ) : const SizedBox()
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => handleSubmit(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                        shape: const StadiumBorder()),
                    child: loading ? const Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        ),
                      ) : const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Register Here.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14
                    ),
                  )
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      )
    );
  }
}