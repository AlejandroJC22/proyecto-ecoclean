// ignore_for_file: use_build_context_synchronously

import 'package:ecocleanproyect/components/dialog_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future registerUser(BuildContext context, String name, String email, String password, String confirmPassword) async {

   // Validamos que en los campos hayan datos
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      DialogHelper dialogHelper = DialogHelper(press: (){
        Navigator.of(context).pop();
      });
      dialogHelper.showAlertDialog(context, 'Completa los campos', "Algunos campos se encuentran sin datos, por favor completa todos los campos.", dialogHelper.press);
      return;
    }
    // Validamos el formato del correo electrónico
    if (!email.contains('@') || (!email.endsWith('.com') && !email.endsWith('.co'))) {
      DialogHelper dialogHelper = DialogHelper(press: (){
        Navigator.of(context).pop();
      });
      dialogHelper.showAlertDialog(context, 'Correo invalido', "El correo no es valido, por favor escribe un correo valido", dialogHelper.press);
      return;
    }
    // Verificamos que la contraseña tenga más de 6 caracteres
    if (password.length <= 5) {
      DialogHelper dialogHelper = DialogHelper(press: (){
        Navigator.of(context).pop();
      });
      dialogHelper.showAlertDialog(context, 'Contraseña insegura', "La contraseña debe contener al menos 6 digitos", dialogHelper.press);
      return;
    }
    // Validamos que la contraseña sea la misma
    if (password != confirmPassword) {
      DialogHelper dialogHelper = DialogHelper(press: (){
        Navigator.of(context).pop();
      });
      dialogHelper.showAlertDialog(context, 'Registro fallido', "Las contraseñas ingresadas no coinciden", dialogHelper.press);
    } else {
      // Si las contraseñas coinciden, autenticamos al usuario en la base de datos
      try {
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final User? user = userCredential.user;

        if (user != null) {

          final userId = user.uid;

          final CollectionReference pruebaCollection = FirebaseFirestore.instance.collection('users');

          // Verificar si el usuario ya existe en Cloud Firestore
          final QuerySnapshot existingUser = await pruebaCollection.where('uid', isEqualTo: userId).get();

          //Verificar si no existe el usuario en la base de datos
          if (existingUser.docs.isEmpty) {
            // El usuario no existe en Firestore, así que lo agregamos
            await pruebaCollection.doc(userId).set({
              'uid': userId,
              'nombre': name,
              'correo': email,
              'imagenURL': 'https://static.vecteezy.com/system/resources/previews/008/442/086/non_2x/illustration-of-human-icon-user-symbol-icon-modern-design-on-blank-background-free-vector.jpg',
              'provider': "Email"
            });

          }
          DialogHelper dialogHelper = DialogHelper(press: (){
            Navigator.of(context).pushNamed('/'); 
          });
          dialogHelper.showAlertDialog(context, 'Registro exitoso', "Se ha completado el registro, por favor inicia sesión", dialogHelper.press);

        } else {
          // Mostramos un mensaje de error en caso de que no se almacenen los datos en la base de datos
          DialogHelper dialogHelper = DialogHelper(press: (){
            Navigator.of(context).pop();
          });
          dialogHelper.showAlertDialog(context,"Registro Fallido", "No se pudo obtener el ID del usuario", dialogHelper.press);
        }
      } catch (error) {
        // No se borran los campos en caso de un error
        DialogHelper dialogHelper = DialogHelper(press: (){
          Navigator.of(context).pop();
        });
        dialogHelper.showAlertDialog(context,"Error al registrar", "El usuario ya existe, por favor inicie sesión", dialogHelper.press);

      }
  }
}
