import 'package:ecocleanproyect/components/responsive.dart';
import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget{
  final Widget child;
  const TextFieldContainer({super.key,
    required this.child,
});

  @override
  Widget build(BuildContext context){
    Responsive responsive = Responsive.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: responsive.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }

}