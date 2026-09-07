import 'package:flutter/material.dart';

class GlbModelViewer extends StatelessWidget {
  final String src;

  const GlbModelViewer({super.key, required this.src});

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('3D preview is available in the web app.'),
      );
}
