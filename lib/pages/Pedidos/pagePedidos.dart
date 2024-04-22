import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:matissamovile/pages/widget/textoFrom.dart';
import '../widget/AppBar.dart';

class PagePedidos extends StatefulWidget {
  final String clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PagePedidos({super.key, required this.clienteId, required this.clienteCorreo, required this.clienteContrasena});

  @override
  State<PagePedidos> createState() => _PagePedidosState();
}

class _PagePedidosState extends State<PagePedidos> {
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> pedidos = [];
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
    fetchProductos();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(clienteId: widget.clienteId, clienteCorreo: widget.clienteCorreo, clienteContrasena: widget.clienteContrasena,),
      body: Column(
        children: [
           Text("Mis pedidos", style: TextStyle(fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 35, fontWeight: FontWeight.bold),),
          Expanded(
            child: ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ExpansionTileCard(
                    initialElevation: 2,
                    expandedColor: const Color.fromARGB(255, 216, 216, 216),
                    baseColor: const Color.fromRGBO(226, 212, 255, 1),
                    title: Text("Producto: ${pedidos[index]['producto']}"),
                    subtitle: Text("Fecha registro: ${pedidos[index]['fechaPedido']}"),
                    leading: const Icon(Icons.shopping_cart),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                            ListTile(
                              title: const Text('Estado'),
                              subtitle: pedidos[index]['estado'] == 1
                                  ? const Text('Activo')
                                  : const Text('Cancelado'),
                              trailing: pedidos[index]['estado'] == 1
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.block),
                            ),
                            ListTile(
                              title: const Text('Precio de producto'),
                              subtitle: Text('${pedidos[index]['precioUnitario']}'),
                              trailing: const Icon(Icons.monetization_on),
                            ),
                            ListTile(
                              title: const Text('cantidad'),
                              subtitle:Text('${pedidos[index]['cantidadProducto']}'),
                              trailing: const Icon(Icons.inventory_2),
                            ),
                            ListTile(
                              title: const Text('Costo total'),
                              subtitle:Text('${pedidos[index]['precioTotalPedido']}'),
                              trailing: const Icon(Icons.monetization_on),
                            )
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          color: Color(0xFFa7e3e1)),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: [
                          TextButton(
                            onPressed: () async {
                              _showEditarModal(context, pedidos[index]);
                            }, 
                            child: const  Column(
                              children: [
                                Icon(Icons.edit, color: Colors.black54,),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Editar", style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: const Text("Alerta!"),
                                        content: const Text("¿Seguro quieres eliminar la cita?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                await deleteData(pedidos[index]['_id']);
                                                await fetchPedidos();
                                                Navigator.of(context).pop();
                                                _showExitoDialog(context, "Pedido eliminado");
                                              },
                                              child: const Text("Aceptar")),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Cancelar"))
                                        ]);
                                  });
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.black54,
                                ),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Eliminar",
                                    style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              if(pedidos[index]['estado'] == 1){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Alerta!"),
                                      content: const Text(
                                          "¿Seguro quieres cancelar el pedido?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await cambiarEstado(
                                                  pedidos[index]['_id']);
                                              Navigator.of(context).pop();
                                              _showExitoDialog(context, "Pedido cancelado");
                                            },
                                            child: const Text("Aceptar")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(),
                                            child: const Text("Cancelar"))
                                      ]
                                    );
                                  }
                                );
                              }else{
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
                                      backgroundColor: Colors.red
                                  )
                                );
                              }
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.block,
                                  color: Colors.black54,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Cancelar",
                                    style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                        ],
                      ),
                    )
                    ],
                  ),
                );
              },
            ) 
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showModal(context);
        },
      ),
    );
  }

  Future<void> _showModal(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            double screenWidth = MediaQuery.of(context).size.width;
            return Container(
              padding: EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 44, 44, 44),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              child: Column(
                children: [
                  const Text("Producto",style: TextStyle(color: Colors.white ),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35.0),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value:
                          selectedProduct.isNotEmpty ? selectedProduct : null,
                      items: productos.map((producto) {
                        return DropdownMenuItem<String>(
                          value: producto['nombre'],
                          child: Text(producto['nombre']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProduct = newValue!;
                          precioProducto = productos.firstWhere((producto) =>
                              producto['nombre'] == newValue)['precio'];
                          _actualizarCostoTotal();
                        });
                      },
                      hint: Text('Selecciona un producto'),
                      style: TextStyle(
                        color: Colors.black, // Color del texto cerrado
                        fontSize: 16.0,
                      ),
                      iconSize: 24.0,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors
                            .transparent, // Puedes cambiar el color de la línea de abajo o hacerla transparente
                      ),
                      isExpanded: true,
                    ),
                  ),
                  const Text("Precio",style: TextStyle(color: Colors.white ),),
                  Label(screenWidth: screenWidth, dato: '\$${precioProducto.toStringAsFixed(2)}'),
                  const Text("Cantidad",style: TextStyle(color: Colors.white ),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: screenWidth,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35.0),
                      color: Colors.white, // Puedes personalizar el color y el grosor del borde
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none
                        ),
                      onChanged: (value) {
                        setState(() {
                          cantidadProducto = int.tryParse(value) ?? 1;
                          _actualizarCostoTotal();
                        });
                      },
                    ),
                  ),
                  const Text("Costo total",style: TextStyle(color: Colors.white ),),
                  Label(screenWidth: screenWidth, dato: '\$${costoTotal.toStringAsFixed(2)}'),
                  SizedBox(height: 20,),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar")),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            onPressed: () async {
                              await _enviarPedido(null);
                              await fetchPedidos();
                              Navigator.of(context).pop();
                              _showExitoDialog(context, "Pedido hecho");
                            },
                            child: Text('Pedir'),
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditarModal(BuildContext context, Map<String, dynamic> pedido) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
              return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            double screenWidth = MediaQuery.of(context).size.width;
            return Container(
              padding: EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 44, 44, 44),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              child: Column(
                children: [
                  const Text("Producto",style: TextStyle(color: Colors.white ),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35.0),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value:
                          selectedProduct.isNotEmpty ? selectedProduct : null,
                      items: productos.map((producto) {
                        return DropdownMenuItem<String>(
                          value: producto['nombre'],
                          child: Text(producto['nombre']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProduct = newValue!;
                          precioProducto = productos.firstWhere((producto) =>
                              producto['nombre'] == newValue)['precio'];
                          _actualizarCostoTotal();
                        });
                      },
                      hint: Text('Selecciona un producto'),
                      style: TextStyle(
                        color: Colors.black, // Color del texto cerrado
                        fontSize: 16.0,
                      ),
                      iconSize: 24.0,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors
                            .transparent, // Puedes cambiar el color de la línea de abajo o hacerla transparente
                      ),
                      isExpanded: true,
                    ),
                  ),
                  const Text("Precio",style: TextStyle(color: Colors.white ),),
                  Label(screenWidth: screenWidth, dato: '\$${precioProducto.toStringAsFixed(2)}'),
                  const Text("Cantidad",style: TextStyle(color: Colors.white ),),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: screenWidth,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35.0),
                      color: Colors.white, // Puedes personalizar el color y el grosor del borde
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none
                        ),
                      onChanged: (value) {
                        setState(() {
                          cantidadProducto = int.tryParse(value) ?? 1;
                          _actualizarCostoTotal();
                        });
                      },
                    ),
                  ),
                  const Text("Costo total",style: TextStyle(color: Colors.white ),),
                  Label(screenWidth: screenWidth, dato: '\$${costoTotal.toStringAsFixed(2)}'),
                  SizedBox(height: 20,),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar")),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            onPressed: () async {
                              await _enviarPedido(pedido);
                              await fetchPedidos();
                              Navigator.pop(context);
                              _showExitoDialog(context, "Pedido editado");
                            },
                            child: Text('Editar'),
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _actualizarCostoTotal() {
    costoTotal = cantidadProducto * precioProducto;
  }

  Future<void> cambiarEstado(String id) async {
    final url = Uri.parse('https://matissa.onrender.com/api/pedidos/$id');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'estado': 0})
    );

    if(response.statusCode == 200){
      print('Estado actualizado: ${response.body}');
      fetchPedidos();
    }
  }

