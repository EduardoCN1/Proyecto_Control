import 'dart:developer';
import 'package:crud_firebase/Pages/alumno_screen.dart';
import 'package:crud_firebase/Pages/padre_screen.dart';
import 'package:crud_firebase/Pages/profesores_screen.dart';
import 'package:flutter/material.dart';
import 'package:crud_firebase/Pages/registro_page.dart';
import 'package:crud_firebase/widgets/button.dart';
import 'package:crud_firebase/widgets/textfield.dart';
import '../services/firebase_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Iniciar Sesion",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              controller: _password,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Iniciar Sesion",
              onPressed: _login,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("No tienes una cuenta? "),
              InkWell(
                onTap: () => goToSignup(context),
                child: const Text("Crear Cuenta",
                    style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context, String userType) {
    switch (userType) {
      case 'alumno':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Qr(userEmail: _email.text)),
        );
        break;
      case 'profesor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRScanner()),
        );
        break;
      case 'padre':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PadreScreen()),
        );
        break;
      default:
        log('Usuario no identificado');
    }
  }

  _login() async {
    final user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("User Logged In");

      // Obtener el correo electrónico del usuario
      String email = user.email!;

      // Determinar el tipo de usuario
      String userType = '';
      if (email.startsWith("2020")) {
        userType = 'alumno';
      } else if (email.startsWith("3030")) {
        userType = 'profesor';
      } else {
        userType = 'padre';
      }

      goToHome(context, userType);
    }
  }
}
