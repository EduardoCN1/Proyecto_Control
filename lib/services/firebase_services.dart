import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>?> getAlumnoByEmail(String email) async {
  try {
    log('Obteniendo datos del alumno con el correo: $email');

    // Obtén el documento directamente usando el ID del documento (que es el correo electrónico)
    final DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('Alumnos').doc(email).get();

    if (docSnapshot.exists) {
      log('Alumno encontrado: ${docSnapshot.data()}');
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      log('No se encontró ningún alumno con el correo $email');
      return null;
    }
  } catch (e) {
    log('Error al obtener el alumno por correo electrónico: $e');
    return null;
  }
}

Future<void> addUser(
    String nombre, String apellido, String telefono, String direccion) async {
  CollectionReference usuarios =
      FirebaseFirestore.instance.collection('Usuarios');

  await usuarios
      .add({
        'Nombre': nombre,
        'Apellido': apellido,
        'Telefono': telefono,
        'Direccion': direccion,
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}

Future<void> updateAlumnoStatus(String email) async {
  try {
    final DocumentReference alumnoRef =
        FirebaseFirestore.instance.collection('Alumnos').doc(email);

    final alumnoDoc = await alumnoRef.get();
    if (alumnoDoc.exists) {
      Map<String, dynamic>? alumnoData =
          alumnoDoc.data() as Map<String, dynamic>?;

      if (alumnoData != null) {
        String estadoActual = alumnoData['EstadoActual'] ?? '';

        String nuevoEstado = (estadoActual == 'Entrada') ? 'Salida' : 'Entrada';

        // Actualizar el estado y la fecha de la última actividad
        await alumnoRef.update({
          'EstadoActual': nuevoEstado,
          'UltimaActividad': FieldValue.serverTimestamp(),
        });

        log('Estado del alumno actualizado exitosamente para $email. Nuevo estado: $nuevoEstado');
      } else {
        log('No se encontró ningún dato para el alumno con el correo $email');
      }
    } else {
      log('No se encontró ningún alumno con el correo $email');
    }
  } catch (e) {
    log('Error al actualizar el estado del alumno: $e');
  }
}