Future<void> _enviarPedido(Map<String, dynamic>? pedido) async {
    final url = pedido != null && pedido.containsKey('_id')
        ? Uri.parse("https://matissa.onrender.com/api/pedidos/${pedido['_id']}")
        : Uri.parse("https://matissa.onrender.com/api/pedidos");

    final response = await (pedido != null && pedido.containsKey('_id')
        ? http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'cliente': widget.clienteCorreo,
              'fechaPedido': fecha(),
              'precioUnitario': precioProducto,
              'producto': selectedProduct,
              'cantidadProducto': cantidadProducto,
              'precioTotalPedido': costoTotal,
              'estado': 1
            }),
          )
        : http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'cliente': widget.clienteCorreo,
              'fechaPedido': fecha(),
              'precioUnitario': precioProducto,
              'producto': selectedProduct,
              'cantidadProducto': cantidadProducto,
              'precioTotalPedido': costoTotal,
              'estado': 1
            }),
          ));

    if (response.statusCode == 200) {
      print(
          'Pedido ${pedido != null && pedido.containsKey('_id') ? 'actualizado' : 'creado'}: ${response.body}');
      Navigator.pop(context);
      _showExitoDialog(context,
          "Pedido ${pedido != null && pedido.containsKey('_id') ? 'actualizado' : 'creado'}");
    } else {
      print('Error: ${response.statusCode}');
    }
  }



    Future<void> fetchPedidos() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/pedidos'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newCitas = [];
      for (var item in jsonData) {
        if (item['cliente'] == widget.clienteCorreo) {
          newCitas.add({
            '_id': item['_id'],
            'cliente': item['cliente'],
            'fechaPedido': item['fechaPedido'],
            'precioUnitario': item['precioUnitario'],
            'producto': item['producto'],
            'cantidadProducto': item['cantidadProducto'],
            'precioTotalPedido': item['precioTotalPedido'],
            'estado': item['estado'],
            // Agrega más campos según la estructura de tus citas
          });
        }
      }

      setState(() {
        pedidos = newCitas;
      });

      print('Pedidos: $pedidos');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

    Future<void> fetchProductos() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/productos'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newData = [];
      for (var item in jsonData) {
        newData.add({
          'id': item['_id'],
          'nombre': item['nombre'],
          'precio': item['precioVenta'],
          'duracion': item['saldoInventario'],
        });
      }

      setState(() {
        productos = newData;
      });

      print('Servicios: $productos');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

    Future<void> deleteData(String idPedido) async {
    final response = await http
        .delete(Uri.parse('https://matissa.onrender.com/api/pedidos/$idPedido'));

    if (response.statusCode == 200) {
      // La respuesta fue exitosa
      print('Response data: ${response.body}');
    } else {
      // Ocurrió un error
      print('Error: ${response.statusCode}');
    }
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
