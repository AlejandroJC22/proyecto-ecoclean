// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}


class _MenuState extends State<Menu> {
//Creamos las variables para almacenar los datos de la base de datos
  String username = "";
  String userEmail = "";
  String userImage = "";
  String id = "";

  //Cargamos los datos de la base de datos
  Future<void> _loadUserInfo() async {
    //Obtenemos los datos del usuario
    final User? user = FirebaseAuth.instance.currentUser;
    //Si no existe el usuario, almacenar los datos en la base de datos con un ID unico
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      //Si existe el usuario, almacenar en las variables los datos de la base de datos
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Verificar que las propiedades existen y no son nulas antes de acceder a ellas
        if (userData['nombre'] != null) {
          setState(() {
            //Asignar el valor a cada variable
            username = userData['nombre'];
            userEmail = userData['correo'];
            userImage = userData['imagenURL'];
            id = userData['uid'];
          });
        }
      }
    }
  }
  //inicializador de procesos
  @override
  void initState(){
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        // Navegar a la página principal
        Navigator.of(context).pushReplacementNamed('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/home');
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.green),
            ),
          )
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Image.network(
                              userImage,
                              fit: BoxFit.contain,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cerrar', style: TextStyle(color: Colors.green),),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: responsive.inch * 0.075,
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(username, style: TextStyle(fontSize: responsive.inch * 0.025),),
                  Text(userEmail, style: TextStyle(fontSize: responsive.inch * 0.025)),
                ],
              ),
              const SizedBox(height: 15,),
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.home, color: Colors.green),
                title: Text('Página Inicial', style: TextStyle(fontSize: responsive.inch * 0.02)),
                onTap: (){
                  Navigator.of(context).pushNamed('/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text('Cuenta', style: TextStyle(fontSize: responsive.inch * 0.02)),
                onTap: (){
                  Navigator.of(context).pushNamed('/account');
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.green),
                title: Text('Ubicaciones Favoritas', style: TextStyle(fontSize: responsive.inch * 0.02)),
                onTap: (){
                  Navigator.of(context).pushNamed('/favorites');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.green),
                title: Text('Configuración', style: TextStyle(fontSize: responsive.inch * 0.02)),
                onTap: (){
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
              SizedBox(height: responsive.height * 0.15,),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.green),
                title: Text('Valoranos', style: TextStyle(fontSize: responsive.inch * 0.02)),
                onTap: (){
                  
                },
              ),
              ListTile(
                title: Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontSize:  responsive.inch * 0.02)),
                leading: const Icon(Icons.logout, color: Colors.red),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}