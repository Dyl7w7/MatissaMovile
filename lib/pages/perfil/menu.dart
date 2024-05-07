import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/widget/AppBar.dart';
import 'package:matissamovile/pages/widget/drawer.dart';

class MenuPage extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const MenuPage(
      {Key? key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena})
      : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String name = "";
  String lastName = "";
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    fetchCliente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(
        clienteId: widget.clienteId,
        clienteCorreo: widget.clienteCorreo,
        clienteContrasena: widget.clienteContrasena,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Bienvenido a Matissa',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 35,
                fontFamily: GoogleFonts.quicksand().fontFamily,
              ),
            ),
            if (!_loaded)
              CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                height: 190,
                width: 190, 
              ),
            ),
            
            if (_loaded)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                textAlign: TextAlign.center,
                '$name $lastName, Le damos la bienvenida a la tienda de belleza virtual de Matissa',
                style: TextStyle(
                  fontFamily: GoogleFonts.quicksand().fontFamily,
                  fontSize: 16
                ),
              ),
            )
            
          ],
        ),

      )
    );
  }

  Future<void> fetchCliente() async {
    int clienteId = widget.clienteId;

    final String url = 'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/id?id=$clienteId';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));
    
    
    final response = await http.get(
      //Uri.parse('http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/id?id=$clienteId')
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> clienteData = jsonDecode(response.body);
      setState(() {
        name = clienteData['nombreCliente'] ?? '';
        lastName = clienteData['apellidoCliente'] ?? '';
        _loaded = true;
      });
      print(clienteData);
    }
  }
}