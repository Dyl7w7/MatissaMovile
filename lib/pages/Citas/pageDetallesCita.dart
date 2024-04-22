import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageDetallesCita extends StatefulWidget {
  final String citaId;
  const PageDetallesCita({super.key, required this.citaId});

  @override
  State<PageDetallesCita> createState() => _PageDetallesCitaState();
}

class _PageDetallesCitaState extends State<PageDetallesCita> {
  List<Map<String, dynamic>> servicio = [];
  List<Map<String, dynamic>> detallesCita = [];

  @override
  void initState() {
    super.initState();
    fetchDetalleCita();
    fetchServicios();
  }

  Future<void> fetchServicios() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/servicios'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newData = [];
      for (var item in jsonData) {
        newData.add({
          'nombre': item['nombre'],
          'precio': item['precio'],
          'duracion': item['duracion'],
        });
      }

      setState(() {
        servicio = newData;
      });

      print('Servicios: $servicio');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> fetchDetalleCita() async {
    final response = await http.get(
        Uri.parse('https://matissa.onrender.com/api/citas/${widget.citaId}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      List<Map<String, dynamic>> newData = [
        {'detallesCitas': jsonData['detalleCitas']}
      ];

      setState(() {
        detallesCita = newData;
      });

      print('DetallesCita: $detallesCita');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de la cita"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Datos obtenidos de la API:'),
            // Muestra los datos en un ListView
            Expanded(
              child: ListView.builder(
                itemCount: detallesCita.length,
                itemBuilder: (context, index) {
                  List<dynamic> detalles = detallesCita[index]['detallesCitas'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Puedes agregar un encabezado si lo necesitas
                      // ListTile(
                      //   title: Text('Detalles de la cita'),
                      // ),
                      // Agregar un ListView.builder solo para los detalles de la cita
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: detalles.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            title: Text('Detalle ${i + 1}: ${detalles[i]['servicio']}'),
                            subtitle: Column(
                              children: [
                                Text('Fecha del servicio ${i + 1}: ${detalles[i]['fechaCita']}'),
                                Text('Hora del servicio ${i + 1}: ${detalles[i]['horaCita']}'),
                                Text('Costo del servicio ${i + 1}: ${detalles[i]['costoServicio']}'),
                                Text('Estado ${i + 1}: ${detalles[i]['estado']}'),
                              ],
                            ),
                            // Agrega aquí otros campos del detalle de la cita según tu estructura JSON
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){

        },
      ),
    );
  }
}
