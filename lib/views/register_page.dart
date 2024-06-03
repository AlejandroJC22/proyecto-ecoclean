import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/controller/register_data.dart';
import 'package:ecocleanproyect/controller/social_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:ecocleanproyect/components/buttons.dart';
import 'package:ecocleanproyect/components/text_field.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage ({super.key});

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  bool _obscureText = true;
  final _auth = FirebaseAuthService();


  @override
  Widget build(BuildContext context){
    final Responsive responsive = Responsive.of(context);
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 15),

                Image.asset(
                  'lib/images/logo.png',
                  width: responsive.width * 0.25,
                ),

                const SizedBox(height: 30),

                Text('Registrarte', style: TextStyle(fontSize: responsive.inch * 0.03,),),

                const SizedBox(height: 30),
                
                TextFieldContainer(child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nombre',
                    icon: Icon(Icons.person, color:Colors.green[100]),
                    border: InputBorder.none
                  ),
                )),

                const SizedBox(height: 20,),

                TextFieldContainer(child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    icon: Icon(Icons.mail, color:Colors.green[100]),
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

                const SizedBox(height: 20,),

                TextFieldContainer(child: TextField(
                  obscureText: _obscureText,
                  controller: confirmpasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirma la contraseña',
                    icon: Icon(Icons.lock, color:Colors.green[100]),
                    suffixIcon: showPassword(),
                    border: InputBorder.none
                  ),
                )),

                Buttons(text: 'Registrarse',
                    press: () async{
                      final name = nameController.text;
                      final email = emailController.text;
                      final password = passwordController.text;
                      final confirmPassword = confirmpasswordController.text;

                      registerUser(context, name, email, password, confirmPassword);
                    }
                ),

                const SizedBox(height: 10,),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Tienes una cuenta?', style: TextStyle(fontSize: responsive.inch * 0.02),),
                    TextButton(
                      onPressed: (){Navigator.of(context).pop(); }, 
                      child: Text('Ingresar', style: TextStyle(color: Colors.green[300], fontSize: responsive.inch * 0.02),
                      )
                    )
                  ],
                ),

                const SizedBox(height: 30,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'O continua con',
                          style: TextStyle(color: Colors.grey[600],fontSize: responsive.inch * 0.02),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        //Validar los datos de inicio con Facebook
                        await _auth.signInWithFacebook();
                      },
                      backgroundColor: const Color.fromARGB(255, 66, 103, 178),
                      child: Image.asset(
                        'lib/images/facebook.png',
                        color: Colors.white,
                        width: responsive.inch * 0.04,
                      ),
                    ),
                    const SizedBox(width: 12,),
                    FloatingActionButton(
                      onPressed: () async {
                        final credential = await _auth.signInWithGoogle(context);
                        if (credential != null) {
                          // Redirigir a la pantalla principal si el inicio de sesión fue exitoso
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'lib/images/google.png',
                        width: responsive.inch * 0.04,
                      ),
                    ),
                  ],
                )

              ],
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