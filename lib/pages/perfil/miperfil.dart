import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/Citas/pageCitas.dart';
import 'package:matissamovile/pages/widget/AppBar.dart';
import 'package:matissamovile/pages/widget/drawer.dart';

class PerfilPage extends StatefulWidget {
  final String clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PerfilPage({Key? key, required this.clienteId, required this.clienteCorreo, required this.clienteContrasena}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  String _nombres = "";
  String _apellidos = "";
  String _direccion = "";
  @override
  void initState(){
    super.initState();
    fetchCliente();
  }
  List<String> list = <String>["Medellín"];
  String dropdownValue = "Medellín";
  
  
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _lastPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(clienteId: widget.clienteId, clienteCorreo: widget.clienteCorreo, clienteContrasena: widget.clienteContrasena,),

      
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
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30, fontFamily: GoogleFonts.quicksand().fontFamily,
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('Editar mi perfil', style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                    ),),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _nombresController,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nombres',
                          hintStyle:
                            const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Quicksand-SemiBold'),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(35)
                              ),
                          filled: true
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor digite el nombre';
                          }
                          return null;
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _apellidosController,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Apellidos',
                          hintStyle:
                            const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Quicksand-SemiBold'),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(35)
                              ),
                          filled: true
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor digite el apellido';
                          }
                          return null;
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _direccionController,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Dirección',
                          hintStyle:
                            const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Quicksand-SemiBold'),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none
                              ),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none
                              ),
                              borderRadius: BorderRadius.circular(35)
                            ),
                          filled: true
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor digite su dirección';
                          }
                          return null;
                        },
                      )
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Ciudad:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: GoogleFonts.quicksand().fontFamily),),
                          const SizedBox(width: 50),
                          DropdownMenu<String>(
                            textStyle: TextStyle(
                              fontFamily: GoogleFonts.quicksand().fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                            initialSelection: list.first,
                            onSelected: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                            dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(value: value, label: value);
                            }).toList(),
                          ),
                        ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _lastPasswordController,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Contraseña actual',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(35)
                              ),
                          filled: true
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "La contraseña es necesaria";
                          } else if (value.length < 10 || value.length > 20) {
                            return "La contraseña debe tener al menos 10 caracteres y máximo 20 caracteres.";
                          } else {
                            return null;
                          }
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Nueva contraseña',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none
                                ),
                                borderRadius: BorderRadius.circular(35)
                              ),
                          filled: true
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "La contraseña es necesaria";
                          } else if (value.length < 10 || value.length > 20) {
                            return "La contraseña debe tener al menos 10 caracteres y máximo 20 caracteres.";
                          } else {
                            return null;
                          }
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String nombres = _nombresController.text;
                              String apellidos = _apellidosController.text;
                              String direccion = _direccionController.text;
                              String lastPassword = _lastPasswordController.text;
                              String newPassword = _newPasswordController.text;
                              bool validPassword = 
                              await putData(nombres, apellidos, direccion, lastPassword, newPassword);
                              ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
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
                                        validPassword ? "Se ha editado correctamente" : "Contraseña incorrecta",
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 255, 255, 255),
                                          fontFamily: 'Quicksand-SemiBold'
                                        ),
                                      )
                                    ],
                                  ),
                                  duration:
                                    const Duration(milliseconds: 2000),
                                  width: 300,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 10
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  backgroundColor: validPassword ? const Color.fromARGB(255, 12, 195, 106) : Colors.red,
                                ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor:const Color.fromRGBO(60, 195, 189, 1), // background (button) color
                            foregroundColor:Colors.white, // foreground (text) color
                          ),
                          child: Text('Editar', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 20),)
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => PageCitas(clienteId: widget.clienteId, clienteCorreo: widget.clienteCorreo, clienteContrasena: widget.clienteContrasena,))
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor:const Color.fromRGBO(0, 0, 0, .5), // background (button) color
                            foregroundColor:Colors.white, // foreground (text) color
                          ),
                          child: Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 20),)
                        ),
                      )
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }
  Future<void> fetchCliente() async {
    String clienteCorreo = widget.clienteCorreo;
    final response = await http.get(Uri.parse('https://matissa.onrender.com/api/clientes/$clienteCorreo'));

    if (response.statusCode == 200){
      Map<String, dynamic> clienteData = jsonDecode(response.body);
      _nombres = clienteData['nombres'] ?? "";
      _apellidos = clienteData['apellidos'] ?? "";
      _direccion = clienteData['direccion'] ?? "";

      _nombresController.text = _nombres;
      _apellidosController.text = _apellidos;
      _direccionController.text = _direccion;
    }
  }

  Future<bool> putData(String nombres, String apellidos, String direccion, String lastPassword, String newPassword) async {
    String clienteId = widget.clienteId;
    String apiUri = 'https://matissa.onrender.com/api/clientes/$clienteId';
    print('Datos formulario: $nombres, $apellidos, $direccion, $lastPassword, $newPassword');
    final getDataResponse = await http.get(Uri.parse(apiUri));
    if (getDataResponse.statusCode == 200){
      Map<String, dynamic> getPassword = jsonDecode(getDataResponse.body);
      print('Datos del Cliente: $getPassword');
      if (getPassword['contraseña'] == lastPassword){
        // Map<String, dynamic> requestBody = {
        //   'nombres': nombres,
        //   'apellidos': apellidos,
        //   'direccion': direccion,
        //   'contraseña': newPassword
        // };
        final putResponse = await http.put(
          Uri.parse(apiUri),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombres': nombres,
            'apellidos': apellidos,
            'direccion': direccion,
            'contraseña': newPassword
          }),
        );
        if(putResponse.statusCode == 200){
          print('Cliente actualizado');
          return true;
        }else{
          print('Error al actualizar: ${putResponse.statusCode}');
          return false;
        }
      } else {
        print('Contraseña incorrecta');
        return false;
      }
    }
    return false;
  }
}



