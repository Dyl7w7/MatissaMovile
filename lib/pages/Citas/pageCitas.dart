import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import 'package:matissamovile/pages/widget/textoFrom.dart';
import '../widget/AppBar.dart';

class PageCitas extends StatefulWidget {
  final String clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PageCitas({Key? key, required this.clienteId, required this.clienteCorreo, required this.clienteContrasena}) : super(key: key);

  @override
  State<PageCitas> createState() => _PageCitasState();
}

class _PageCitasState extends State<PageCitas> {
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  List<Map<String, dynamic>> servicios = [];
  List<Map<String, dynamic>> citas = [];
  Map<String, dynamic>? selectedService;

  String fecha() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    String fecha = '$year-$month-$day';

    return fecha;
  }

  @override
  void initState() {
    super.initState();
    fetchServicios();
    fetchCitas();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(clienteId: widget.clienteId, clienteCorreo: widget.clienteCorreo, clienteContrasena: widget.clienteContrasena,),
      body: Column(children: [
        Text("Mis citas", style: TextStyle(fontFamily: GoogleFonts.quicksand().fontFamily, fontSize: 35, fontWeight: FontWeight.bold),),
        Expanded(
          child: ListView.builder(
            itemCount: citas.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTileCard(
                  initialElevation: 2,
                  expandedColor: const Color.fromARGB(255, 216, 216, 216),
                  baseColor: const Color.fromRGBO(226, 212, 255, 1),
                  title: Text('Servicio: ${citas[index]['servicio']}'),
                  subtitle:Text('Feca registro: ${citas[index]['fechaRegistro']}'),
                  leading: const Icon(Icons.cut),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  children: <Widget>[
                    const Divider(
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Estado'),
                              subtitle: citas[index]['estado'] == 1
                                  ?  const Text('Activo')
                                  :  const Text('Cancelado'),
                              trailing: citas[index]['estado'] == 1
                                  ?  const Icon(Icons.check) 
                                  :  const Icon(Icons.block),
                            ),
                            ListTile(
                              title: const Text('Precio'),
                              subtitle: Text('${citas[index]['costoTotal']}'),
                              trailing: const Icon(Icons.monetization_on),
                            ),
                            ListTile(
                              title: const Text('Fecha de la cita'),
                              subtitle: Text('${citas[index]['fechaCita']}'),
                              trailing: const Icon(Icons.event),
                            ),
                            ListTile(
                              title: const Text('Hora de la cita'),
                              subtitle: Text('${citas[index]['horaCita']}'),
                              trailing: const Icon(Icons.schedule),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        color:  Color(0xFFa7e3e1)
                      ),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: [
                          TextButton(
                            onPressed: () {
                              _showEditCitaModal(context, citas[index]);
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.edit, color: Colors.black54,),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Editar", style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: const Text("Alerta!"),
                                      content: const Text("¿Seguro quieres eliminar la cita?"),
                                      actions: [
                                      TextButton(
                                        onPressed: () async{
                                        await deleteData(citas[index]['_id']);
                                        await fetchCitas();
                                        Navigator.of(context).pop();
                                        _showExitoDialog(context, "Cita eliminada");
                                        },
                                        child: const Text("Aceptar")
                                      ),
                                      TextButton(
                                        onPressed: ()=>Navigator.of(context).pop(),
                                        child: const Text("Cancelar")
                                      )
                                    ]
                                  );
                                }
                              );
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.delete, color: Colors.black54,),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Eliminar", style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              if(citas[index]['estado'] == 1){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Alerta!"),
                                      content: const Text(
                                          "¿Seguro quieres cancelar la cita?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              await cambiarEstado(
                                                  citas[index]['_id']);
                                              Navigator.of(context).pop();
                                              _showExitoDialog(context, "Cita cancelada");
                                            },
                                            child: const Text("Aceptar")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("Cancelar"))
                                      ]
                                    );
                                  }
                                );
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.cancel,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "La cita ya esta cancelada",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontFamily:
                                                    'Quicksand-SemiBold'),
                                          )
                                        ],
                                      ),
                                      duration: const Duration(
                                          milliseconds: 2000),
                                      width: 300,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 10),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      backgroundColor: Colors.red
                                  )
                                );
                              }
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.block,
                                  color: Colors.black54,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Cancelar",
                                    style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddCitaModal(context);
        },
      ),
    );
  }

  Future<void> _showAddCitaModal(BuildContext context) async {
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 200),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    // ignore: use_build_context_synchronously
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      selectedDate =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              double screenWidth = MediaQuery.of(context).size.width;
              return Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 44, 44, 44),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                width: screenWidth,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35.0),
                        color: Colors.white,
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedService,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedService = newValue;
                          });
                        },
                        items:
                            servicios.map<DropdownMenuItem<Map<String, dynamic>>>(
                          (Map<String, dynamic> servicio) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: servicio,
                              child: Text(servicio['nombre']),
                            );
                          },
                        ).toList(),
                        hint: const Text('Selecciona un servicio'),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedService != null) ...[
                      const Text("Servicio",style: TextStyle(color: Colors.white ),),
                      Label(screenWidth: screenWidth, dato: '${selectedService!['nombre']}'),
                      const Text("Precio",style: TextStyle(color: Colors.white )),
                      Label(screenWidth: screenWidth, dato: '${selectedService!['precio']}'),
                      const Text("Duración",style: TextStyle(color: Colors.white )),
                      Label(screenWidth: screenWidth, dato: '${selectedService!['duracion']}h'),
                      const Text("Fecha de la cita",style: TextStyle(color: Colors.white )),
                      Label(screenWidth: screenWidth, dato: '${selectedDate!.toLocal().toIso8601String().split('T')[0]}'),
                      const Text("Hora de la cita",style: TextStyle(color: Colors.white )),
                      Label(screenWidth: screenWidth, dato: '${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}'),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancelar")
                            ),
                          ),
                          Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedService != null) {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Aviso'),
                                        content: const Text(
                                            '¿Estas seguro de agendar la cita?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await postNuevaCita(
                                                selectedService!['precio'],
                                                selectedService!['nombre'],
                                                '${selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                                                "${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}",
                                              );
                                              await fetchCitas();
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context).pop();
                                              // ignore: use_build_context_synchronously
                                              _showExitoDialog(context, "Cita agendada");
                                            },
                                            child: const Text('Agendar'),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancelar"))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Aviso'),
                                        content: const Text('Elija un servicio.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Aceptar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: const Text('Agendar'),
                            ),
                          ),
                        ],
                      ) 
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> _showEditCitaModal(BuildContext context, Map<String, dynamic> cita) async {
        selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 200),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    // ignore: use_build_context_synchronously
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

        if (selectedDate != null) {
      selectedDate =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              double screenWidth = MediaQuery.of(context).size.width;
              return Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 44, 44, 44),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: screenWidth,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35.0),
                        color: Colors.white,
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedService,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedService = newValue;
                          });
                        },
                        items: servicios
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (Map<String, dynamic> servicio) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: servicio,
                              child: Text(servicio['nombre']),
                            );
                          },
                        ).toList(),
                        hint: const Text('Selecciona un servicio'),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedService != null) ...[
                      const Text(
                        "Servicio",
                        style: TextStyle(color: Colors.white),
                      ),
                      Label(
                          screenWidth: screenWidth,
                          dato: '${selectedService!['nombre']}'),
                      const Text("Precio",
                          style: TextStyle(color: Colors.white)),
                      Label(
                          screenWidth: screenWidth,
                          dato: '${selectedService!['precio']}'),
                      const Text("Duración",
                          style: TextStyle(color: Colors.white)),
                      Label(
                          screenWidth: screenWidth,
                          dato: '${selectedService!['duracion']}h'),
                      const Text("Fecha de la cita",
                          style: TextStyle(color: Colors.white)),
                      Label(
                          screenWidth: screenWidth,
                          dato:
                              '${selectedDate!.toLocal().toIso8601String().split('T')[0]}'),
                      const Text("Hora de la cita",
                          style: TextStyle(color: Colors.white)),
                      Label(
                          screenWidth: screenWidth,
                          dato:
                              '${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}'),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancelar")),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedService != null) {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Aviso'),
                                      content: const Text(
                                          '¿Estas seguro de editar la cita?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await putEditarCita(
                                              cita['_id'],
                                              selectedService!['precio'],
                                              selectedService!['nombre'],
                                              '${selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                                              "${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}",
                                            );
                                            await fetchCitas();
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                            // ignore: use_build_context_synchronously
                                            _showExitoDialog(
                                                context, "Cita editada");
                                          },
                                          child: const Text('Editar'),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancelar"))
                                      ],
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Aviso'),
                                      content: const Text('Elija un servicio.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Aceptar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text('Editar'),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> putEditarCita(String id, int costoTotal, String servicio,
      String fechaCita, String horaCita) async {
    final url = Uri.parse('https://matissa.onrender.com/api/citas/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'costoTotal': costoTotal,
        'servicio': servicio,
        'fechaCita': fechaCita,
        'horaCita': horaCita,
      }),
    );

    if (response.statusCode == 200) {
      print('Cita actualizada con ID: $id');
      fetchCitas();
    } else {
      print('Error al actualizar la cita: ${response.statusCode}');
    }
  }


  Future<void> cambiarEstado(String id) async {
    final url = Uri.parse('https://matissa.onrender.com/api/citas/$id');
    final response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'estado': 0}));

    if (response.statusCode == 200) {
      print('Estado actualizado: ${response.body}');
    }
  }

  Future<void> fetchCitas() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/citas'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newCitas = [];
      for (var item in jsonData) {
        if(item['cliente'] == widget.clienteCorreo){
          newCitas.add({
            '_id': item['_id'],
            'fechaRegistro': item['fechaRegistro'],
            'horaCita': item['horaCita'],
            'costoTotal': item['costoTotal'],
            'servicio': item['servicio'],
            'fechaCita': item['fechaCita'],
            'estado': item['estado'],
            // Agrega más campos según la estructura de tus citas
          });
        }
      }

      setState(() {
        citas = newCitas;
      });

      print('Citas: $citas');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<String> postNuevaCita(int costoTotal, String servicio,
      String fechaCita, String horaCita) async {
    final url = Uri.parse('https://matissa.onrender.com/api/citas');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cliente': "${widget.clienteCorreo}",
        'fechaRegistro': '${fecha()}',
        'costoTotal': costoTotal,
        'servicio': servicio,
        'fechaCita': fechaCita,
        'horaCita': horaCita,
        'estado': 1
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      dynamic idValue = responseData['_id'];
      String nuevaCitaId =
          idValue is Map ? idValue['\$oid'].toString() : idValue.toString();
      print('Nueva cita creada con ID: $nuevaCitaId');
      return nuevaCitaId;
    } else {
      print('Error: ${response.statusCode}');
      return '';
    }
  }

  Future<void> fetchServicios() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/servicios'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newData = [];
      for (var item in jsonData) {
        newData.add({
          'id': item['_id'],
          'nombre': item['nombre'],
          'precio': item['precio'],
          'duracion': item['duracion'],
        });
      }

      setState(() {
        servicios = newData;
      });

      print('Servicios: $servicios');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> deleteData(String idCita) async {
    final response = await http.delete(Uri.parse('https://matissa.onrender.com/api/citas/$idCita'));

    if (response.statusCode == 200) {
      // La respuesta fue exitosa
      print('Response data: ${response.body}');
    } else {
      // Ocurrió un error
      print('Error: ${response.statusCode}');
    }
  }
}

void _showExitoDialog(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      backgroundColor: const Color.fromARGB(255, 12, 195, 106)));
}
