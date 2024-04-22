import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: Text(
          'Matissa',
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: GoogleFonts.merienda().fontFamily),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(60, 195, 189, 1));
  }
}
