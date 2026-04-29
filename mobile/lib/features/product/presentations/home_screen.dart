import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArudoCare Home'),
        backgroundColor: const Color(0xFF39A28F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Color(0xFF39A28F)),
            SizedBox(height: 20),
            Text(
              'Welcome to ArudoCare!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('placeholder'),
          ],
        ),
      ),
    );
  }
}