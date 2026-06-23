import 'package:flutter/material.dart';

class DnaStudioFooter extends StatelessWidget {
  const DnaStudioFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.58,
      child: Image.asset(
        'assets/images/dna_studio_white.png',
        height: 30,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
