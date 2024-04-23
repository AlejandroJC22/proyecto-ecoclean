// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Future<User?> signInWithEmail(BuildContext context, String email, String password) async{

  try{
    // Solicitar acceso al correo electrónico con los datos ingresados
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    Navigator.of(context).pushNamed('/home');
    // Si los datos no coinciden con la base de datos, mostrar error
  } catch (e) {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Datos incorrectos"),
        content: const Text('Los datos ingresados son erroneos o no estas registrado'),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text('Volver', style: TextStyle(color: Colors.green),)
          )
        ],
      );
    });
  }
  return null;
}