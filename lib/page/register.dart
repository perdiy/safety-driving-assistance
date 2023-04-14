import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe/page/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String email = '';
  String password = '';
  String name = '';
  bool loading = false;
  String errorText = '';

  handleSubmit() async {
    if (email.isEmpty && password.isEmpty && name.isEmpty) {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((result) async {
        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
          "name": name,
          "email": email,
          "uid": result.user!.uid,
          "created_at": FieldValue.serverTimestamp(),
        }).then((value) {
          setState(() {
            loading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil daftar. Silahkan login terlebih dahulu'),
              behavior: SnackBarBehavior.floating,
            )
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;

        if (e.code == 'email-already-in-use') {
          errorText = 'Email sudah digunakan';
        } else if (e.code == 'invalid-email') {
          errorText = 'Email tidak valid';
        } else if (e.code == 'weak-password') {
          errorText = 'Password lemah';
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
                        hintText: 'Name',
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    const SizedBox(height: 24),
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
                      'Register',
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
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Have an account? Sign in here.",
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