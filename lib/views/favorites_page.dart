import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/dialog_helper.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {

  String home = '';
  String work = '';
  TextEditingController addressController = TextEditingController();

  // Método que se llama al inicializar el estado de la pantalla.
  @override
  void initState() {
    super.initState();
    // Inicializar la carga de la información del usuario.
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    //final Location location = Location();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    try {
      if (user != null) {
        // Obtener el UID del usuario actual
        String uid = user.uid;

        // Obtener datos de la colección 'users' en Firestore
        DocumentSnapshot<Map<String, dynamic>> userDocument =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        // Asignar los datos a las variables home y work
        setState(() {
          home = userDocument['direccion_casa'] ?? '';
          work = userDocument['direccion_trabajo'] ?? '';
        });
      }

      //final LocationData locationData = await location.getLocation();
      //setState(() {currentLocation = locationData;currentLocationInstance = CurrentLocation(currentLocation);});
    } catch (e) {
      // ignore: avoid_print
      print("Error obtaining location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        // Navegar a la página principal
        Navigator.of(context).pushReplacementNamed('/menu');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10,),
            child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/menu');
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.green),
            ),
          ),
          centerTitle: true,
          title: Text('Rutas favoritas', style: TextStyle(fontSize: responsive.inch * 0.028, color: Colors.green),),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15), 
              child: GestureDetector(
                onTap: () {
                Navigator.of(context).pushNamed('/home');
              },
              child: Icon(Icons.home, size: responsive.inch * 0.035, color: Colors.green),
              ),
            )
          ],
        ),
        body:  SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20,),
              ListTile(
                title: Text(
                  'Tu ubicación actual', 
                  style: TextStyle(fontSize: responsive.inch * 0.018),
                ),
                leading: const Icon(Icons.add_location_alt, color: Colors.green,),
                onTap: (){},
              ),
              ListTile(
                title: Text(
                  'Ver en el mapa', 
                  style: TextStyle(fontSize: responsive.inch * 0.018),
                ),
                leading: const Icon(Icons.map, color: Colors.green,),
                onTap: (){},
              ),
              const SizedBox(height: 10,),
              Container(
                //Acciones adicionales de la cuenta
                color: Colors.green[400],
                width: double.infinity,
                height: 25,
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ver rutas favoritas',
                    style: TextStyle(fontSize: responsive.inch * 0.015)
                  ),
                ),
              ),
              ListTile(
                title: Text('Casa', style: TextStyle(fontSize: responsive.inch * 0.018)),
                subtitle: Text('Pulsa para ver', style: TextStyle(color: Colors.grey, fontSize: responsive.inch * 0.013)),
                onTap: (){},
                trailing: GestureDetector(
                  onTap: () {
                    DialogHelper.editProfile(
                      context,
                      'Casa',
                      home,
                      (newHome) {
                        setState(() {
                          home = newHome;
                        });
                      },
                    );
                  },
                  child: const Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              ListTile(
                title: Text('Trabajo', style: TextStyle(fontSize: responsive.inch * 0.018)),
                subtitle: Text('Pulsa para ver', style: TextStyle(color: Colors.grey, fontSize: responsive.inch * 0.013)),
                onTap: (){},
                trailing: GestureDetector(
                  onTap: () {
                    DialogHelper.editProfile(
                      context,
                      'Trabajo',
                      work,
                      (newWork) {
                        setState(() {
                          work = newWork;
                        });
                      },
                    );
                  },
                  child: const Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              SizedBox(height: responsive.height * 0.3,),
              Container(
                //Acciones adicionales de la cuenta
                color: Colors.green[400],
                width: double.infinity,
                height: 25,
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Configuración adicional',
                    style: TextStyle(fontSize: responsive.inch * 0.015)
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar ruta', style: TextStyle(fontSize: responsive.inch * 0.018, color: Colors.red)),
                subtitle: Text('Pulsa para seleccionar ruta a eliminar', style: TextStyle(color: Colors.grey, fontSize: responsive.inch * 0.013)),
                onTap: (){
                  DialogHelper.deleteRoute(context, () => null);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}