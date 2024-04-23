import 'package:flutter/material.dart';

class IconsRow extends StatelessWidget {
  final Widget child;
  final Color background;
  const IconsRow({
    super.key,
    required this.child,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
        color: background,
      ),
      child: child,
    );
  }
}