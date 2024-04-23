import 'package:ecocleanproyect/components/responsive.dart';
import 'package:flutter/material.dart';

class Buttons extends StatelessWidget{
  final String text;
  final VoidCallback press;

  const Buttons ({
    super.key,
    required this.text,
    required this.press,
  });

  @override
  Widget build(BuildContext context){
    final Responsive responsive = Responsive.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: responsive.width * 0.9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          color: Colors.green[300],
        ),
        child: TextButton(
          onPressed: press,
          child: Text(text,
            style: TextStyle(color: Colors.white, fontSize: responsive.inch * 0.02),
          ),
        ),
      ),
    );
  }
}