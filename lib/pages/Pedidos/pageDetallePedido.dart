import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Producto({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidad,
    required this.subtotal
  });
}

class Product {
  final int id;
  final String nombre;
  final double precio;
  final int cantidad;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['idProducto'],
      nombre: json['nombreProducto'],
      precio: json['precioVenta'].toDouble(),
      cantidad: json['saldoInventario']
    );
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
  const PageDetallePedido(
      {super.key,
      required this.clienteId,
      required this.clienteCorreo,
      required this.clienteContrasena});

  @override
  State<PageDetallePedido> createState() => _PageDetallePedidoState();
}

class _PageDetallePedidoState extends State<PageDetallePedido> {
  bool _isCreating = false;
  final String url = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos';
  final String username = '11173482';
  final String password = '60-dayfreetrial';
  late List<Product> productos = [];
  Map<int, int> carrito = {};
  List<Producto> carrito2 = [];
  double totalPedido = 0;

  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Future<void> fetchProductos() async {
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Product> newData = [];
      for (var item in jsonData) {
        if(item['estado'] == 1){
          newData.add(Product.fromJson(item));
        }
      }
      setState(() {
        productos = newData;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void addToCart(Product product, int quantity, double price) {
    setState(() {
      carrito[product.id] = quantity;
      // totalPedido += price;
    });
    print(carrito);
  }

  void removeFromCart(int productId, double price, int quantity) {
    setState(() {
      carrito.remove(productId);
      // if (totalPedido > 0){
      //   totalPedido -= price * quantity;
      // } else {
      //   totalPedido = 0;
      // }
      
    });
    print(carrito);
  }

  void obtenerTotalPedido() {
    carrito2.clear();
    for (Product producto in productos) {
      int cantidadEnCarrito = carrito[producto.id] ?? 0;
      if (cantidadEnCarrito > 0) {
      // El producto está en el carrito
        if (producto.cantidad >= cantidadEnCarrito) {
          double subtotal = producto.precio * cantidadEnCarrito;
          carrito2.add(
            Producto(
              idProducto: producto.id, 
              nombreProducto: producto.nombre, 
              cantidad: cantidadEnCarrito, 
              subtotal: subtotal
            )
          );
          totalPedido += subtotal;
          print('Producto añadido al carrito: ID: ${producto.id}. ${producto.nombre}, Cantidad: ${producto.nombre} Subtotal: $subtotal');
        } else {
          _showErrorDialog(context, producto.nombre, 'No tenemos suficientes productos');
        }
      }
    
    //   carrito.forEach((key, value) {
    //   print('ID: $key, Cantidad: $value');
    //   if (productos[i].id == key){
    //     String nombreProducto = productos[i].nombre;
    //     if (productos[i].cantidad >= value){
    //       subtotal = productos[i].precio * value;
    //       carrito2.add(
    //         Producto(idProducto: key, nombreProducto: nombreProducto, cantidad: value, subtotal: subtotal)
    //       );
    //       totalPedido += subtotal;
    //       print(totalPedido);
    //     } else {
    //       _showErrorDialog(context, nombreProducto, 'No tenemos suficientes productos');
    //     }
    //   }
    //   i++;
    // });
    }
    print('Total del pedido: $totalPedido');
  }

  Future<bool> cart() async {
    
    final String urlPedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    bool success = false;
    DateTime fechaPedido = DateTime.now();
    String fechaFormat = DateFormat('yyyy-MM-dd').format(fechaPedido);
    int idNewPedido = await obtenerUltimoIdPedido();

    final postPedidoApi = await http.post(
      Uri.parse(urlPedidos),
      headers: <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'},
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
      print('Nuevo pedido creado: ${postPedidoApi.body}');
      success = true;
    } else {
      // Ocurrió un error al realizar la solicitud POST
      print('Error al crear el nuevo pedido: ${postPedidoApi.statusCode}');
      success = false;
    }
    print("idPedido: ${idNewPedido + 1}, idCliente: ${widget.clienteId}, fechaPedido: $fechaFormat, precioTotalPedido: $totalPedido, Estado: 1");
  
    final String urlDetallePedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/detallePedidos';
    

    int idPedido = await obtenerUltimoIdPedido();

    for (int i = 0; i < carrito2.length; i++){
      int idDetallePedido = await obtenerUltimoIdDetallePedido();
      final postDetallePedidoApi = await http.post(
        Uri.parse(urlDetallePedidos),
        headers: <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'idDetallePedido': idDetallePedido + 1,
          'idProducto': carrito2[i].idProducto,
          'idPedido': idPedido,
          'cantidadProducto': carrito2[i].cantidad,
          'precioUnitario': carrito2[i].subtotal
        }),
      );
      int idProducto = carrito2[i].idProducto;
      final String urlProductos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/id?id=$idProducto';
      final getProductoApi = await http.get(
        Uri.parse(urlProductos),
        headers: <String, String>{'authorization': basicAuth},
      );
      if(getProductoApi.statusCode == 200){
        Map<String, dynamic> getProducto = jsonDecode(getProductoApi.body);
        int putCantidad = getProducto['saldoInventario'] - carrito2[i].cantidad;
        final String urlProductosPut = 'http://dylanbolivar1-001-site1.ftempurl.com/api/productos/$idProducto';
        final putProductoApi = await http.put(
          Uri.parse(urlProductosPut),
          headers: <String, String>{'authorization': basicAuth, 'Content-Type': 'application/json'},
          body: jsonEncode({
            "idProducto": getProducto['idProducto'],
            "nombreProducto": getProducto['nombreProducto'],
            "descripcion": getProducto['descripcion'],
            "fechaCaducidad": getProducto['fechaCaducidad'],
            "precioVenta": getProducto['precioVenta'],
            "saldoInventario": putCantidad,
            "estado": getProducto['estado']
          })
        );
        if(putProductoApi.statusCode == 204){
          print('Se restaron los productos: ${getProducto['nombreProducto']}, cantidad: ${putCantidad}');
        } else {
          print('Error al actualizar producto ${putProductoApi.statusCode}');
        }
      } else {
        print('Error al obtener productos: ${getProductoApi.statusCode}');
      }

      
      final data = jsonDecode(postDetallePedidoApi.body);
      print(data);
      if (postDetallePedidoApi.statusCode == 200) {
        // La respuesta fue exitosa
        print('Nuevo detalle del pedido creado: ${postDetallePedidoApi.body}');
        success = true;
      } else {
        // Ocurrió un error al realizar la solicitud POST
        print('Error al crear el nuevo pedido: ${postDetallePedidoApi.statusCode}');
        success = false;
      }
      print("idDetallePedido: ${idDetallePedido + 1}, idProducto: ${carrito2[i].idProducto}, idPedido: $idPedido, cantidad: ${carrito2[i].cantidad}, precioUnitario: ${carrito2[i].subtotal}");
    }
    setState(() {
      _isCreating = false;
    });
    if (success){
      return true;
    }else{
      return false;
    }
  }

  Future<int> obtenerUltimoIdPedido() async {
  final String urlPedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/pedidos';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
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
      ? pedidos.map((pedido) => pedido.idPedido ?? 0).reduce((value, element) => value > element ? value : element)
      : 0;

    return idPedido;
  }

  Future<int> obtenerUltimoIdDetallePedido() async {
  final String urlDetallePedidos = 'http://dylanbolivar1-001-site1.ftempurl.com/api/detallepedidos';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var detallepedidos = [];
    final getDetallePedidosApi = await http.get(
      Uri.parse(urlDetallePedidos),
      headers: <String, String>{'authorization': basicAuth},
    );
    if (getDetallePedidosApi.statusCode == 200) {
      final List<dynamic> detallePedidosData = jsonDecode(getDetallePedidosApi.body);
      List<DetallePedido> newData = [];
      for (var item in detallePedidosData) {
        newData.add(DetallePedido.fromJson(item));
      }
      detallepedidos = newData;
    }
  
    int idDetallePedido = detallepedidos.isNotEmpty
      ? detallepedidos.map((detallepedido) => detallepedido.idDetallePedido ?? 0).reduce((value, element) => value > element ? value : element)
      : 0;

    return idDetallePedido;
  }



  void _showErrorDialog(BuildContext context, String errorMessage, String errorMessage2) {
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
        duration: const Duration(milliseconds: 2000),
        width: 350,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        backgroundColor: Colors.red));
  }
  // void addToCart(Product product, int idProduct, String nombre, int quantity, double precioProduct) {
  //   setState(() {
  //     carrito[product.id] = idProduct;
  //     print(idProduct);
  //     print(nombre);
  //     print(precioProduct);
  //     print(quantity);
  //     double subtotal = precioProduct * quantity;
  //     carrito2.add(
  //       Producto(idProducto: idProduct, nombreProducto: nombre, precio: precioProduct, cantidad: quantity, subtotal: subtotal)
  //     );
  //   });
  //   print(carrito2);
  // }

  

  void createOrder() {
    // Aquí puedes implementar la lógica para enviar los detalles del pedido al servidor
    // Puedes acceder a los productos seleccionados desde el mapa "carrito"
    // Realizar una solicitud POST para enviar los detalles del pedido al servidor


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
        ),
        body: ListView.builder(
          itemCount: productos.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(productos[index].nombre),
              //subtitle: Text('\$ ${productos[index].precio.toStringAsFixed(2)}'),
              subtitle: Text('\$ ${NumberFormat('#,###', 'es_ES').format(productos[index].precio)}'),
              trailing: QuantitySelector(
                onSelected: (int quantity) {
                  double precio = productos[index].precio;
                  if (quantity > 0) {
                    // int idProducto = productos[index].id;
                    // String nombre = productos[index].nombre;
                    // double precio = productos[index].precio;
                    // addToCart(productos[index], idProducto, nombre, quantity, precio);
                    addToCart(productos[index], quantity, precio);
                  } else {
                    removeFromCart(productos[index].id, precio, quantity);
                  }
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Row(
            children: [
              Text('Pedir  '),
              Icon(Icons.add_shopping_cart),
            ],
          ),
          onPressed: (){
            obtenerTotalPedido();
            if (carrito2.isNotEmpty){
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text("¿Desea crear el pedido?"),
                    content: Text("Precio total: \$ ${NumberFormat('#,###', 'es_ES').format(totalPedido)}"),
                    actions: [
                      if (_isCreating)
                        Padding(
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 5),
                            child:
                                CircularProgressIndicator()), // Icono de carga
                      TextButton(
                          onPressed: _isCreating
                              ? null
                              : () async {
                                
                                  setState(() {
                                    _isCreating =
                                        true;
                                  });
                                  bool success = false;
                                  try {
                                    // Ejecutar la función cart() y esperar su finalización

                                    // Mostrar el diálogo de carga mientras se ejecuta la función
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false, // Impide que el usuario cierre el diálogo tocando fuera de él
                                      builder: (BuildContext context) {
                                        return PopScope(
                                          canPop: false, // Impide que el usuario cierre el diálogo al presionar el botón de retroceso
                                          child: AlertDialog(
                                            title: const Text("Creando pedido"),
                                            content: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 100),
                                              child: CircularProgressIndicator()
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    success = await cart();

                                    // Esperar un momento antes de cerrar el diálogo para que el usuario pueda verlo
                                    await Future.delayed(Duration(seconds: 1));

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
                                              title: const Text("Pedido creado"),
                                              content: const Text("El pedido se ha creado correctamente."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => PagePedido(
                                                          clienteId: widget.clienteId,
                                                          clienteCorreo: widget.clienteCorreo,
                                                          clienteContrasena: widget.clienteContrasena,
                                                        )));
                                                  },
                                                  child: const Text("Aceptar"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                  
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
                              
                          child:
                              const Text("Cancelar"))
                    ]);
          });
            } else {
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Alerta"),
                  content: const Text("No ha seleccionado productos"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
  final Function(int) onSelected;

  const QuantitySelector({Key? key, required this.onSelected}) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector>
{
  int _quantity = 0;

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onSelected(_quantity);
  }

  void _decrement() {
    setState(() {
      _quantity = (_quantity > 0) ? _quantity - 1 : 0;
    });
    widget.onSelected(_quantity);
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
        Text(_quantity.toString()),
        IconButton(
          onPressed: _increment,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
