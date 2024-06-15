import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:intl/intl.dart';
import '../widget/AppBar.dart';

class DetalleCitaConNombre {
  final String nombreServicio;
  final int horaInicio;
  final int horaFin;
  final double costoServicio;

  DetalleCitaConNombre({
    required this.nombreServicio,
    required this.horaInicio,
    required this.horaFin,
    required this.costoServicio,
  });
}

class DetalleCita {
  final int idDetalleCita;
  final int idServicio;
  final int idCita;
  final double descuento;
  

  DetalleCita(
      {required this.idDetalleCita,
      required this.idServicio,
      required this.idCita,
      required this.descuento});

  factory DetalleCita.fromJson(Map<String, dynamic> json) {
    return DetalleCita(
        idDetalleCita: json['idDetallePedido'],
        idServicio: json['idProducto'],
        idCita: json['idPedido'],
        descuento: json['cantidadProducto'].toDouble());
  }
}

class PageCitas extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const PageCitas(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser});

  @override
  State<PageCitas> createState() => _PageCitaState();
}

class _PageCitaState extends State<PageCitas> {
  bool _isCanceling = false;
  bool _loaded = false;
  List<Map<String, dynamic>> servicios = [];
  List<Map<String, dynamic>> citas = [];

  String fecha() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    String fecha = '$year-$month-$day';

