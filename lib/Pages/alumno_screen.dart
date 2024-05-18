import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crud_firebase/services/firebase_services.dart';

class Qr extends StatefulWidget {
  final String userEmail;

  const Qr({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<Qr> createState() => _QrState();
}

class _QrState extends State<Qr> {
  Map<String, dynamic>? alumnoData;

  @override
  void initState() {
    super.initState();
    getAlumnoData();
  }

  Future<void> getAlumnoData() async {
    try {
      log('Obteniendo datos del alumno con el correo: ${widget.userEmail}');
      final data = await getAlumnoByEmail(widget.userEmail);
      setState(() {
        alumnoData = data;
      });
      if (data == null) {
        print('No se encontró información del alumno.');
      } else {
        print('Información del alumno obtenida: $data');
      }
    } catch (e) {
      print('Error al obtener la información del alumno: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Generator"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            RepaintBoundary(
              child: Center(
                child: QrImageView(
                  data: widget.userEmail,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            if (alumnoData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Información del alumno:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Nombre: ${alumnoData!['Nombre']}'),
                  Text('Apellido: ${alumnoData!['Apellido']}'),
                  Text('Matrícula: ${alumnoData!['Matricula']}'),
                ],
              ),
            if (alumnoData == null)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'No se encontró información del alumno.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
