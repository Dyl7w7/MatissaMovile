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

class DetallePedidoConNombre {
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  DetallePedidoConNombre({
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });
}

class DetallePedido {
  final int idDetallePedido;
  final int idProducto;
  final int idPedido;
  final int cantidadProducto;
  final double precioUnitario;

  DetallePedido(
      {required this.idDetallePedido,
      required this.idProducto,
      required this.idPedido,
      required this.cantidadProducto,
      required this.precioUnitario});

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
        idDetallePedido: json['idDetallePedido'],
        idProducto: json['idProducto'],
        idPedido: json['idPedido'],
        cantidadProducto: json['cantidadProducto'],
        precioUnitario: json['precioUnitario'].toDouble());
  }
}

class PageVentas extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const PageVentas(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser});

  @override
  State<PageVentas> createState() => _PageVentasState();
}

class _PageVentasState extends State<PageVentas> {
  bool _loaded = false;
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> pedidos = [];
  List<Map<String, dynamic>> citas = [];
  List<Map<String, dynamic>> servicios = [];

  // Ordenar los pedidos por fecha de manera descendente
      
  //late List<DetallePedido> detallePedidos = [];
  //Map<int, int> detallePedido = {};
  String selectedProduct = "";
  int cantidadProducto = 1;
  double precioProducto = 0.0;
  double costoTotal = 0.0;

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
    fetchPedidos();
    fetchCitas();

    citas.sort((a, b) => DateTime.parse(b['detalle'][0]['fechaCita'])
          .compareTo(DateTime.parse(a['detalle'][0]['fechaCita'])));
    //fetchProductos();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(
          clienteId: widget.clienteId,
          clienteCorreo: widget.clienteCorreo,
          clienteContrasena: widget.clienteContrasena,
          clientOrUser: widget.clientOrUser),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Citas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(60, 195, 189, 1),
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;
  List<Widget> get _widgetOptions => <Widget>[
    /* ------------------------- PEDIDOS ------------------------------ */
    Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Pedidos",
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
            itemCount: pedidos.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTileCard(
                  expandedColor: Color.fromARGB(255, 240, 240, 240),
                  baseColor: Color.fromARGB(255, 240, 240, 240),
                  title: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Color.fromARGB(255, 0, 173, 14),
                        size: 30,
                      ),
                      Text(
                          '  Fecha de la venta: ${pedidos[index]['fechaPedido']}'),
                    ],
                  ),
                  subtitle: Text(
                      ' Cliente: ${pedidos[index]['cliente'][0]['nombreCliente']} ${pedidos[index]['cliente'][0]['apellidoCliente']} - ${pedidos[index]['cliente'][0]['cedula']} \n Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(pedidos[index]["precioTotalPedido"])}'),
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: pedidos[index]['detalles'].length,
                        itemBuilder: (BuildContext context, int idx) {
                          return ListTile(
                              title: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Color.fromARGB(255, 0, 173, 14),
                                    ),
                                    Text(
                                      '   ${pedidos[index]['detalles'][idx]['producto'][0]['nombreProducto']}',
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(children: [
                                  Text(
                                    'Subtotal: \$ ${NumberFormat('#,###', 'es_ES').format(pedidos[index]['detalles'][idx]['precioUnitario'])} | ${pedidos[index]['detalles'][idx]['cantidadProducto']} unidades',
                                  ),
                                ]),
                              )
                            );
                        }),
                  ],
                ),
              );
            },
          ))
        ],
      ),

      /* ------------------------- CITAS ------------------------------ */
      Column(
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
                        Icons.calendar_month,
                        color: Color.fromARGB(255, 0, 173, 14),
                        size: 30,
                      ),
                      Text(
                          '  Fecha de la cita: ${citas[index]['detalles'][0]['fechaCita']}'),
                    ],
                  ),
                  subtitle: Text(
                      ' Cliente: ${citas[index]['cliente'][0]['nombreCliente']} ${citas[index]['cliente'][0]['apellidoCliente']} | ${citas[index]['cliente'][0]['cedula']} \n Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(citas[index]["costoTotal"])}'),
                  children: <Widget>[
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
                                      Icons.check_circle,
                                      color: Color.fromARGB(255, 0, 173, 14),
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
                  ],
                ),
              );
            },
          ))
        ],
      ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        if (item['estado'] == 3) {
          newCitas.add({
            'idCita': item['idCita'],
            'idCliente': item['idCliente'],
            'costoTotal': item['costoTotal'],
            'cliente': await fetchCliente(item['idCliente']),
            'detalles': await fetchDetallesCita(item['idCita']),

          });
        }
      }

      setState(() {
        citas = newCitas;
        _loaded = true;
      });
    } else {}
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

  Future<void> fetchPedidos() async {
    final String uriPedidos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriPedidos),
      headers: <String, String>{
        'authorization': basicAuth,
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newPedidos = [];
      for (var item in jsonData) {
        if (item['estado'] == 2) {
          String fechaPedidoString = item['fechaPedido'];
          DateTime fechaPedido = DateTime.parse(fechaPedidoString);
          String fechaFormateada =
              "${fechaPedido.year}-${fechaPedido.month.toString().padLeft(2, '0')}-${fechaPedido.day.toString().padLeft(2, '0')}";
          newPedidos.add({
            'idPedido': item['idPedido'],
            'idCliente': item['idCliente'],
            'fechaPedido': fechaFormateada,
            'precioTotalPedido': item['precioTotalPedido'],
            'estado': item['estado'],
            'cliente': await fetchCliente(item['idCliente']),
            'detalles': await fetchDetallesPedido(item['idPedido']),

          });
        }
      }

      // Ordenar los pedidos por fecha de manera descendente
      newPedidos.sort((a, b) => DateTime.parse(b['fechaPedido'])
          .compareTo(DateTime.parse(a['fechaPedido'])));

      setState(() {
        pedidos = newPedidos;
        _loaded = true;
      });
    } else {}
  }

  Future<List<Map<String, dynamic>>> fetchDetallesPedido(int idPedido) async {
    final String uriDetallesPedido =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/detallepedidos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriDetallesPedido),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> detalles = [];
      for (var item in jsonData) {
        if (item['idPedido'] == idPedido) {
          detalles.add({
            'idDetallePedido': item['idDetallePedido'],
            'idProducto': item['idProducto'],
            'cantidadProducto': item['cantidadProducto'],
            'precioUnitario': item['precioUnitario'],
            'producto': await fetchProducto(item['idProducto']),
          });
        }
      }
      return detalles;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducto(int idProducto) async {
    final String uriProductos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/productos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriProductos),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> producto = [];
      for (var item in jsonData) {
        if (item['idProducto'] == idProducto) {
          producto.add({
            'nombreProducto': item['nombreProducto'],
          });
        }
      }
      return producto;
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
