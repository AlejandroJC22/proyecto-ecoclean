// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecocleanproyect/components/buttons.dart';
import 'package:ecocleanproyect/components/dialog_helper.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ForgotPass extends StatefulWidget {
  const ForgotPass ({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

//Vista olvido de contraseña
class _ForgotPassState extends State<ForgotPass>{
  //Variable contenedora de correo electronico
  TextEditingController emailController = TextEditingController();

  //Inicializador de procesos
  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  //Conexión con la base de datos
  Future<void> passwordReset() async {
    DialogHelper dialogHelper = DialogHelper(press: (){
      Navigator.of(context).pop();
    });

    try {
      //Buscar el correo ingresado en la base de datos
      final email = emailController.text.trim();
      final userExists = await doesEmailExistInFirestore(email);

      if (userExists) {
        // El correo está registrado en Firestore, puedes enviar el correo de restablecimiento
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        DialogHelper toLogin = DialogHelper(press: (){
          Navigator.of(context).pushNamed('/login');
        });
        //Mostrar información sobre recuperación de contraseña
        dialogHelper.showAlertDialog(
          context,
          "Correo enviado", 
          "Se ha enviado un correo electrónico con el enlace de recuperación de contraseña", 
          toLogin.press
        );
        
        
      } else {
        // El correo no está registrado en Firestore
        dialogHelper.showAlertDialog(
          context,
          "Datos erróneos",
          "El correo ingresado no se encuentra registrado en nuestra base de datos, por favor verifique el correo",
          dialogHelper.press
        );
      }
    } on FirebaseAuthException catch (e) {
      
      // Manejo de errores de Firebase Authentication
      if (e.code == 'invalid-email') {
        dialogHelper.showAlertDialog(
          context, 
          "Correo inválido", 
          "Por favor ingrese un correo válido.",
          dialogHelper.press
        );
      } else {
        dialogHelper.showAlertDialog(
          context, 
          "Datos erróneos", 
          "Por favor ingrese el correo para recuperar contraseña",
          dialogHelper.press
        );
      }
    }
  }

  //Booleano identificador de correo ingresado
  Future<bool> doesEmailExistInFirestore(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
    //Buscar en la colección users, que sea igual al correo de la base de datos, un correo unico
        .collection('users')
        .where('correo', isEqualTo: email)
        .limit(1)
        .get();

    //Retornar la información
    return result.docs.isNotEmpty;
  }

  //Construir la vista
  @override
  Widget build(BuildContext context) {
    //Obtener la diagonal del dispositivo
    final Responsive responsive = Responsive.of(context);
    return SafeArea(
      //Construccion de la ventana forgot_password
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de inicio de sesión aquí
                  Navigator.of(context).pop();
                },
                //texto identificador
                child: Text("Cancelar", style: TextStyle(fontSize: responsive.inch * 0.015, color: Colors.green)),
              ),
              SizedBox(width: responsive.inch*0.145,),
              Image.asset("lib/images/logo.png", width: 32, height: 32),
            ],
          ),
        ),
        //Cuerpo de la ventana
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              //Titulo inicial
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Text("Encuentra tu cuenta",
                style: TextStyle(fontSize: responsive.inch * 0.025, fontWeight: FontWeight.bold)),
              ),
              //Espaciado entre campos
              const SizedBox(height: 20),
              //Texto informativo
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Text("Introduce el correo electrónico asociado a tu cuenta para cambiar tu contraseña",
                style: TextStyle(fontSize: responsive.inch * 0.018)),
              ),
              //Espaciado entre campos
              const SizedBox(height: 15),
              //Espacio de ingreso de texto
              TextFieldContainer(
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    icon: Icon(Icons.person, color:Colors.green[100]),
                    border: InputBorder.none
                  ),
                )
              ),
              //Container boton
              Buttons(
                text: 'Restablecer contraseña',
                press: () async{
                  passwordReset();
                }
              ),
            ],
          ),
        ),
      )

    );
  }

}