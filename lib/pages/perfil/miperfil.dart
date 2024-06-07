import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/perfil/menu.dart';
import 'package:matissamovile/pages/widget/AppBar.dart';
import 'package:matissamovile/pages/widget/drawer.dart';

class PerfilPage extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const PerfilPage(
      {Key? key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser})
      : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _nombres = "";
  String _apellidos = "";
  String _direccion = "";
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchCliente();
  }

  List<String> list = <String>["Medellín"];
  String dropdownValue = "Medellín";

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _lastPasswordController = TextEditingController();
  String _newPasswordController = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(
            clienteId: widget.clienteId,
            clienteCorreo: widget.clienteCorreo,
            clienteContrasena: widget.clienteContrasena,
            clientOrUser: widget.clientOrUser),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Mi perfil',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                    ),
                  ),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Padding(
                        //     padding: const EdgeInsets.only(top: 15),
                        //     child: TextFormField(
                        //       controller: _nombresController,
                        //       readOnly: true,
                        //       style: TextStyle(
                        //         fontFamily: GoogleFonts.quicksand().fontFamily,
                        //       ),
                        //       decoration: InputDecoration(
                        //           hintText: 'Nombres',
                        //           hintStyle: const TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               fontFamily: 'Quicksand-SemiBold'),
                        //           focusedBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(20)),
                        //           enabledBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(35)),
                        //           filled: true),
                        //       validator: (value) {
                        //         if (value == null || value.isEmpty) {
                        //           return 'Por favor digite el nombre';
                        //         }
                        //         return null;
                        //       },
                        //     )),
                        // Padding(
                        //     padding: const EdgeInsets.only(top: 15),
                        //     child: TextFormField(
                        //       controller: _apellidosController,
                        //       readOnly: true,
                        //       style: TextStyle(
                        //         fontFamily: GoogleFonts.quicksand().fontFamily,
                        //       ),
                        //       decoration: InputDecoration(
                        //           hintText: 'Apellidos',
                        //           hintStyle: const TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               fontFamily: 'Quicksand-SemiBold'),
                        //           focusedBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(20)),
                        //           enabledBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(35)),
                        //           filled: true),
                        //       validator: (value) {
                        //         if (value == null || value.isEmpty) {
                        //           return 'Por favor digite el apellido';
                        //         }
                        //         return null;
                        //       },
                        //     )),
                        // Padding(
                        //     padding: const EdgeInsets.only(top: 15),
                        //     child: TextFormField(
                        //       controller: _direccionController,
                        //       readOnly: true,
                        //       style: TextStyle(
                        //         fontFamily: GoogleFonts.quicksand().fontFamily,
                        //       ),
                        //       decoration: InputDecoration(
                        //           hintText: 'Dirección',
                        //           hintStyle: const TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               fontFamily: 'Quicksand-SemiBold'),
                        //           focusedBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(20)),
                        //           enabledBorder: OutlineInputBorder(
                        //               borderSide: const BorderSide(
                        //                   width: 0, style: BorderStyle.none),
                        //               borderRadius: BorderRadius.circular(35)),
                        //           filled: true),
                        //       validator: (value) {
                        //         if (value == null || value.isEmpty) {
                        //           return 'Por favor digite su dirección';
                        //         }
                        //         return null;
                        //       },
                        //     )),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 15),
                        //   child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: <Widget>[
                        //         Text(
                        //           'Ciudad:',
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               fontSize: 16,
                        //               fontFamily:
                        //                   GoogleFonts.quicksand().fontFamily),
                        //         ),
                        //         const SizedBox(width: 50),
                        //         DropdownMenu<String>(
                        //           textStyle: TextStyle(
                        //             fontFamily:
                        //                 GoogleFonts.quicksand().fontFamily,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //           initialSelection: list.first,
                        //           onSelected: (String? value) {
                        //             setState(() {
                        //               dropdownValue = value!;
                        //             });
                        //           },
                        //           dropdownMenuEntries: list
                        //               .map<DropdownMenuEntry<String>>(
                        //                   (String value) {
                        //             return DropdownMenuEntry<String>(
                        //                 value: value, label: value);
                        //           }).toList(),
                        //         ),
                        //       ]),
                        // ),
                        Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextFormField(
                              controller: _lastPasswordController,
                              obscureText: true,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  hintText: 'Contraseña actual',
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.quicksand().fontFamily),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(20)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(35)),
                                  filled: true),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "La contraseña es necesaria";
                                } else if (value.length < 10 ||
                                    value.length > 20) {
                                  return "La contraseña debe tener al menos 10 caracteres y máximo 20 caracteres.";
                                } else {
                                  return null;
                                }
                              },
                            )),
                        Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextFormField(
                              obscureText: true,
                              onChanged: (value) {
                                setState(() {
                                  _newPasswordController = value;
                                });
                              },
                              decoration: InputDecoration(
                                  hintText: 'Nueva contraseña',
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.quicksand().fontFamily),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(20)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(35)),
                                  filled: true),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "La contraseña es necesaria";
                                } else if (value.length < 10 ||
                                    value.length > 20) {
                                  return "La contraseña debe tener al menos 10 caracteres y máximo 20 caracteres.";
                                } else {
                                  return null;
                                }
                              },
                            )),
                        Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: TextFormField(
                              obscureText: true,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  hintText: 'Confirme la nueva contraseña',
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.quicksand().fontFamily),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(20)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius: BorderRadius.circular(35)),
                                  filled: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Confirme su contraseña";
                                } else if (value != _newPasswordController) {
                                  return "Las contraseñas no coinciden";
                                } else {
                                  return null;
                                }
                              },
                            )),
                        if (_isEditing) // Mostrar el icono de carga si _isCreating es true
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child:
                                CircularProgressIndicator(), // Icono de carga
                          )
                        else
                          Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: SizedBox(
                                width: 200,
                                height: 45,
                                child: ElevatedButton(
                                    onPressed: _isEditing
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isEditing =
                                                    true; // Indica que se está realizando el registro
                                              });
                                              String nombres =
                                                  _nombresController.text;
                                              String apellidos =
                                                  _apellidosController.text;
                                              String direccion =
                                                  _direccionController.text;
                                              String lastPassword =
                                                  _lastPasswordController.text;
                                              String newPassword =
                                                  _newPasswordController;
                                              bool validPassword =
                                                  await putData(
                                                      nombres,
                                                      apellidos,
                                                      direccion,
                                                      lastPassword,
                                                      newPassword);
                                              setState(() {
                                                _isEditing =
                                                    false; // Indica que se está realizando el registro
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      validPassword
                                                          ? "Se ha editado correctamente"
                                                          : "Contraseña incorrecta",
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                          fontFamily:
                                                              'Quicksand-SemiBold'),
                                                    )
                                                  ],
                                                ),
                                                duration: const Duration(
                                                    milliseconds: 2000),
                                                width: 300,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 10),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.0),
                                                ),
                                                backgroundColor: validPassword
                                                    ? const Color.fromARGB(
                                                        255, 12, 195, 106)
                                                    : Colors.red,
                                              ));
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 10,
                                      backgroundColor: const Color.fromRGBO(
                                          60,
                                          195,
                                          189,
                                          1), // background (button) color
                                      foregroundColor: Colors
                                          .white, // foreground (text) color
                                    ),
                                    child: Text(
                                      'Editar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontFamily: GoogleFonts.quicksand()
                                              .fontFamily,
                                          fontSize: 20),
                                    )),
                              )),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: 200,
                              height: 45,
                              child: ElevatedButton(
                                  onPressed: _isEditing
                                      ? null
                                      : () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => MenuPage(
                                                      clienteId:
                                                          widget.clienteId,
                                                      clienteCorreo:
                                                          widget.clienteCorreo,
                                                      clienteContrasena: widget
                                                          .clienteContrasena,
                                                      clientOrUser: widget
                                                          .clientOrUser)));
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 10,
                                    backgroundColor: const Color.fromRGBO(0, 0,
                                        0, .5), // background (button) color
                                    foregroundColor:
                                        Colors.white, // foreground (text) color
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontFamily:
                                            GoogleFonts.quicksand().fontFamily,
                                        fontSize: 20),
                                  )),
                            )),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  Future<void> fetchCliente() async {
    int clienteId = widget.clienteId;

    final String url =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/id?id=$clienteId';
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
      _nombres = clienteData['nombreCliente'] ?? "";
      _apellidos = clienteData['apellidoCliente'] ?? "";
      _direccion = clienteData['direccion'] ?? "";

      _nombresController.text = _nombres;
      _apellidosController.text = _apellidos;
      _direccionController.text = _direccion;
    }
  }

  String encryptPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la cadena a bytes en UTF-8
    var digest = sha256.convert(bytes); // Realiza el hash SHA-256

    return digest.toString();
  }

  Future<bool> putData(String nombres, String apellidos, String direccion,
      String lastPassword, String newPassword) async {
    // Encriptar nueva contraseña
    String encryptedPassword = encryptPassword(newPassword);
    // Encriptar contraseña actual
    String actualEncryptedPassword = encryptPassword(lastPassword);

    int clienteId = widget.clienteId;
    String apiUri =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/id?id=$clienteId';
    final String usernameApi = '11173482';
    final String passwordApi = '60-dayfreetrial';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));

    final getDataResponse = await http.get(
      Uri.parse(apiUri),
      headers: <String, String>{'authorization': basicAuth},
    );
    if (getDataResponse.statusCode == 200) {
      Map<String, dynamic> getPassword = jsonDecode(getDataResponse.body);
      if (getPassword['contraseña'] == actualEncryptedPassword) {
        // Map<String, dynamic> requestBody = {
        //   'nombres': nombres,
        //   'apellidos': apellidos,
        //   'direccion': direccion,
        //   'contraseña': newPassword
        // };
        String apiUriPut =
            'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes/$clienteId';
        final putResponse = await http.put(
          Uri.parse(apiUriPut),
          headers: <String, String>{
            'authorization': basicAuth,
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "idCliente": clienteId,
            "nombreCliente": getPassword['nombreCliente'],
            "apellidoCliente": getPassword['apellidoCliente'],
            "correo": getPassword['correo'],
            "contraseña": encryptedPassword,
            "telefono": getPassword['telefono'],
            "nacimiento": getPassword['nacimiento'],
            "direccion": getPassword['direccion'],
            "estado": 1
          }),
        );
        if (putResponse.statusCode == 200) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => PerfilPage(
                    clienteId: widget.clienteId,
                    clienteCorreo: widget.clienteCorreo,
                    clienteContrasena: widget.clienteContrasena,
                    clientOrUser: widget.clientOrUser)),
          );
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
    return false;
  }
}
