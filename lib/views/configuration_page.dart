
import 'package:ecocleanproyect/components/responsive.dart';
import 'package:ecocleanproyect/components/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        // Navegar a la página principal
        Navigator.of(context).pushReplacementNamed('/menu');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10,),
            child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/menu');
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.green,),
            ),
          ),
          centerTitle: true,
          title: Text('Configuración', style: TextStyle(fontSize: responsive.inch * 0.028, color: Colors.green),),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15), 
              child: GestureDetector(
                onTap: () {
                Navigator.of(context).pushNamed('/home');
              },
              child: Icon(Icons.home, size: responsive.inch * 0.035, color: Colors.green),
              ),
            ), 
          ],
        ),
        body: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 2,),
                ListTile(
                  title: Text('Ciudad', style: TextStyle(fontSize: responsive.inch * 0.02)),
                  subtitle: Text('Bogotá', style: TextStyle(fontSize: responsive.inch * 0.017)),
                  onTap: (){},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(),
                ),
                ListTile(
                  title: Text('Notificaciones', style: TextStyle(fontSize: responsive.inch * 0.02)),
                  onTap: (){},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(),
                ),
                ListTile(
                  title: Text('Modo Oscuro', style: TextStyle(fontSize: responsive.inch * 0.02)),
                  trailing: Switch(
                    value: Provider.of<ThemeProvider>(context).isDarkTheme,
                    onChanged: (_) {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(),
                ),
                ListTile(
                  title: Text('Acerca de', style: TextStyle(fontSize: responsive.inch * 0.02)),
                  onTap: (){},
                ),   
              ],
      
            ),
          ],
        )
      ),
    );
  }
}