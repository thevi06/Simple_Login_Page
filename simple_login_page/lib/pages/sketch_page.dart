import 'package:flutter/material.dart';

class SketchPage extends StatelessWidget {
  const SketchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sketch'),
      ),
      body: const Center(
        child: Text('Sketch Page'),
      ),
    );
  }
}
