import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/dialog_helper.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/controller/add_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

//Clase editar que permite mostrar la ventana
class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  //Instancia que crea la vista editar
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  //Obtenemos la imagen del controlador
  File? _img;
  //Creamos las variables para almacenar los datos de la base de datos
  String username = "";
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
            userImage = userData['imagenURL'];
            id = userData['uid'];
          });
        }
      }
    }
  }

  //inicializador de procesos
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  //Si selecciona cambiar imagen por galeria, llamar a la eit_profile
  void selectImage() async {
    final image = await pickImage(ImageSource.gallery);
    if (image == null){
      return;
    }
    setState(() {
      _img = File(image.path);
    });
    //Guardar los datos
    StoreData().saveData(_img!, id);
  }

  //Si selecciona la camara obtener la imagen
  void cameraImage() async {
    final image = await pickImage(ImageSource.camera);
    if (image == null){
      return;
    }
    setState(() {
      _img = File(image.path);
    });
    //Guardar datos
    StoreData().saveData(_img!, id);
  }

  //Construir la vista
  @override
  Widget build(BuildContext context) {
    //Obtener la diagonal del dispositivo
    final Responsive responsive = Responsive.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        // Navegar a la página principal
        Navigator.of(context).pushReplacementNamed('/menu');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/menu');
              },
              child: const Icon(Icons.arrow_back_ios, color: Colors.green),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Editar Cuenta',
            style: TextStyle(
                fontSize: responsive.inch * 0.028, color: Colors.green),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/home');
                },
                child: Icon(Icons.home,
                    size: responsive.inch * 0.035, color: Colors.green),
              ),
            )
          ],
        ),

        //Construcción de la ventana editar
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          //Construimos todos los apartados en una lista unica
          child: ListView(
            children: [
              //Espacio entre campos
              const SizedBox(height: 25),
              //Centrar imagen
              Center(
                child: Stack(
                  children: [
                    //Si existe, mostrar imagen del usuario
                    _img != null
                        ? CircleAvatar(
                            //Estilo de la imagen del usuario
                            radius: 60,
                            child: Container(
                              //tamaño de la imagen
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                //Decoración de la imagen
                                border: Border.all(width: 4, color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    //Sombreado
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.1),
                                  )
                                ],
                                //Imprimir la imagen por defecto
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(_img!),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            //Mostrar opciones al oprimir
                            onTap: () {
                              //Si selecciona galeria, obtener la imagen seleccionada
                              DialogHelper.showOptions(context,
                                  (ImageSource? source) async {
                                if (source == ImageSource.gallery) {
                                  selectImage();
                                  //Si se selecciona la camara, abrir la camara
                                } else if (source == ImageSource.camera) {
                                  cameraImage();
                                }
                              });
                            },
                            //Decoración circulo de imagen
                            child: CircleAvatar(
                              radius: 60,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                    )
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(userImage),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    //Lapiz que acompaña el circulo de la imagen
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: Colors.white),
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Espaciado entre campos
              const SizedBox(height: 35),
              Container(
                //Acciones adicionales de la cuenta
                color: Colors.green[400],
                width: double.infinity,
                height: 25,
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Datos personales',
                      style: TextStyle(fontSize: responsive.inch * 0.015)),
                ),
              ),
              //Parametros para edición
              Column(
                children: [
                  ListTile(
                    //Primer apartado, edicion de perfil
                    title: const Text('Nombre de usuario'),
                    //Mostrar nombre actual
                    subtitle: Text(username),
                    onTap: (){
                      DialogHelper.editProfile(
                        context, 
                        'nombre', 
                        username,
                        (newName) {
                          setState(() {
                            username = newName;
                          });
                        });
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      //Si oprime el campo mostrar la edición del nombre
                      onPressed: () {
                        DialogHelper.editProfile(
                          context, 
                          'nombre', 
                          username,
                          (newName) {
                          setState(() {
                            username = newName;
                          });
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(),
                  ),
                  ListTile(
                    //Tercer apartado, edición de contraseña
                    title: const Text('Contraseña'),
                    //Mostrar caracteres de contraseña
                    subtitle: const Text('********'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        DialogHelper.editPassword(context);
                      },
                    ),
                    onTap: (){DialogHelper.editPassword(context);},
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(),
                  ),
                  SizedBox(
                    height: responsive.height * 0.25,
                  ),
                  Container(
                    //Acciones adicionales de la cuenta
                    color: Colors.green[400],
                    width: double.infinity,
                    height: 25,
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Control de la cuenta',
                          style: TextStyle(fontSize: responsive.inch * 0.015)),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Eliminar Cuenta',
                      style: TextStyle(
                          fontSize: responsive.inch * 0.02, color: Colors.red),
                    ),
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onTap: () {
                      DialogHelper.deleteAccount(context, id);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
