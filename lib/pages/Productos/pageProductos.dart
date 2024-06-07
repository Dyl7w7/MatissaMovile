import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:intl/intl.dart';
import '../widget/AppBar.dart';

class Product {
  final int id;
  final String nombre;
  final double precio;

  Product({required this.id, required this.nombre, required this.precio});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['idProducto'],
      nombre: json['nombreProducto'],
      precio: json['precioVenta'].toDouble(),
    );
  }
}

class PageProductos extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const PageProductos({
    super.key,
    required this.clienteId,
    required this.clienteCorreo,
    required this.clienteContrasena,
    required this.clientOrUser,
  });

  @override
  State<PageProductos> createState() => _PageProductosState();
}

class _PageProductosState extends State<PageProductos> {
  TextEditingController _controller = TextEditingController();
  late List<Product> productos = [];
  List<Product> productosFiltrados = [];
  String status = "";
  bool _loaded = false;

  @override
  void initState() {
    fetchProductos();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(
          clienteId: widget.clienteId,
          clienteCorreo: widget.clienteCorreo,
          clienteContrasena: widget.clienteContrasena,
          clientOrUser: widget.clientOrUser,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Container(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Color de fondo del título
                child: ListTile(
                  title: Text(
                    "Productos disponibles",
                    style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Color del texto del título
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (!_loaded) CircularProgressIndicator(),
            if (_loaded)
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Container(
                  color: Color.fromARGB(
                      255, 255, 255, 255), // Color de fondo del título
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        // Filtrar la lista de productos según el término de búsqueda
                        productosFiltrados = productos
                            .where((producto) => producto.nombre
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            Expanded(
                child: ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Container(
                          margin: EdgeInsets.all(6),
                          child: Column(children: [
                            ListTile(
                              tileColor: Color.fromARGB(255, 240, 240, 240),
                              title: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_shopping_cart,
                                      color: Color.fromARGB(255, 0, 193, 207),
                                      size: 30,
                                    ),
                                    Text(
                                      '${productosFiltrados[index].nombre}',
                                    ),
                                  ],
                                ),
                              ),
                              //subtitle: Text('\$ ${productos[index].precio.toStringAsFixed(2)}'),
                              subtitle: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  ' Precio venta: \$ ${NumberFormat('#,###', 'es_ES').format(productosFiltrados[index].precio)}',
                                ),
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: Color.fromARGB(255, 0, 207, 17),
                                size: 30,
                              ),
                            ),
                          ]));
                    }))
          ],
        ));
  }

  Future<void> fetchProductos() async {
    final String url =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/productos';
    final String username = '11173482';
    final String password = '60-dayfreetrial';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      //Uri.parse('dylanbolivar1-001-site1.ftempurl.com/api/productos')
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Product> newData = [];
      for (var item in jsonData) {
        if (item['estado'] ==
            1 /*|| item['estado'] == 2 || item['estado'] == 3*/) {
          newData.add(Product.fromJson(item));
        }
      }

      setState(() {
        productos = newData;
        productosFiltrados = newData;
        _loaded = true;
      });
    } else {}
  }
}
