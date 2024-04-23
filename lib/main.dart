import 'package:ecocleanproyect/components/theme.dart';
import 'package:ecocleanproyect/views/configuration_page.dart';
import 'package:ecocleanproyect/views/favorites_page.dart';
import 'package:ecocleanproyect/views/forgot_password_page.dart';
import 'package:ecocleanproyect/views/home_page.dart';
import 'package:ecocleanproyect/views/login.dart';
import 'package:ecocleanproyect/views/menu.dart';
import 'package:ecocleanproyect/views/register_page.dart';
import 'package:ecocleanproyect/views/social_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(create: ((context) => ThemeProvider()),
    child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: Provider.of<ThemeProvider>(context).themeData,
    title: 'EcoClean Bogotá',
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const PrincipalPage();
        }else {
          return const LoginPage();
        }
      },
    ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/settings': (context) => const SettingPage(),
        '/home': (context) => const PrincipalPage(),
        '/account': (context) => const SocialPage(),
        '/menu': (context) => const Menu(),
        '/favorites': (context) => const FavoritesPage(),
        '/forgot': (context) => const ForgotPass(),
      },
    );
  }
}