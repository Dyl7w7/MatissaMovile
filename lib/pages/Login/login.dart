import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/Register/register.dart';
import 'package:matissamovile/pages/perfil/menu.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  late TextEditingController _correoController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();

  bool _isLogging = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateUserName(String? value) {
    print("entre a la función");
    if (value == null || value.isEmpty) {
      return "Por favor, ingrese un correo";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    print("entre a la función");
    if (value == null || value.isEmpty) {
      return "Por favor ingrese una contraseña";
    }
    return null;
  }

  String encryptPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la cadena a bytes en UTF-8
    var digest = sha256.convert(bytes); // Realiza el hash SHA-256

    return digest.toString();
  }

  Future<void> _login(BuildContext context) async {
    final correo = _correoController.text;
    final password = _passwordController.text;

    if (correo == "" || password == "") {
      _showErrorDialog(context, 'Por favor, rellene los campos');
    } else {
      print("entre a la función");

      final String url = 'http://dylanbolivar1-001-site1.ftempurl.com/api/clientes';
      final String usernameApi = '11173482';
      final String passwordApi = '60-dayfreetrial';

      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$usernameApi:$passwordApi'));

      final response = await http.get(
        //Uri.parse('dylanbolivar1-001-site1.ftempurl.com/api/clientes')
        Uri.parse(url),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final List<dynamic> userData = jsonDecode(response.body);

        final usuario = userData.firstWhere((usuario) => usuario['correo'] == correo, orElse: () => null);

        if (usuario != null) {
          final String storedCorreo = usuario['correo'];
          final String storedPassword = usuario['contraseña'];
          final int idCliente = usuario['idCliente'];

          String encryptedPassword = encryptPassword(password);
          print(encryptedPassword); // Imprime la contraseña encriptada

          if (encryptedPassword == storedPassword) {
            // Puedes hacer lo que necesitas con el ID y otros datos
            // En este ejemplo, simplemente imprimimos el ID y vamos a la siguiente página
            print('Usuario ID: $idCliente');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MenuPage(
                      clienteId: idCliente,
                      clienteCorreo: "$storedCorreo",
                      clienteContrasena: "$storedPassword")),
            );
          } else {
            _showErrorDialog(context, 'Contraseña incorrecta');
          }
        } else {
          _showErrorDialog(context, 'Usuario no encontrado');
        }
      } else {
        final dynamic responseData = json.decode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Error de inicio de sesión';
        _showErrorDialog(context, errorMessage);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3CC3BD),
        centerTitle: true,
        title: Text(
          'Matissa',
          style: TextStyle(
            fontFamily: GoogleFonts.merienda().fontFamily,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF3CC3BD),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  height: 160.0,
                  width: double.infinity,
                  color: Colors.white,
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(height: 60), // Espacio de 10 pixels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: TextFormField(
                    //validator: (value) => _validateUserName(value),
                    controller: _correoController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    enableIMEPersonalizedLearning: false,
                    decoration: InputDecoration(
                      hintText: 'Correo',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.quicksand().fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      fillColor: Colors.grey.shade200,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor ingrese un correo';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: TextFormField(
                    //validator: (value) => _validatePassword(value),
                    controller: _passwordController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    enableIMEPersonalizedLearning: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.quicksand().fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      fillColor: Colors.grey.shade200,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        print("Vacio pai");
                        return 'Por favor ingrese una contraseña';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 30),
                 if (_isLogging) // Mostrar el icono de carga si _isCreating es true
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child:
                        CircularProgressIndicator(), // Icono de carga
                  )
                else 
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Cambiar el radio del borde aquí
                    ),
                    foregroundColor: const Color.fromARGB(179, 129, 127, 127),
                    backgroundColor: const Color.fromARGB(255, 255, 252, 252),
                    minimumSize: const Size(
                        140, 35), // Cambiar el tamaño mínimo del botón aquí
                  ),
                  onPressed: _isLogging
                      ? null
                      : () async {
                    setState(() {
                      _isLogging =
                          true; // Indica que se está realizando el registro
                    });
                    try{
                      await _login(context);
                    } catch(e) {
                      print('Error al enviar ingresar: $e');
                    }

                    setState(() {
                      _isLogging = false; // Indica que se está realizando el registro
                    });
                    
                    
                    
                  },
                  child: Text(
                    'Ingresar',
                    style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                      fontSize: 18,
                      color: const Color.fromARGB(255, 82, 81, 81),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Espacio de 10 pixels
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, 'signup'); //El archivo donde se va enviar
                  },
                  child: Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Cambiar el radio del borde aquí
                    ),
                    foregroundColor: const Color.fromARGB(179, 129, 127, 127),
                    backgroundColor: const Color.fromARGB(255, 255, 252, 252),
                    minimumSize: const Size(
                        140, 35), // Cambiar el tamaño mínimo del botón aquí
                  ),
                  onPressed: _isLogging ? null : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ));
                  },
                  child: Text(
                    'Registrate',
                    style: TextStyle(
                      fontFamily: GoogleFonts.quicksand().fontFamily,
                      fontSize: 18,
                      color: const Color.fromARGB(255, 82, 81, 81),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showErrorDialog(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.cancel,
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
      backgroundColor: Colors.red));
}
