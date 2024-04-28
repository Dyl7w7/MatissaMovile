import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/Pedidos/pageDetallePedido.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:intl/intl.dart';
import '../widget/AppBar.dart';

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

  DetallePedido({
    required this.idDetallePedido,
    required this.idProducto,
    required this.idPedido,
    required this.cantidadProducto,
    required this.precioUnitario
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      idDetallePedido: json['idDetallePedido'],
      idProducto: json['idProducto'],
      idPedido: json['idPedido'],
      cantidadProducto: json['cantidadProducto'],
      precioUnitario: json['precioUnitario'].toDouble()
    );
  }
}

class PagePedido extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PagePedido(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena});

  @override
  State<PagePedido> createState() => _PagePedidoState();
}

class _PagePedidoState extends State<PagePedido> {
  bool _isCanceling = false;
  //bool _isDeleting = false;
  bool _isCreating = false;
  //bool _isEditing = false;
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> pedidos = [];
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
    _isCreating = false;
    super.initState();
    fetchPedidos();
    //fetchProductos();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(
        clienteId: widget.clienteId,
        clienteCorreo: widget.clienteCorreo,
        clienteContrasena: widget.clienteContrasena,
      ),
      body: Column(
        children: [
          Text(
            "Mis pedidos",
            style: TextStyle(
                fontFamily: GoogleFonts.quicksand().fontFamily,
                fontSize: 35,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTileCard(

                  title: Text('Fecha del pedido: ${pedidos[index]['fechaPedido']}'),
                  subtitle: Text(
                    'Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(pedidos[index]["precioTotalPedido"])}'
                  ),
                  children: <Widget>[
                    // Otros elementos del pedido...
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: pedidos[index]['detalles'].length,
                      itemBuilder: (BuildContext context, int idx) {
                        return ListTile(
                          title: Text(
                            '${pedidos[index]['detalles'][idx]['producto'][0]['nombreProducto']}',
                          ),
                          subtitle: Text(
                            'Cantidad: ${pedidos[index]['detalles'][idx]['cantidadProducto']} | Precio: \$ ${NumberFormat('#,###', 'es_ES').format(pedidos[index]['detalles'][idx]['precioUnitario'])}',
                          ),
                // children: <Widget>[
                //   ListView.builder(
                //     shrinkWrap: true,
                //     itemCount: pedidos[index]['detalles'][idx]['producto'].length,
                //     itemBuilder: (BuildContext context, int productIdx) {
                //       return ListTile(
                //         title: Text(
                //           '${pedidos[index]['detalles'][idx]['producto'][productIdx]['nombreProducto']}',
                //         ),
                //         // Otros detalles del producto, si es necesario
                //       );
                //     },
                //   ),
                // ],
              );
            }                
          ),
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
                         
                          if (pedidos[index]['estado'] == 1)
                            TextButton(
                                onPressed: () {
                                  if (pedidos[index]['estado'] == 1) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: const Text("Alerta!"),
                                              content: const Text(
                                                  "¿Seguro quieres cancelar el pedido?"),
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
                                                            bool success = false;
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                                              builder: (BuildContext context) {
                                                                return PopScope(
                                                                  canPop: false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                                                  child: AlertDialog(
                                                                    title: const Text("Cancelando pedido"),
                                                                    content: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 100),
                                                                      child: CircularProgressIndicator()
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            success = await cambiarEstado(pedidos[index]['idPedido']);
                                                            await Future.delayed(Duration(seconds: 1));

                                                            Navigator.of(context).pop();

                                                            if (success) {
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => PagePedido(
                                                                    clienteId: widget.clienteId,
                                                                    clienteCorreo: widget.clienteCorreo,
                                                                    clienteContrasena: widget.clienteContrasena,
                                                                  )));
                                                            }
                                                          },
                                                    child:
                                                        const Text("Aceptar")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context).pop(),
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
                                                  "El pedido ya esta cancelado",
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
                          if (pedidos[index]['estado'] == 0)
                            const Column(
                              children: [
                                Icon(
                                  Icons.highlight_remove,
                                  color: Colors.black54,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Cancelado",
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PageDetallePedido(
                      clienteId: widget.clienteId,
                      clienteCorreo: widget.clienteCorreo,
                      clienteContrasena: widget.clienteContrasena,
                    )));
          setState(() {
            _isCreating = false;
          });
          //_showModal(context);
        },
      ),
    );
  }

  

  Future<bool> cambiarEstado(int id) async {
    final String uriPedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos/id?id=$id';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));

    final getPedido = await http.get(
      Uri.parse(uriPedidos),
      headers: {'authorization': basicAuth}
    );
    if (getPedido.statusCode == 200){
      Map<String, dynamic> pedido = jsonDecode(getPedido.body);
      final String uriPutPedido = 'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos/$id';
      final response = await http.put(
        Uri.parse(uriPutPedido),
        headers: {'authorization': basicAuth, "Content-Type": "application/json"},
        body: jsonEncode({
          'idPedido': pedido['idPedido'],
          'idCliente': pedido['idCliente'],
          'fechaPedido': pedido['fechaPedido'],
          'precioTotalPedido': pedido['precioTotalPedido'],
          'estado': 0
        })
      );
      final String uriGetDetallePedido = 'http://dylanbolivar1-001-site1.ftempurl.com/api/detallePedidos';
      final getDetallePedido = await http.get(
        Uri.parse(uriGetDetallePedido),
        headers: {'authorization': basicAuth}
      );
      List<dynamic> detallePedido = jsonDecode(getDetallePedido.body);
      for (var item in detallePedido) {
        if(item['idPedido'] == id){
          final String uriProducto = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/id?id=${item['idProducto']}';
          final getProducto = await http.get(
            Uri.parse(uriProducto),
            headers: {'authorization': basicAuth}
          );
          Map<String, dynamic> productos = jsonDecode(getProducto.body);
          final String uriPutProducto = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/${item['idProducto']}';
          final response = await http.put(
            Uri.parse(uriPutProducto),
            headers: {'authorization': basicAuth, "Content-Type": "application/json"},
            body: jsonEncode({
              'idProducto': productos['idProducto'],
              'nombreProducto': productos['nombreProducto'],
              'descripcion': productos['descripcion'],
              'fechaCaducidad': productos['fechaCaducidad'],
              'precioVenta': productos['precioVenta'],
              'saldoInventario': productos['saldoInventario'] + item['cantidadProducto'],
              'estado': productos['estado']
            })
          );
          if (response.statusCode == 204){
            print('Cantidad reestablecida: ${item['cantidadProducto']}, ${productos['nombreProducto']}');
          }
        }
      }
      
      if (response.statusCode == 204) {
        print('Estado actualizado: ${response.body}');
        return true;
      } else {
        print('Error: ${response.statusCode}');
      }
    }
    return false;
  }

  Future<void> fetchPedidos() async {
    final String uriPedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
      Uri.parse(uriPedidos),
      headers: <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newPedidos = [];
      for (var item in jsonData) {
        if (item['idCliente'] == widget.clienteId && item['estado'] == 1) {
          String fechaPedidoString = item['fechaPedido'];
          DateTime fechaPedido = DateTime.parse(fechaPedidoString); // Convertir la cadena en un objeto DateTime
          // Formatear la fecha como "yyyy-mm-dd"
          String fechaFormateada = "${fechaPedido.year}-${fechaPedido.month.toString().padLeft(2, '0')}-${fechaPedido.day.toString().padLeft(2, '0')}";
          newPedidos.add({
            'idPedido': item['idPedido'],
            'idCliente': item['idCliente'],
            'fechaPedido': fechaFormateada,
            'precioTotalPedido': item['precioTotalPedido'],
            'estado': item['estado'],
            'detalles': await fetchDetallesPedido(item['idPedido']),
          });
        }
      }

      setState(() {
        pedidos = newPedidos;
      });

      print('Pedidos: $pedidos');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetallesPedido(int idPedido) async {
    final String uriDetallesPedido = 'http://dylanbolivar1-001-site1.ftempurl.com/api/detallepedidos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
    Uri.parse(uriDetallesPedido),
    headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    List<Map<String, dynamic>> detalles = [];
    for (var item in jsonData) {
      if(item['idPedido'] == idPedido){
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
    print('Error: ${response.statusCode}');
    return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducto(int idProducto) async {
    final String uriProductos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    final response = await http.get(
    Uri.parse(uriProductos),
    headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    List<Map<String, dynamic>> producto = [];
    for (var item in jsonData) {
      if(item['idProducto'] == idProducto){
        producto.add({
        'nombreProducto': item['nombreProducto'],
        });
      }
    }
    return producto;
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  }

  // Future<void> fetchPedidos() async {
  //   final String uriPedidos = 'https://http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
  //   final String usernameApi = '11173482';
  //   final String passwordApi = '60-dayfreetrial';
  //   final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
  //   final response = await http.get(
  //     Uri.parse(uriPedidos),
  //     headers: <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = jsonDecode(response.body);
  //     List<Map<String, dynamic>> newPedidos = [];
  //     for (var item in jsonData) {
  //       if (item['idCliente'] == widget.clienteId) {
  //         newPedidos.add({
  //           'idPedido': item['idPedido'],
  //           'idCliente': item['idCliente'],
  //           'fechaPedido': item['fechaPedido'],
  //           'precioTotalPedido': item['precioTotalPedido'],
  //           'estado': item['estado'],
  //         });
  //       }
  //     }

  //     setState(() {
  //       pedidos = newPedidos;
  //     });

  //     print('Pedidos: $pedidos');
  //   } else {
  //     print('Error: ${response.statusCode}');
  //   }
  // }

//   Future<void> fetchProductos() async {
//     final response =
//         await http.get(Uri.parse('https://http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos'));

//     if (response.statusCode == 200) {
//       List<dynamic> jsonData = jsonDecode(response.body);
//       List<Map<String, dynamic>> newData = [];
//       for (var item in jsonData) {
//         newData.add({
//           'id': item['idPedido'],
//           'idCliente': item['idCliente'],
//           'fechaPedido': item['fechaPedido'],
//           'precioTotalPedido': item['precioTotalPedido'],
//           'estado': item['estado']
//         });
//       }

//       setState(() {
//         productos = newData;
//       });

//       print('Servicios: $productos');
//     } else {
//       print('Error: ${response.statusCode}');
//     }
//   }

  
// }

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