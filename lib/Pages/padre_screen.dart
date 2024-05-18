import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PadreScreen extends StatefulWidget {
  @override
  _PadreScreenState createState() => _PadreScreenState();
}

class _PadreScreenState extends State<PadreScreen> {
  String correo = ''; // Correo del hijo a seguir

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Padre Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (correo.isNotEmpty)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Alumnos')
                    .doc(correo)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('No hay datos disponibles');
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  String estadoActual = data['EstadoActual'] ?? 'N/A';
                  Timestamp? timestamp = data['FechaActualizacion'];
                  String fecha = timestamp != null
                      ? DateFormat('yyyy-MM-dd – kk:mm')
                          .format(timestamp.toDate())
                      : 'N/A';

                  return Column(
                    children: [
                      Text('Estado Actual: $estadoActual'),
                      Text('Fecha: $fecha'),
                    ],
                  );
                },
              )
            else
              Text('Por favor, configure un correo en la configuración.'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                // Navegar a la pantalla de configuración
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ConfiguracionScreen(onCorreoSaved: (correoGuardado) {
                            setState(() {
                              correo = correoGuardado;
                            });
                          })),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.control_point),
              onPressed: () {
                // Mostrar información de llegada
                if (correo.isNotEmpty) {
                  _mostrarInformacionLlegada(context);
                } else {
                  _mostrarError(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInformacionLlegada(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Alumnos')
              .doc(correo)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('Información de Llegada'),
                content: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return AlertDialog(
                title: Text('Información de Llegada'),
                content: Text('No hay datos disponibles'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cerrar'),
                  ),
                ],
              );
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            String estadoActual = data['EstadoActual'] ?? 'N/A';
            Timestamp? timestamp = data['FechaActualizacion'];
            String fecha = timestamp != null
                ? DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate())
                : 'N/A';

            return AlertDialog(
              title: Text('Información de Llegada'),
              content:
                  Text('Correo: $correo\nEstado: $estadoActual\nFecha: $fecha'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'Por favor, agregue un correo en la configuración para ver la información de llegada.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class ConfiguracionScreen extends StatelessWidget {
  final TextEditingController _correoController = TextEditingController();
  final Function(String) onCorreoSaved;

  ConfiguracionScreen({required this.onCorreoSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _correoController,
              decoration: InputDecoration(
                hintText: 'Ingrese su correo',
                labelText: 'Correo',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _guardarCorreo(context);
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarCorreo(BuildContext context) {
    final String correo = _correoController.text;

    if (correo.isNotEmpty) {
      // Guardar el correo en la colección "Padres" de Firestore
      FirebaseFirestore.instance.collection('Padres').add({
        'correo': correo,
      }).then((value) {
        // Llamar a la función callback para guardar el correo en la pantalla principal
        onCorreoSaved(correo);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo guardado con éxito'),
          ),
        );

        // Regresar a la pantalla anterior
        Navigator.pop(context);
      }).catchError((error) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el correo'),
          ),
        );
      });
    } else {
      // Mostrar mensaje de error si el campo de correo está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese un correo'),
        ),
      );
    }
  }
}
