import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/Login/login.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<String> list = <String>["Medellín"];
  String _ciudad = "Medellín";

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellido = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  String _password = '';
  

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Matissa', style: TextStyle(fontFamily: GoogleFonts.merienda().fontFamily, fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(60, 195, 189, 1)),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  'Registrarse',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30, fontFamily: GoogleFonts.quicksand().fontFamily,
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('¡Bienvenido a Matissa! Por favor registrese', style: TextStyle(
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
                        controller: _nombre,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nombres',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily:
                                        GoogleFonts.quicksand().fontFamily,
                                  ),
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
                            return 'Por favor ingrese su nombre';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                          });
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _apellido,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Apellidos',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily,),
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
                            return 'Por favor digite su apellido';
                          }
                          return null;
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _telefono,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Teléfono',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily,),
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
                            return 'Por favor digite su teléfono';
                          }
                          return null;
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _direccion,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Dirección',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily:
                                        GoogleFonts.quicksand().fontFamily,
                                  ),
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
                          Text('Ciudad:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily:
                                        GoogleFonts.quicksand().fontFamily,
                                  ),),
                          const SizedBox(width: 50),
                          DropdownMenu<String>(
                            textStyle: TextStyle(
                              fontFamily: GoogleFonts.quicksand().fontFamily,
                              fontWeight: FontWeight.w600
                            ),
                            initialSelection: list.first,
                            onSelected: (String? value) {
                              setState(() {
                                _ciudad = value!;
                              });
                            },
                            dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                value: value, 
                                label: value,
                                                   
                                );
                            }).toList(),
                          ),
                        ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Correo eléctronico',
                          hintStyle:
                            TextStyle(fontWeight: FontWeight.w600, fontFamily:
                                        GoogleFonts.quicksand().fontFamily,
                                  ),
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
                          String pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regExp = RegExp(pattern);
                          if (value!.isEmpty) {
                            return "El correo es necesario";
                          } else if (!regExp.hasMatch(value)) {
                            return "Correo invalido";
                          } else {
                            return null;
                          }
                        },
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextFormField(
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
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
                        obscureText: true,
                        style: TextStyle(
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirmar contraseña',
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
                            return 'Confirme su contraseña';
                          }
                          if (value != _password) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
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
                              String nombre = _nombre.text;
                              String apellido = _apellido.text;
                              String direccion = _direccion.text;
                              String ciudad = _ciudad;
                              String telefono = _telefono.text;
                              String correo = _correo.text;
                              String password = _password;
                              bool register = 
                              await postData(nombre, apellido, direccion, ciudad, correo, telefono, password);
                              ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        register ? Icons.check_circle : Icons.error,
                                        color: Color.fromARGB(255, 6, 6, 6),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                        Text(
                                          register ? "Se ha registrado correctamente" : "Error: el correo o el teléfono \n ya estan registrados",
                                          style: TextStyle(
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
                                  backgroundColor: register ? const Color.fromARGB(255, 12, 195, 106) : Colors.red,
                                ));
                                if (register){
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MyLogin())
                                  );
                                }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor:const Color.fromRGBO(60, 195, 189, 1), // background (button) color
                            foregroundColor:Colors.white, // foreground (text) color
                          ),
                          child: Text('Registrarse', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 20),)
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
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor:const Color.fromRGBO(0, 0, 0, .5), // background (button) color
                            foregroundColor:Colors.white, // foreground (text) color
                          ),
                          child: Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 20),)
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
}
// Future<void> postData(String cedula, String nombre, String apellido, String direccion, String ciudad, String correo, String telefono, String fechaNacimiento, String password) async {
//     final url = Uri.parse('https://matissa.onrender.com/api/clientes');

//     final postDataResponse = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'cedula': cedula,
//           'nombres': nombre,
//           'apellidos': apellido,
//           'telefono': telefono,
//           'direccion': direccion,
//           'ciudad': ciudad,
//           'fechaNacimiento': fechaNacimiento,
//           'correo': correo,
//           'contraseña': password,
//           'estado': 1
//         }),
//       );
//       final data = jsonDecode(postDataResponse.body);
//       print(data);

//       if (postDataResponse.statusCode == 200) {
//         // La respuesta fue exitosa
//         print('Nuevo registro creado: ${postDataResponse.body}');
//       } else {
//         // Ocurrió un error al realizar la solicitud POST
//         print('Error al crear el nuevo registro: ${postDataResponse.statusCode}');
//       }

//       print("Cédula: $cedula, Nombre: $nombre, Apellido: $apellido, Teléfono: $telefono, Dirección: $direccion, Ciudad: $ciudad, Correo: $correo, Nacimiento: $fechaNacimiento, Contraseña: $password, Estado: 1");
//   }



Future<bool> postData(String nombre, String apellido, String direccion, String ciudad, String correo, String telefono, String password) async {
  // Realizar una solicitud GET para obtener los datos existentes
  final getDataResponse = await http.get(Uri.parse('https://matissa.onrender.com/api/clientes'));

  if (getDataResponse.statusCode == 200) {
    // Analizar la respuesta JSON de la solicitud GET
    final List<dynamic> existingData = jsonDecode(getDataResponse.body);

    // Verificar si el nuevo registro con la cédula ya existe
    bool correoExists = existingData.any((recordCorreo) => recordCorreo['correo'] == correo);
    bool telefonoExists = existingData.any((recordTef) => recordTef['telefono'] == int.parse(telefono));
    if (correoExists || telefonoExists) {
      print('El correo o el teléfono ya existe');
      return false;
    } else {
      // Si el registro no existe, realizar la solicitud POST
      final postDataResponse = await http.post(
        Uri.parse('https://matissa.onrender.com/api/clientes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombres': nombre,
          'apellidos': apellido,
          'telefono': telefono,
          'direccion': direccion,
          'ciudad': ciudad,
          'correo': correo,
          'contraseña': password,
          'estado': 1
        }),
      );
      final data = jsonDecode(postDataResponse.body);
      print(data);

      if (postDataResponse.statusCode == 200) {
        // La respuesta fue exitosa
        print('Nuevo registro creado: ${postDataResponse.body}');
        Mailer(correo, nombre);
      } else {
        // Ocurrió un error al realizar la solicitud POST
        print('Error al crear el nuevo registro: ${postDataResponse.statusCode}');
      }
      print("Nombre: $nombre, Apellido: $apellido, Teléfono: $telefono, Dirección: $direccion, Ciudad: $ciudad, Correo: $correo, Contraseña: $password, Estado: 1");
      return true;
    }
  }
  return false;
}

Mailer(String correo, String nombre) async {
  
  String username = 'dilanstivel9@gmail.com';
  String password = 'cflk wkza cqsh qgyi';

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.  

  // Create our message.
  final message = Message()
    ..from = Address(username, 'Matissa')
    ..recipients.add('dilanstivel9@gmail.com')
    ..ccRecipients.addAll(['dilanstivel9@gmail.com', correo])
    ..bccRecipients.add(Address('dilanstivel9@gmail.com'))
    ..subject = 'Registro en Matissa'
    ..text = 'Se ha registrado en Matissa correctamente.'
    ..html = "Sr $nombre. Usted se ha registrado correctamente en Matissa el día: ${DateTime.now()}";

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
 
  var connection = PersistentConnection(smtpServer);

  // Send the first message
  await connection.send(message);

  // send the equivalent message
  

  // close the connection
  await connection.close();
}