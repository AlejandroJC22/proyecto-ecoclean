import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


// Clase principal que representa la pantalla principal de la aplicación.
class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});
  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

// Estado de la pantalla principal.
class _PrincipalPageState extends State<PrincipalPage> {
  // Variable para almacenar el nombre de usuario.
  String username = "";

  // Método que se llama al inicializar el estado de la pantalla.
  @override
  void initState() {
    super.initState();
    // Inicializar la carga de la información del usuario.
    _loadUserInfo();
  }


  // Método asincrónico para cargar la información del usuario.
  Future<void> _loadUserInfo() async {
    // Obtener el usuario actualmente autenticado.
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Obtener el documento del usuario desde Firestore.
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Verificar si existe el documento del usuario en Firestore.
      if (userDoc.exists) {
        // Obtener los datos del usuario como un mapa.
        final userData = userDoc.data() as Map<String, dynamic>;

        // Verificar si el campo 'nombre' existe en los datos del usuario.
        if (userData['nombre'] != null) {
          // Actualizar el estado con el nombre del usuario.
          setState(() {
            username = userData['nombre'];
          });
        }
      } else {
        // Imprimir mensaje si no se encuentra el documento del usuario en Firestore.
        username = "";
      }
    } else {
      // Imprimir mensaje si no se puede obtener el usuario actual.
      username = "No obtuve el usuario";
    }
  }


  // Método para construir la interfaz de la pantalla principal.
  @override
  Widget build(BuildContext context) {
    // Instancia de la clase Responsive para gestionar la responsividad del diseño.
    final Responsive responsive = Responsive.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        // Maneja el evento de presionar el botón de retroceso del teléfono
        // Si el usuario está en la página de inicio, cierra la aplicación
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir de la aplicación?'),
            content: const Text('¿Estás seguro de que quieres salir de la aplicación?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('Salir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      // Estructura principal del widget.
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text('EcoClean Bogotá', style: TextStyle(color: Colors.white),),
          toolbarHeight: 50,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10), 
              child: GestureDetector(
                onTap: () {
                Navigator.of(context).pushNamed('/menu');
              },
              child: const Icon(Icons.menu, color: Colors.white,),
              ),
            ),
          ],
        ),
        // Contenedor principal que abarca toda la pantalla.
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Espaciado superior
              const SizedBox(
                height: 20,
              ),
              // Contenedor para mostrar el saludo al usuario
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 15),
                child: Text(
                  "Bienvenido $username",
                  style: TextStyle(fontSize: responsive.inch * 0.02),
                ),
              ),
              // Espaciado adicional
              const SizedBox(
                height: 30,
              ),
              // Título para las rutas cercanas
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Puntos de recolección cercanos',
                          style: TextStyle(color: Colors.grey,fontSize: responsive.inch * 0.018),
                        ),
                      ),
                    ],
                  ),
                ),
              // Espaciado adicional
              const SizedBox(
                height: 10,
              ),
              // Contenedor para mostrar el mapa con las rutas
              SizedBox(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 300,
                  child: Image.asset(
                    'lib/images/map.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Espaciado adicional
              const SizedBox(
                height: 15,
              ),
              // Título para las empresas prestadoras del servicio
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Empresas prestadoras del servicio',
                          style: TextStyle(color: Colors.grey,fontSize: responsive.inch * 0.018),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              // Espaciado adicional
              const SizedBox(
                height: 10,
              ),
              // Tarjeta deslizable con enlaces a empresas prestadoras del servicio
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildCards(
                          'lib/images/bogota_limpia.png',
                          'https://www.bogotalimpia.com/'),
                      const SizedBox(width: 15),
                      buildCards(
                          'lib/images/ciudad_limpia.jpg',
                          'https://www.ciudadlimpia.com.co/'),
                      const SizedBox(width: 15),
                      buildCards(
                          'lib/images/lime.jpeg', 'https://www.lime.net.co/'),
                      const SizedBox(width: 15),
                      buildCards(
                          'lib/images/area_limpia.png',
                          'https://arealimpia.com.co/'),
                      const SizedBox(width: 15),
                      buildCards(
                          'lib/images/promoambiental.png',
                          'https://www.promoambientaldistrito.com/'),
                    ],
                  ),
                ),
              ),
              // Espaciado adicional
              const SizedBox(
                height: 20,
              ),
              // Elemento de lista con enlace al ChatBot
              ListTile(
                title: const Text(
                  '¿Tienes dudas?',
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
                subtitle: const Text(
                  'Pregúntale a nuestro ChatBot',
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
                trailing: InkWell(
                  onTap: () {
                    // Navegar a la página del ChatBot al hacer clic en el ícono de burbuja de chat.
                    
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir tarjetas deslizables con imágenes y enlaces a empresas prestadoras de servicio.
  Widget buildCards(String imagePath, String url) {
    // Crear instancia de Uri a partir de la cadena de URL proporcionada.
    final uri = Uri.parse(url);
    // Retornar un contenedor con la tarjeta deslizable.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 100,
      height: 100,
      child: Column(
        children: [
          // Widget expandido para ajustar la relación de aspecto de la imagen.
          Expanded(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              // Recortar y redondear las esquinas de la imagen.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  // Configurar acción al hacer clic en la imagen.
                  onTap: () async {
                    // Verificar si se puede lanzar la URL y abrir el enlace.
                    if (!await launchUrl(uri)){
                      launchUrl(uri);
                    }else{
                      return;
                    }
                  },
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}