// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

//Conexión con el almacenamiento de firebase
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Obtener la imagen seleccionada por el usuario
Future<XFile?> pickImage(ImageSource source) async{
  final ImagePicker imagePicker = ImagePicker();

  //Clasificar los datos de la imagen
  XFile? file = await imagePicker.pickImage(source: source);

  //Enviar los datos a add_data
  return file;
}



//Clase para guardar la imagen en el almacenamiento de Firebase
class StoreData {
  Future<String> uploadImage(String childName, String userId, File image) async {
    //Le asignamos el id a la imagen subida por el usuario
    Reference ref = _storage.ref().child(childName).child(userId);
    //Subimos el archivo a la base de datos
    final UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    //Obtenemos la url para mostrarlo por pantalla
    String urlImage = await snapshot.ref.getDownloadURL();
    //Retornamos la url
    return urlImage;
  }
  Future<void> saveData (File image, String userID) async{
   try {
      String imageUrl = await uploadImage('profileImages', userID, image);

      // Obtiene una referencia al documento del usuario
      final DocumentReference userRef = _firestore.collection('users').doc(userID);

      if (imageUrl.isNotEmpty) {
        // Actualiza el campo "imagenURL" con la nueva URL de descarga
        await userRef.update({'imagenURL': imageUrl});
      }
    } catch (e) {
      print(e.toString());
    }
  }
  //Eliminar los datos del usuario
  Future<void> deleteData(String userId) async {
    try {
      // Obtener el usuario actual
      User? user = FirebaseAuth.instance.currentUser;

      // Verificar si el usuario actual es nulo (no debería serlo si ha iniciado sesión)
      if (user != null) {

        // Eliminar datos de FirebaseAuth (cerrar sesión y eliminar la cuenta permanentemente)
        await user.delete();

        // Eliminar datos de FirebaseFirestore
        await _firestore.collection('users').doc(userId).delete();

        //Obtener la referencia a la carpeta de imagenes
        Reference storageRef = _storage.ref().child('profileImages').child(userId);

        //Listar los archivos en el directorio
        ListResult result = await storageRef.listAll();

        //Si hay archivos, eliminarlos
        if (result.items.isNotEmpty){
          for (Reference fileRef in result.items) {
            await fileRef.delete();
          }
        }else{
          return;
        }
      }
      // Mostrar un mensaje de éxito o realizar otras acciones después de eliminar los datos
      print("Datos eliminados con éxito.");
    } catch (error) {
      print("Error al eliminar datos: $error");
      // Mostrar un mensaje de error o realizar otras acciones en caso de error
    }
  }
}