import 'package:flutter/material.dart';

class MyClaimsScreen extends StatelessWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
      ),
      body: const Center(
        child: Text(
          'My Claims',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}