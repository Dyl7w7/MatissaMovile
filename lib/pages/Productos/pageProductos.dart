import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:matissamovile/pages/widget/textoFrom.dart';
import '../widget/AppBar.dart';

class PageProductos extends StatefulWidget {
  final String clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PageProductos(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena});

  @override
  State<PageProductos> createState() => _PageProductosState();
}

class _PageProductosState extends State<PageProductos> {
  List<Map<String, dynamic>> productos = [];
  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(
          clienteId: widget.clienteId,
          clienteCorreo: widget.clienteCorreo,
          clienteContrasena: widget.clienteContrasena,
        ),
        body: ListView.builder(
            itemCount: productos.length,
            itemBuilder: (BuildContext ctx, index) {
              return Center(
                  child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '${productos[index]["idProducto"]}. ' +
                          productos[index]["nombreProducto"],
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    tileColor: const Color.fromARGB(255, 204, 204, 204),
                  ),
                  ListTile(
                      title: Text(
                    'Precio venta: ${productos[index]["precioVenta"]}',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 18),
                  )),
                  ListTile(
                    subtitle: Text('Estado: ${productos[index]["estado"]}'),
                  ),
                ],
              ));
            }));
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
      List<Map<String, dynamic>> newData = [];
      for (var item in jsonData) {
        newData.add({
          'idProducto': item['idProducto'],
          'nombreProducto': item['nombreProducto'],
          'precioVenta': item['precioVenta'],
          'estado': item['estado']
        });
      }

      setState(() {
        productos = newData;
      });

      print('Productos: $productos');
    } else {
      print('Error: ${response.statusCode}');
    }
  }
}
