import 'package:flutter/widgets.dart';
import 'dart:math' as math;

//Clase para definir pulgadas de pantalla y definir tamaño
class Responsive {
  //Variables para calculo
  final double width, height, inch;

  //Definir requerimientos de la clase
  Responsive({
    required this.width,
    required this.height,
    required this.inch,
  });
  //Contenedor del tamaño de la diagonal del dispositivo
  factory Responsive.of(BuildContext context) {
    //Obtenemos la cantidad de pixeles de la pantalla
    final MediaQueryData data = MediaQuery.of(context);
    //Almacenamos el dato en una variable
    final size = data.size;

    //Calculamos la diagonal de la pantalla en pulgadas mediante el teorema de pitagoras
    final inch = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));
    return Responsive(width: size.width, height: size.height, inch: inch);
  }
  //calculamos el ancho de la pantalla
  double wp(double percent) {
    return width * percent / 100;
  }

  //calculamos el el alto de la pantalla
  double hp(double percent) {
    return width * percent / 100;
  }

  //calculamos la longitud diagonal de la pantalla
  double ip(double percent) {
    return width * percent / 100;
  }
}