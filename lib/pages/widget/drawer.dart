import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matissamovile/pages/Citas/pageCitas.dart';
import 'package:matissamovile/pages/Login/login.dart';
import 'package:matissamovile/pages/Pedidos/pagePedido.dart';
import 'package:matissamovile/pages/Pedidos/pagePedidos.dart';
import 'package:matissamovile/pages/Productos/pageProductos.dart';
import 'package:matissamovile/pages/Ventas/pageVentas.dart';
import 'package:matissamovile/pages/perfil/miperfil.dart';

class MyDrawer extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const MyDrawer(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE2D4FF),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3CC3BD),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          fit: BoxFit
                              .cover, // Ajusta automáticamente al tamaño del DrawerHeader
                          height:
                              70, // Puedes ajustar la altura según sea necesario
                          width:
                              70, // Puedes ajustar el ancho según sea necesario
                        ),
                        const SizedBox(height: 14.0),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontFamily: GoogleFonts.merienda().fontFamily,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.clientOrUser == 1)
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        _onItemTapped(0);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PerfilPage(
                                clienteId: widget.clienteId,
                                clienteCorreo: widget.clienteCorreo,
                                clienteContrasena: widget.clienteContrasena,
                                clientOrUser: widget.clientOrUser,
                              ),
                            ));
                      },
                    ),
                  if (widget.clientOrUser == 1)
                    ListTile(
                      leading: const Icon(
                        Icons.shopping_bag,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Mis pedidos',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        _onItemTapped(1);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PagePedido(
                                      clienteId: widget.clienteId,
                                      clienteCorreo: widget.clienteCorreo,
                                      clienteContrasena:
                                          widget.clienteContrasena,
                                      clientOrUser: widget.clientOrUser,
                                    )));
                      },
                    ),
                    if (widget.clientOrUser == 0)
                    ListTile(
                      leading: const Icon(
                        Icons.event,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Citas',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 2,
                      onTap: () {
                        _onItemTapped(2);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PageCitas(
                                    clienteId: widget.clienteId,
                                    clienteCorreo: widget.clienteCorreo,
                                    clienteContrasena: widget.clienteContrasena,
                                    clientOrUser: widget.clientOrUser)));
                      },
                    ),
                    if (widget.clientOrUser == 0)
                    ListTile(
                      leading: const Icon(
                        Icons.shopping_cart,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Pedidos',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 3,
                      onTap: () {
                        _onItemTapped(3);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PagePedidos(
                                    clienteId: widget.clienteId,
                                    clienteCorreo: widget.clienteCorreo,
                                    clienteContrasena: widget.clienteContrasena,
                                    clientOrUser: widget.clientOrUser)));
                      },
                    ),
                  if (widget.clientOrUser == 0)
                    ListTile(
                      leading: const Icon(
                        Icons.monetization_on,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Ventas',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        _onItemTapped(4);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PageVentas(
                                      clienteId: widget.clienteId,
                                      clienteCorreo: widget.clienteCorreo,
                                      clienteContrasena:
                                          widget.clienteContrasena,
                                      clientOrUser: widget.clientOrUser,
                                    )));
                      },
                    ),
                  
                    if (widget.clientOrUser == 0)
                    ListTile(
                      leading: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 30,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Productos',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: GoogleFonts.quicksand().fontFamily,
                        ),
                      ),
                      selected: _selectedIndex == 5,
                      onTap: () {
                        _onItemTapped(5);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PageProductos(
                                    clienteId: widget.clienteId,
                                    clienteCorreo: widget.clienteCorreo,
                                    clienteContrasena: widget.clienteContrasena,
                                    clientOrUser: widget.clientOrUser)));
                      },
                    ),

                  // ListTile(
                  //   leading: const Icon(
                  //     Icons.badge,
                  //     size: 30,
                  //     color: Colors.black,
                  //   ),
                  //   title: Text(
                  //     'Prueba',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       color: Colors.black,
                  //       fontFamily: GoogleFonts.quicksand().fontFamily,
                  //     ),
                  //   ),
                  //   selected: _selectedIndex == 2,
                  //   onTap: () {
                  //     _onItemTapped(3);
                  //     Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => DatePickerField()));
                  //   },
                  // ),
                ],
              ),
            ),
            // Footer
            Container(
              color: const Color(0xFF444444),
              child: ListTile(
                title: Text(
                  'Cerrar sesion',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: GoogleFonts.quicksand().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                trailing: const Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const MyLogin()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
