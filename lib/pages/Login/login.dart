import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:matissamovile/pages/Citas/pageCitas.dart';
import 'package:matissamovile/pages/Register/register.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  late TextEditingController _correoController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateUserName(String? value){
    if(value == null || value.isEmpty){
      return "Por favor, ingrese un correo";
    }
    return null;
  }

  String? _validatePassword(String? value){
    if(value == null || value.isEmpty){
      return "Por favor ingrese una contraseña";
    }
    return null;
  }

    Future<void> _login(BuildContext context) async {
    final correo = _correoController.text;
    final password = _passwordController.text;

    print("entre a la función");

    final response = await http.get(
      Uri.parse('https://matissa.onrender.com/api/clientes/$correo'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = jsonDecode(response.body);

      if (userData.containsKey('correo')) {
        final String storedCorreo = userData["correo"];
        final String storedPassword = userData['contraseña'];
        final String clienteId = userData['_id'];

        if (password == storedPassword) {
          // Puedes hacer lo que necesitas con el ID y otros datos
          // En este ejemplo, simplemente imprimimos el ID y vamos a la siguiente página
          print('Usuario ID: $clienteId');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PageCitas(clienteId: "$clienteId", clienteCorreo: "$storedCorreo", clienteContrasena: "$storedPassword")),
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
                    validator: (value) => _validateUserName(value),
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
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: TextFormField(
                    validator: (value) => _validatePassword(value),
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
                  ),
                ),

                const SizedBox(height: 30),
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
                  onPressed: () {
                    _login(context);
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
                  child:  Text(
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
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const RegisterPage(),)
                    );
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
