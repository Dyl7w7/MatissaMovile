import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/widget/AppBar.dart';
import 'package:matissamovile/pages/widget/drawer.dart';

class MenuAdminPage extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const MenuAdminPage(
      {Key? key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser})
      : super(key: key);

  @override
  State<MenuAdminPage> createState() => _MenuAdminPageState();
}

class _MenuAdminPageState extends State<MenuAdminPage> {
  String username = "";
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    fetchUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(
            clienteId: widget.clienteId,
            clienteCorreo: widget.clienteCorreo,
            clienteContrasena: widget.clienteContrasena,
            clientOrUser: widget.clientOrUser),
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
              if (!_loaded) CircularProgressIndicator(),
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
                    'Bienvenido $username, a la tienda de belleza virtual Matissa',
                    style: TextStyle(
                        fontFamily: GoogleFonts.quicksand().fontFamily,
                        fontSize: 16),
                  ),
                )
            ],
          ),
        ));
  }

  Future<void> fetchUsuario() async {
    int clienteId = widget.clienteId;

    final String url =
        'http://matissaapi-001-site1.dtempurl.com/api/usuarios/id?id=$clienteId';
    final String usernameApi = '11182245';
    final String passwordApi = '60-dayfreetrial';

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));

    final response = await http.get(
      //Uri.parse('http://matissaapi-001-site1.dtempurl.com/api/clientes/id?id=$clienteId')
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(response.body);
      setState(() {
        username = userData['nombreUsuario'] ?? '';
        _loaded = true;
      });
    }
  }
}