    return fecha;
  }

  @override
  void initState() {
    super.initState();
    fetchCitas();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(
          clienteId: widget.clienteId,
          clienteCorreo: widget.clienteCorreo,
          clienteContrasena: widget.clienteContrasena,
          clientOrUser: widget.clientOrUser),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Citas",
              style: TextStyle(
                  fontFamily: GoogleFonts.quicksand().fontFamily,
                  fontSize: 35,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_loaded)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CircularProgressIndicator()), // Icono de carga
          Expanded(
              child: ListView.builder(
            itemCount: citas.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTileCard(
                  expandedColor: Color.fromARGB(255, 240, 240, 240),
                  baseColor: Color.fromARGB(255, 240, 240, 240),
                  title: Row(
                    children: [
                      Icon(
                        citas[index]['estado'] != 0 ? Icons.calendar_month : Icons.block,
                        color: citas[index]['estado'] != 0 ? Color.fromARGB(255, 0, 124, 173) : Color.fromARGB(255, 173, 0, 0),
                        size: 30,
                      ),
                      Text(
                          '  Fecha de la cita: ${citas[index]['detalles'][0]['fechaCita']}'),
                    ],
                  ),
                  subtitle: Text(
                      ' Cliente: ${citas[index]['cliente'][0]['nombreCliente']} ${citas[index]['cliente'][0]['apellidoCliente']} | ${citas[index]['cliente'][0]['cedula']} \n Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(citas[index]["costoTotal"])}'),
                  children: <Widget>[
                    // Otros elementos del pedido...
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: citas[index]['detalles'].length,
                        itemBuilder: (BuildContext context, int idx) {
                          return ListTile(
                              title: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      citas[index]['estado'] != 0 ? Icons.check_circle : Icons.cancel,
                                      color: citas[index]['estado'] != 0 ? Color.fromARGB(255, 0, 133, 173) : Color.fromARGB(255, 173, 0, 0),
                                    ),
                                    Text(
                                      '   ${citas[index]['detalles'][idx]['servicio'][0]['nombreServicio']}',
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(children: [
                                  Text(
                                    ' Hora inicio: ${citas[index]['detalles'][idx]['horaInicio']}\n Hora fin: ${citas[index]['detalles'][idx]['horaFin']}\n Costo: \$ ${NumberFormat('#,###', 'es_ES').format(citas[index]['detalles'][idx]['costoServicio'])}',
                                  ),
                                ]),
                              )
                            );
                        }),
                    Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: Color(0xFFa7e3e1)),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: [
                          if (citas[index]['estado'] == 1)
                          TextButton(
                                onPressed: () {
                                  if (citas[index]['estado'] == 1) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: const Text("Alerta!"),
                                              content: const Text(
                                                  "¿Seguro quieres cambiar el estado de la cita?"),
                                              actions: [
                                                if (_isCanceling)
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child:
                                                          CircularProgressIndicator()), // Icono de carga
                                                TextButton(
                                                    onPressed: _isCanceling
                                                        ? null
                                                        : () async {
                                                            setState(() {
                                                              _isCanceling =
                                                                  true;
                                                            });
                                                            bool success =
                                                                false;
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return PopScope(
                                                                  canPop:
                                                                      false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                                                  child:
                                                                      AlertDialog(
                                                                    title: const Text(
                                                                        "Cambiando estado"),
                                                                    content: Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                100),
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            success = await cambiarEstado(
                                                                citas[index][
                                                                    'idCita'], 2);
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1));

                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            if (success) {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => PageCitas(
                                                                          clienteId: widget
                                                                              .clienteId,
                                                                          clienteCorreo: widget
                                                                              .clienteCorreo,
                                                                          clienteContrasena: widget
                                                                              .clienteContrasena,
                                                                          clientOrUser:
                                                                              widget.clientOrUser)));
                                                            }
                                                          },
                                                    child:
                                                        const Text("Aceptar")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child:
                                                        const Text("Cancelar"))
                                              ]);
                                        });
                                  }
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.alarm,
                                      color: Colors.black54,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.0)),
                                    Text("Cambiar a 'En proceso'",
                                        style: TextStyle(color: Colors.black54))
                                  ],
                                )),
                                if (citas[index]['estado'] == 2)
                                TextButton(
                                onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: const Text("Alerta!"),
                                              content: const Text(
                                                  "¿Seguro quieres terminar la cita?"),
                                              actions: [
                                                if (_isCanceling)
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child:
                                                          CircularProgressIndicator()), // Icono de carga
                                                TextButton(
                                                    onPressed: _isCanceling
                                                        ? null
                                                        : () async {
                                                            setState(() {
                                                              _isCanceling =
                                                                  true;
                                                            });
                                                            bool success =
                                                                false;
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return PopScope(
                                                                  canPop:
                                                                      false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                                                  child:
                                                                      AlertDialog(
                                                                    title: const Text(
                                                                        "Cambiando estado"),
                                                                    content: Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                100),
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            success = await cambiarEstado(
                                                                citas[index][
                                                                    'idCita'], 2);
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1));

                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            if (success) {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => PageCitas(
                                                                          clienteId: widget
                                                                              .clienteId,
                                                                          clienteCorreo: widget
                                                                              .clienteCorreo,
                                                                          clienteContrasena: widget
                                                                              .clienteContrasena,
                                                                          clientOrUser:
                                                                              widget.clientOrUser)));
                                                            }
                                                          },
                                                    child:
                                                        const Text("Aceptar")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child:
                                                        const Text("Cancelar"))
                                              ]);
                                        });
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.black54,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.0)),
                                    Text("Terminar cita",
                                        style: TextStyle(color: Colors.black54))
                                  ],
                                )),
                            if(citas[index]['estado'] != 0 && citas[index]['estado'] != 3)
                            TextButton(
                                onPressed: () {
                                  if (citas[index]['estado'] != 0) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: const Text("Alerta!"),
                                              content: const Text(
                                                  "¿Seguro quieres cancelar la cita?"),
                                              actions: [
                                                if (_isCanceling)
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child:
                                                          CircularProgressIndicator()), // Icono de carga
                                                TextButton(
                                                    onPressed: _isCanceling
                                                        ? null
                                                        : () async {
                                                            setState(() {
                                                              _isCanceling =
                                                                  true;
                                                            });
                                                            bool success =
                                                                false;
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return PopScope(
                                                                  canPop:
                                                                      false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                                                  child:
                                                                      AlertDialog(
                                                                    title: const Text(
                                                                        "Cancelando cita"),
                                                                    content: Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                100),
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            success = await cambiarEstado(
                                                                citas[index][
                                                                    'idCita'], 0);
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1));

                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            if (success) {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => PageCitas(
                                                                          clienteId: widget
                                                                              .clienteId,
                                                                          clienteCorreo: widget
                                                                              .clienteCorreo,
                                                                          clienteContrasena: widget
                                                                              .clienteContrasena,
                                                                          clientOrUser:
                                                                              widget.clientOrUser)));
                                                            }
                                                          },
                                                    child:
                                                        const Text("Aceptar")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child:
                                                        const Text("Cancelar"))
                                              ]);
                                        });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.cancel,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "La cita ya está cancelada",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontFamily:
                                                          'Quicksand-SemiBold'),
                                                )
                                              ],
                                            ),
                                            duration: const Duration(
                                                milliseconds: 2000),
                                            width: 300,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 10),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                            ),
                                            backgroundColor: Colors.red));
                                  }
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.block,
                                      color: Colors.black54,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.0)),
                                    Text("Cancelar",
                                        style: TextStyle(color: Colors.black54))
                                  ],
                                )),
                          if (citas[index]['estado'] == 0)
                            const Column(
                              children: [
                                Icon(
                                  Icons.highlight_remove,
                                  color: Colors.black54,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Cancelada",
                                    style: TextStyle(color: Colors.black54))
                              ],
                            ),
                            if (citas[index]['estado'] == 3)
                            const Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.black54,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Terminada",
                                    style: TextStyle(color: Colors.black54))
                              ],
                            )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ))
        ],
      ),
    );
  }

  Future<bool> cambiarEstado(int id, int estado) async {
    final String uriCitas =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/citums/$id';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));

    final getCita = await http
        .get(Uri.parse(uriCitas), headers: {'authorization': basicAuth});
    if (getCita.statusCode == 200) {
      Map<String, dynamic> cita = jsonDecode(getCita.body);
      final String uriPutCita =
          'http://dylanbolivar1-001-site1.ftempurl.com/api/citums/$id';
      final response = await http.put(Uri.parse(uriPutCita),
          headers: {
            'authorization': basicAuth,
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            'idCita': cita['idCita'],
            'fechaRegistro': cita['fechaRegistro'],
            'costoTotal': cita['costoTotal'],
            'idCliente': cita['idCliente'],
            'estado': estado
          }));
      if (response.statusCode == 204) {
        return true;
      } else {}
    }
    return false;
  }

  Future<void> fetchCitas() async {
    final String uriCitas =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/citums';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriCitas),
      headers: <String, String>{
        'authorization': basicAuth,
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newCitas = [];
      for (var item in jsonData) {
        var detalles = await fetchDetallesCita(item['idCita']);

        var fechaCita = extractFechaCita(detalles);


        newCitas.add({
          'idCita': item['idCita'],
          'idCliente': item['idCliente'],
          'costoTotal': item['costoTotal'],
          'fechaCita': fechaCita,
          'estado': item['estado'],
          'cliente': await fetchCliente(item['idCliente']),
          'detalles': detalles,
        });
      }

      
      // Ordenar las citas por estado y luego por fecha ascendente
      newCitas.sort((a, b) {
        int estadoComparison = getEstadoPriority(a['estado']).compareTo(getEstadoPriority(b['estado']));
        if (estadoComparison != 0) {
          return estadoComparison;
        }
        // Comparar las fechas de manera ascendente si los estados tienen la misma prioridad
        return (a['fechaCita']).compareTo(b['fechaCita']);
      });

      setState(() {
        citas = newCitas;
        _loaded = true;
      });
    } else {}
  }

  int getEstadoPriority(int estado) {
    switch (estado) {
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      case 0:
      default:
        return 3;
    }
  }

  DateTime extractFechaCita(List<dynamic> detalles) {
    var fechaString = detalles[0]['fechaCita'];
    return DateTime.parse(fechaString);
  }

  Future<List<Map<String, dynamic>>> fetchDetallesCita(int idCita) async {
    final String uriDetallesCitas =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/detallecitums';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriDetallesCitas),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> detalles = [];
      for (var item in jsonData) {
        if (item['idCita'] == idCita) {
          String fechaCitaString = item['fechaCita'];
          DateTime fechaCita = DateTime.parse(fechaCitaString);
          String fechaFormateada =
              "${fechaCita.year}-${fechaCita.month.toString().padLeft(2, '0')}-${fechaCita.day.toString().padLeft(2, '0')}";


          detalles.add({
            'idDetalleCita': item['idDetalleCita'],
            'idServicio': item['idServicio'],
            'fechaCita': fechaFormateada,
            'fechaOrden': item['fechaCita'],
            'horaInicio': item['horaInicio'],
            'horaFin': item['horaFin'],
            'costoServicio': item['costoServicio'],
            'servicio': await fetchServicio(item['idServicio']),
          });
        }
      }
      return detalles;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchServicio(int idServicio) async {
    final String uriServicios =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/servicios';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriServicios),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> servicio = [];
      for (var item in jsonData) {
        if (item['idServicio'] == idServicio) {
          servicio.add({
            'nombreServicio': item['nombreServicio'],
          });
        }
      }
      return servicio;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCliente(int idCliente) async {
    final String uriCliente =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/id?id=$idCliente';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriCliente),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> cliente = [];
      cliente.add({
        'cedula': jsonData['idCliente'].toString(),
        'nombreCliente': jsonData['nombreCliente'],
        'apellidoCliente': jsonData['apellidoCliente']
      });

      return cliente;
    } else {
      return [];
    }
  }

  

  void _showExitoDialog(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.check_circle,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              errorMessage,
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Quicksand-SemiBold'),
            )
          ],
        ),
        duration: const Duration(milliseconds: 2000),
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 195, 106)));
  }
}
