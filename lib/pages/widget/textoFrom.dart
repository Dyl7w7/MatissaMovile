import 'package:flutter/material.dart';

class Label extends StatefulWidget {
  final double screenWidth;
  final String dato;
  const Label({super.key, required this.screenWidth, required this.dato});

  @override
  State<Label> createState() => _LabelState();
}

class _LabelState extends State<Label> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: widget.screenWidth,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: Colors.white, // Puedes personalizar el color y el grosor del borde
      ),
        child: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.dato),
            ],
          )
        )
    );
  }
}