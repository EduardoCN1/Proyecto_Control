import 'dart:developer';
import 'dart:io';
import 'package:crud_firebase/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool isEntry = true; // Variable para almacenar el estado actual del alumno

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? Text('Código QR: $qrText')
                  : Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      final qrCode = scanData.code;
      if (qrCode != null) {
        _processQRCode(qrCode);
      }
    });
  }

  Future<void> _processQRCode(String qrCode) async {
    try {
      final alumno = await getAlumnoByEmail(qrCode);
      if (alumno != null) {
        final currentState = alumno['Estatus'] == 1; // Estado actual del alumno
        await updateAlumnoStatus(qrCode); // Actualizar estado del alumno

        setState(() {
          qrText = qrCode;
          isEntry = !currentState; // Cambiar entre entrada y salida
        });
      } else {
        // Manejar caso donde no se encontró ningún alumno con el código QR
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante el procesamiento del código QR
      log('Error al procesar el código QR: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
