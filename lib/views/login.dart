import 'dart:io';

import 'package:ecocleanproyect/components/buttons.dart';
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/components/text_field.dart';
import 'package:ecocleanproyect/controller/email_sign_in.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage ({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;


  @override
  Widget build(BuildContext context){
    final Responsive responsive = Responsive.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
      
                  Image.asset(
                    'lib/images/logo.png',
                    width: responsive.width * 0.6,
                  ),
                  
                  const SizedBox(height: 30),
                  Text('Iniciar Sesión', style: TextStyle(fontSize: responsive.inch * 0.03, ),),
                  const SizedBox(height: 30),
      
                  TextFieldContainer(child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      icon: Icon(Icons.person, color:Colors.green[100]),
                      border: InputBorder.none
                    ),
                  )),
      
                  const SizedBox(height: 20,),
      
                  TextFieldContainer(child: TextField(
                    obscureText: _obscureText,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      icon: Icon(Icons.lock, color:Colors.green[100]),
                      suffixIcon: showPassword(),
                      border: InputBorder.none
                    ),
                  )),
      
                  Buttons(text: 'Iniciar Sesión',
                    press: () async{
                      final String email = emailController.text;
                      final String password = passwordController.text;
      
                      signInWithEmail(context, email, password);
                    }
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed('/forgot');
                        }, 
                        child: Text('¿Olvidaste tu contraseña?', 
                        style: TextStyle(color: Colors.grey, fontSize: responsive.inch * 0.02),))
                    ],
                  ),
                  
                  const SizedBox(height: 50,),
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta?', style: TextStyle(fontSize: responsive.inch * 0.02),),
                      TextButton(onPressed: (){
                        Navigator.of(context).pushNamed('/register');
                      }, child: Text('Registrarte', style: TextStyle(color: Colors.green[300], fontSize: responsive.inch * 0.02)))
                    ],
                  )
                ],
              ),
            ),
          ),
      
        ),
      ),
    );
  }


  Widget showPassword(){
    return IconButton(onPressed: (){
      setState(() {
        _obscureText = !_obscureText;
      });
    }, icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off), color: Colors.green[100]);
  }
}