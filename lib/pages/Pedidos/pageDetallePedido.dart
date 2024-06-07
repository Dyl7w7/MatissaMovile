import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:matissamovile/pages/Pedidos/pagePedido.dart';
import 'package:matissamovile/pages/widget/drawer.dart';
import '../widget/AppBar.dart';

class Producto {
  final int idProducto;
  final String nombreProducto;
  final int cantidad;
  final double subtotal;

  Producto(
      {required this.idProducto,
      required this.nombreProducto,
      required this.cantidad,
      required this.subtotal});
}

class Product {
  final int id;
  final String nombre;
  final double precio;
  final int cantidad;

  Product(
      {required this.id,
      required this.nombre,
      required this.precio,
      required this.cantidad});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['idProducto'],
        nombre: json['nombreProducto'],
        precio: json['precioVenta'].toDouble(),
        cantidad: json['saldoInventario']);
  }
}

class Pedido {
  final int? idPedido;

  Pedido({this.idPedido});

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json['idPedido'],
    );
  }
}

class DetallePedido {
  final int? idDetallePedido;

  DetallePedido({this.idDetallePedido});

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      idDetallePedido: json['idDetallePedido'],
    );
  }
}

class PageDetallePedido extends StatefulWidget {
  final int clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  final int clientOrUser;
  const PageDetallePedido(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena,
      required this.clientOrUser});

  @override
  State<PageDetallePedido> createState() => _PageDetallePedidoState();
}

class _PageDetallePedidoState extends State<PageDetallePedido> {
  bool _isCreating = false;
  bool _loaded = false;
  bool _stock = true;
  final String url =
      'http://dylanbolivar1-001-site1.ftempurl.com/api/productos';
  final String username = '11173482';
  final String password = '60-dayfreetrial';
  TextEditingController _controller = TextEditingController();
  late List<Product> productos = [];
  List<Product> productosFiltrados = [];
  Map<int, int> carrito = {};
  Map<int, int> cantidadSeleccionada = {};
  List<Producto> carrito2 = [];
  double totalPedido = 0;

  @override
  void initState() {
    fetchProductos();
    super.initState();
  }

