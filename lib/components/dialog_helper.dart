// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/components/text_field.dart';
import 'package:ecocleanproyect/controller/add_image.dart';
import 'package:ecocleanproyect/views/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DialogHelper {
  final VoidCallback press;

  DialogHelper({required this.press});
  void showAlertDialog(BuildContext context, String title, String message, press) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: press,
              child: const Text("Aceptar", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
  static void editProfile(BuildContext context, String field, String initialValue, Function(String) onEdit) {
    String? newValue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar $field'),
          content: TextFormField(
            initialValue: initialValue,
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cancelar la edición
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                // Actualizar el campo
                if (newValue != null && newValue!.isNotEmpty) {
                  onEdit(newValue!);

                  // Actualizar el campo correspondiente en Firestore
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    final userId = user.uid;

                    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

                    try {
                      if (field == 'nombre') {
                        await userRef.update({'nombre': newValue});
                      } else if (field == "Casa"){
                        await userRef.update({'direccion_casa': newValue});
                      }else if (field == "Trabajo"){
                        await userRef.update({'direccion_trabajo': newValue});
                      }

                      // Mostrar Snackbar si la actualización fue exitosa
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos actualizados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Mostrar Snackbar si la actualización falla
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo actualizar los datos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Actualizar', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  //Ventana para editar contraseña
  static void editPassword(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldContainer(
                  child: TextField(
                  obscureText: obscureText,
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña antigua',
                    icon: Icon(Icons.lock, color:Colors.green[100]),
                    border: InputBorder.none
                  ),
                )),
                const SizedBox(height: 3,),
                TextFieldContainer(
                  child: TextField(
                  obscureText: obscureText,
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña nueva',
                    icon: Icon(Icons.lock, color:Colors.green[100]),
                    border: InputBorder.none
                  ),
                )),
                const SizedBox(height: 3,),
                TextFieldContainer(
                  child: TextField(
                  obscureText: obscureText,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirmar contraseña',
                    icon: Icon(Icons.lock, color:Colors.green[100]),
                    border: InputBorder.none
                  ),
                )),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPass()
                      )
                    );
                  },
                  child: Text('Olvidé mi contraseña', style: TextStyle(fontSize: responsive.inch * 0.015, color: Colors.grey)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cancelar la edición
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (currentPassword.isNotEmpty &&
                    newPassword.isNotEmpty &&
                    confirmPassword.isNotEmpty) {
                  if (newPassword == confirmPassword) {
                    try {
                      // Cambiar la contraseña
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        AuthCredential credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentPassword,
                        );

                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPassword);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña cambiada exitosamente.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario no autenticado.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Error al cambiar la contraseña. Verifica la contraseña actual.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    Navigator.of(context).pop();
                  } else {
                    // Mostrar un mensaje de error si las contraseñas no coinciden
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las contraseñas no coinciden.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Mostrar un mensaje de error si algún campo está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Actualizar', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  static void showOptions(BuildContext context, Function(ImageSource) onSelect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen desde:'),
          actions: [
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                onSelect(ImageSource.gallery); // Ir a la galería
              },
              leading: const Icon(Icons.photo),
              title: const Text('Galería'),
            ),

            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                onSelect(ImageSource.camera); // Usar la cámara
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),      
            ),
            
            ListTile(
              onTap: (){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: const Text('¿Está seguro que desea eliminar la imagen?'),
                    actions: [
                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        }, 
                        child: const Text('Cancelar', style: TextStyle(color: Colors.green),)
                      ),
                      TextButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            //Conexión con el almacenamiento de firebase
                            final FirebaseStorage storage = FirebaseStorage.instance;
                            // Eliminar datos de FirebaseStorage
                            var userID = user.uid;
                            await storage.ref().child('profileImages').child(userID).delete();

                            final CollectionReference pruebaCollection = FirebaseFirestore.instance.collection('users');
                            await pruebaCollection.doc(user.uid).update({
                              'imagenURL': 'https://static.vecteezy.com/system/resources/previews/008/442/086/non_2x/illustration-of-human-icon-user-symbol-icon-modern-design-on-blank-background-free-vector.jpg',
                            });
                            Navigator.of(context).pushNamed('/account');
                            // Mostrar Snackbar si la actualización fue exitosa
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Datos actualizados correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }else{
                            // Mostrar Snackbar si la actualización fue exitosa
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo completar la acción'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }, 
                        child: const Text('Aceptar', style: TextStyle(color: Colors.red),),
                        
                      ),
                    ],
                  );
                });
              },
              leading: const Icon(Icons.delete, color: Colors.red,),
              title: const Text('Eliminar imagen', style: TextStyle(color: Colors.red),),
            ),

            ListTile(
              onTap: () {
                Navigator.of(context).pop(); // Cancelar
                // Mostrar Snackbar si la actualización fue exitosa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo realizar la acción'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  static void deleteAccount(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Estás seguro de que quieres eliminar todos los datos?\n Esta acción es irreversible"),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
            ),
            TextButton(
              child: const Text("Aceptar", style: TextStyle(color: Colors.red),),
              onPressed: () async {
                // Crear una instancia de StoreData
                StoreData storeData = StoreData();

                // Llamar al método deleteData en la instancia creada
                await storeData.deleteData(id);
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                // Puedes redirigir a la pantalla de inicio de sesión después de eliminar los datos
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  static void deleteRoute(BuildContext context, Function() onSelect){
    Responsive responsive = Responsive.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar ruta a eliminar:'),
          actions: [
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                
              },
              leading: const Icon(Icons.home),
              title: const Text('Casa'),
            ),

            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                
              },
              leading: const Icon(Icons.work,),
              title: const Text('Trabajo'),
            ),

            ListTile(
              onTap: () {
                Navigator.of(context).pop(); // Cancelar
              },
              title: Text('Eliminar todas las ubicaciones', style: TextStyle(color: Colors.red, fontSize: responsive.inch * 0.015),),
              leading: const Icon(Icons.delete_forever, color: Colors.red,),
            ),
          ],
        );
      },
    );
  }
  
}




