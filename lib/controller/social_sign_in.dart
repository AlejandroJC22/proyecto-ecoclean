// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter_login/twitter_login.dart';


//Clase para autenticar al usuario a la base de datos por facebook
class FirebaseAuthService {

  //Variable que almacena las instancias de autenticación
  final _auth = FirebaseAuth.instance;
  //Variable que almacena los datos del usuario en la base de datos
  final _firestore = FirebaseFirestore.instance;
  
  //Crear el proceso de inicio de sesión con facebook
  Future<User?> signInWithFacebook() async {
    //Accedemos al perfil publico y los datos publicos del usuario
    final LoginResult loginResult = await FacebookAuth.instance.login();

    //Si la autenticacion fue exitosa
    if (loginResult.status == LoginStatus.success) {
      try {
        //Almacenamos las llaves de acceso de facebook en variables
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

        //Obtenemos los datos publicos del usuario
        final userData = await FacebookAuth.i.getUserData(fields: "name,email,picture.width(200)");
        //Almacenamos las credenciales en Firebase
        final UserCredential userCredential = await _auth.signInWithCredential(facebookAuthCredential);
        //Almacenamos las credenciales del usuario en una variable
        final User? user = userCredential.user;

        //Llamamos a la colección del usuario en la base de datos
        final userRef = _firestore.collection('users').doc(user!.uid);

        //Creamos un mapa con los datos que deseas almacenar
        final userDataMap = {
          'correo': userData['email'],
          'nombre': userData['name'],
          'imagenURL': userCredential.user!.photoURL,
          'provider': "Facebook",
          //Asignamos el mismo id en la base de datos como en la autenticación
          'uid': user.uid
        };

        //Guardamos los datos en la base de datos
        await userRef.set(userDataMap, SetOptions(merge: true));

        return user;
      } catch (e) {
        //Si la autenticacion no fue exitosa, mostrar error
        print('Error en la autenticación con Facebook: $e');
        return null;
      }
    } else {
      print('No se logro establecer la conexión con facebook');
    }
    return null;
  }
  //Cerrar la sesión del usuario
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // El usuario canceló el inicio de sesión.
      } else {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        // Iniciar sesión con las credenciales de Google.
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Almacenar las credenciales del usuario en una variable
        final User? user = userCredential.user;

        if (user != null) {
          final userId = user.uid;
          // Crear una referencia a la colección "users" en Cloud Firestore
          final CollectionReference usersCollection = _firestore.collection('users');

          // Verificar si el usuario ya existe en Cloud Firestore
          final DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

          if (!userDoc.exists) {
            // El usuario no existe en Firestore, así que lo agregamos con los datos del usuario
            await usersCollection.doc(userId).set({
              'uid': userId,
              'nombre': user.displayName,
              'correo': user.email,
              'imagenURL': user.photoURL,
              'provider': "Google"
            });

            // Si es primer ingreso, almacenamos los datos y mostramos la pantalla inicial
            print('Usuario agregado a Firestore.');
          }

          // Redirigir a la pantalla principal
          Navigator.pushReplacementNamed(context, '/home');
        }
        return userCredential;
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  //Clase para autenticar al usuario a la base de datos por twitter
  Future<UserCredential?> signInWithTwitter(BuildContext context) async {
      //Almacenamos las llaves de acceso de twitter en variables
      final twitterLogin = TwitterLogin(
        apiKey: "164cI0dc31J3xbeA8DY3XKIQg",
        apiSecretKey: "pf9esqNGskF9OkXE2r1WhV9qcanMwLoJLo3aBoVBhaeuLpsnkw",
        redirectURI: "https://ecocleanproyect.firebaseapp.com/__/auth/handler",
      );

      final authResult = await twitterLogin.login();

      if(authResult.status == TwitterLoginStatus.loggedIn){
        try {
          final credential = TwitterAuthProvider.credential(
            accessToken: twitterLogin.apiKey,
            secret: twitterLogin.apiSecretKey            
          );
          final UserCredential userCredential = await _auth.signInWithCredential(credential);

          final User? user = userCredential.user;

          if(user != null){
            final userId = user.uid;

            final CollectionReference pruebaCollection = FirebaseFirestore.instance.collection('users');

            final QuerySnapshot existingUser = await pruebaCollection.where('uid', isEqualTo: userId).get();

            if (existingUser.docs.isEmpty) {
              // El usuario no existe en Firestore, así que lo agregamos
              String correo = user.email ?? "";
              await pruebaCollection.doc(userId).set({
                'uid': userId,
                'nombre': user.displayName,
                'correo': correo,
                'imagenURL': user.photoURL ?? "",
                'provider': "Twitter"
              });

              print('Usuario agregado a Firestore.');
              
            } else {
              print('El usuario ya existe en Firestore.');
            }
            Navigator.pushReplacementNamed(context, '/home');
            return userCredential;
          }
        } catch (e) {
          print(e.toString());
        }
      }
      return null;
    }
  
}