  Future<void> fetchProductos() async {
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Product> newData = [];
      for (var item in jsonData) {
        if (item['estado'] == 1) {
          newData.add(Product.fromJson(item));
        }
      }
      setState(() {
        productos = newData;
        productosFiltrados = newData;
        _loaded = true;
      });
    } else {}
  }

  void addToCart(int id, int quantity, double price) {
    setState(() {
      quantity++;
      carrito[id] = quantity;
      // totalPedido += price;
    });
  }

  void removeFromCart(int productId, int quantity, double price) {
    setState(() {
      if (quantity > 0) {
        quantity--;
        carrito[productId] = quantity;
      } else {
        quantity = 0;
        carrito[productId] = quantity;
      }
      // if (totalPedido > 0){
      //   totalPedido -= price * quantity;
      // } else {
      //   totalPedido = 0;
      // }
    });
  }

  void obtenerTotalPedido() {
    carrito2.clear();
    for (Product producto in productos) {
      int cantidadEnCarrito = carrito[producto.id] ?? 0;
      if (cantidadEnCarrito > 0) {
        // El producto está en el carrito
        if (producto.cantidad >= cantidadEnCarrito) {
          double subtotal = producto.precio * cantidadEnCarrito;
          carrito2.add(Producto(
              idProducto: producto.id,
              nombreProducto: producto.nombre,
              cantidad: cantidadEnCarrito,
              subtotal: subtotal));
          totalPedido += subtotal;
        } else {
          _showErrorDialog(
              context, producto.nombre, 'No tenemos suficientes productos');
          setState(() {
            _stock = false;
          });
        }
      }
    }
  }

  Future<bool> cart() async {
    final String urlPedidos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    bool success = false;
    DateTime fechaPedido = DateTime.now();
    String fechaFormat = DateFormat('yyyy-MM-dd').format(fechaPedido);
    int idNewPedido = await obtenerUltimoIdPedido();

    final postPedidoApi = await http.post(
      Uri.parse(urlPedidos),
      headers: <String, String>{
        'authorization': basicAuth,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'idPedido': idNewPedido + 1,
        'idCliente': widget.clienteId,
        'fechaPedido': fechaFormat,
        'precioTotalPedido': totalPedido,
        'estado': 1
      }),
    );
    if (postPedidoApi.statusCode == 200) {
      // La respuesta fue exitosa

      success = true;
    } else {
      // Ocurrió un error al realizar la solicitud POST

      success = false;
    }

    final String urlDetallePedidos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/detallePedidos';

    int idPedido = await obtenerUltimoIdPedido();

    for (int i = 0; i < carrito2.length; i++) {
      int idDetallePedido = await obtenerUltimoIdDetallePedido();
      final postDetallePedidoApi = await http.post(
        Uri.parse(urlDetallePedidos),
        headers: <String, String>{
          'authorization': basicAuth,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'idDetallePedido': idDetallePedido + 1,
          'idProducto': carrito2[i].idProducto,
          'idPedido': idPedido,
          'cantidadProducto': carrito2[i].cantidad,
          'precioUnitario': carrito2[i].subtotal
        }),
      );
      int idProducto = carrito2[i].idProducto;
      final String urlProductos =
          'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/id?id=$idProducto';
      final getProductoApi = await http.get(
        Uri.parse(urlProductos),
        headers: <String, String>{'authorization': basicAuth},
      );
      if (getProductoApi.statusCode == 200) {
        Map<String, dynamic> getProducto = jsonDecode(getProductoApi.body);
        int putCantidad = getProducto['saldoInventario'] - carrito2[i].cantidad;
        final String urlProductosPut =
            'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/$idProducto';
        final putProductoApi = await http.put(Uri.parse(urlProductosPut),
            headers: <String, String>{
              'authorization': basicAuth,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              "idProducto": getProducto['idProducto'],
              "nombreProducto": getProducto['nombreProducto'],
              "descripcion": getProducto['descripcion'],
              "fechaCaducidad": getProducto['fechaCaducidad'],
              "precioVenta": getProducto['precioVenta'],
              "saldoInventario": putCantidad,
              "estado": getProducto['estado']
            }));
        if (putProductoApi.statusCode == 204) {
        } else {}
      } else {}

      if (postDetallePedidoApi.statusCode == 200) {
        // La respuesta fue exitosa

        success = true;
      } else {
        // Ocurrió un error al realizar la solicitud POST

        success = false;
      }
    }
    setState(() {
      _isCreating = false;
    });
    if (success) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> obtenerUltimoIdPedido() async {
    final String urlPedidos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var pedidos = [];
    final getPedidosApi = await http.get(
      Uri.parse(urlPedidos),
      headers: <String, String>{'authorization': basicAuth},
    );
    if (getPedidosApi.statusCode == 200) {
      final List<dynamic> pedidosData = jsonDecode(getPedidosApi.body);
      List<Pedido> newData = [];
      for (var item in pedidosData) {
        newData.add(Pedido.fromJson(item));
      }
      pedidos = newData;
    }

    int idPedido = pedidos.isNotEmpty
        ? pedidos
            .map((pedido) => pedido.idPedido ?? 0)
            .reduce((value, element) => value > element ? value : element)
        : 0;

    return idPedido;
  }

  Future<int> obtenerUltimoIdDetallePedido() async {
    final String urlDetallePedidos =
        'http://dylanbolivar1-001-site1.ftempurl.com/api/detallepedidos';
    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var detallepedidos = [];
    final getDetallePedidosApi = await http.get(
      Uri.parse(urlDetallePedidos),
      headers: <String, String>{'authorization': basicAuth},
    );
    if (getDetallePedidosApi.statusCode == 200) {
      final List<dynamic> detallePedidosData =
          jsonDecode(getDetallePedidosApi.body);
      List<DetallePedido> newData = [];
      for (var item in detallePedidosData) {
        newData.add(DetallePedido.fromJson(item));
      }
      detallepedidos = newData;
    }

    int idDetallePedido = detallepedidos.isNotEmpty
        ? detallepedidos
            .map((detallepedido) => detallepedido.idDetallePedido ?? 0)
            .reduce((value, element) => value > element ? value : element)
        : 0;

    return idDetallePedido;
  }

  void _showErrorDialog(
      BuildContext context, String errorMessage, String errorMessage2) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Icon(
            //   Icons.cancel,
            //   color: Color.fromARGB(255, 255, 255, 255),
            // ),
            // const SizedBox(
            //   width: 5,
            // ),
            Column(
              children: [
                Text(
                  errorMessage,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Quicksand-SemiBold'),
                ),
                Text(
                  errorMessage2,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Quicksand-SemiBold'),
                )
              ],
            ),
          ],
        ),
        duration: const Duration(milliseconds: 4000),
        width: 350,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        backgroundColor: Colors.red));
  }

  void _showCreandoDialog(BuildContext context, String message) {
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
              message,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(
        clienteId: widget.clienteId,
        clienteCorreo: widget.clienteCorreo,
        clienteContrasena: widget.clienteContrasena,
        clientOrUser: widget.clientOrUser,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(0.0),
            child: Container(
              color: Color.fromARGB(
                  255, 255, 255, 255), // Color de fondo del título
              child: ListTile(
                title: Text(
                  "Seleccione los productos",
                  style: TextStyle(
                    fontFamily: GoogleFonts.quicksand().fontFamily,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Color del texto del título
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (!_loaded) CircularProgressIndicator(),
          if (_loaded)
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Container(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Color de fondo del título
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      // Filtrar la lista de productos según el término de búsqueda
                      productosFiltrados = productos
                          .where((producto) => producto.nombre
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar producto',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: productosFiltrados.length,
              itemBuilder: (BuildContext context, int index) {
                final int productId = productosFiltrados[index].id;
                int cantidad = carrito[productId] ?? 0;

                return Container(
                  margin: EdgeInsets.all(6),
                  child: ListTile(
                    tileColor: Color.fromARGB(255, 240, 240, 240),
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Color.fromARGB(255, 0, 193, 207),
                            size: 30,
                          ),
                          Text(
                              '$cantidad - ${productosFiltrados[index].nombre}'),
                        ],
                      ),
                    ),
                    //subtitle: Text('\$ ${productos[index].precio.toStringAsFixed(2)}'),
                    subtitle: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                  ' ${productosFiltrados[index].cantidad} disponibles'),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                ' Precio: \$ ${NumberFormat('#,###', 'es_ES').format(productosFiltrados[index].precio)}',
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            double precio = productos[index].precio;
                            removeFromCart(
                                productosFiltrados[index].id, cantidad, precio);
                            setState(() {
                              cantidadSeleccionada[productId] =
                                  carrito[productId] ?? 0;
                            });
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text('$cantidad'),
                        IconButton(
                          onPressed: () {
                            double precio = productos[index].precio;
                            addToCart(
                                productosFiltrados[index].id, cantidad, precio);
                            setState(() {
                              cantidadSeleccionada[productId] =
                                  carrito[productId] ?? 0;
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 80,
            color: Color.fromARGB(255, 255, 255, 255),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Row(
          children: [
            Text('Pedir  '),
            Icon(Icons.add_shopping_cart),
          ],
        ),
        onPressed: () {
          obtenerTotalPedido();
          if (carrito2.isNotEmpty && _stock) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("¿Desea crear el pedido?"),
                      content: Text(
                          "Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(totalPedido)}"),
                      actions: [
                        if (_isCreating)
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child:
                                  CircularProgressIndicator()), // Icono de carga
                        TextButton(
                            onPressed: _isCreating
                                ? null
                                : () async {
                                    setState(() {
                                      _isCreating = true;
                                    });
                                    bool success = false;
                                    try {
                                      // Ejecutar la función cart() y esperar su finalización

                                      // Mostrar el diálogo de carga mientras se ejecuta la función
                                      showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                        builder: (BuildContext context) {
                                          return PopScope(
                                            canPop:
                                                false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                            child: AlertDialog(
                                              title:
                                                  const Text("Creando pedido"),
                                              content: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 100),
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          );
                                        },
                                      );
                                      success = await cart();

                                      // Esperar un momento antes de cerrar el diálogo para que el usuario pueda verlo
                                      await Future.delayed(
                                          Duration(seconds: 1));

                                      // Cerrar el diálogo
                                      Navigator.of(context).pop();

                                      // Si la función cart() tuvo éxito, puedes mostrar un diálogo de éxito
                                      if (success) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return PopScope(
                                              canPop: false,
                                              child: AlertDialog(
                                                title:
                                                    const Text("Pedido creado"),
                                                content: const Text(
                                                    "El pedido se ha creado correctamente."),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => PagePedido(
                                                                  clienteId: widget
                                                                      .clienteId,
                                                                  clienteCorreo:
                                                                      widget
                                                                          .clienteCorreo,
                                                                  clienteContrasena:
                                                                      widget
                                                                          .clienteContrasena,
                                                                  clientOrUser:
                                                                      widget
                                                                          .clientOrUser)));
                                                    },
                                                    child:
                                                        const Text("Aceptar"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    } catch (e) {}
                                  },
                            child: const Text("Aceptar")),
                        TextButton(
                            onPressed: _isCreating
                                ? null
                                : () async {
                                    setState(() {
                                      totalPedido = 0;
                                      carrito2.clear();
                                    });
                                    Navigator.of(context).pop();
                                  },
                            child: const Text("Cancelar"))
                      ]);
                });
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Alerta"),
                      content: Text(_stock
                          ? 'No ha seleccionado productos'
                          : 'No hay suficientes productos'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _stock = false;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Aceptar"))
                      ]);
                });
          }
        },
      ),
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final Function(int, int) onSelected;
  final int initialQuantity;
  final int productoId;

  const QuantitySelector(
      {Key? key,
      required this.onSelected,
      required this.productoId,
      this.initialQuantity = 0})
      : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onSelected(widget.productoId, _quantity);
  }

  void _decrement() {
    setState(() {
      _quantity = (_quantity > 0) ? _quantity - 1 : 0;
    });
    widget.onSelected(widget.productoId, _quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _decrement,
          icon: Icon(Icons.remove),
        ),
        //Text('$_quantity'),
        IconButton(
          onPressed: _increment,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
