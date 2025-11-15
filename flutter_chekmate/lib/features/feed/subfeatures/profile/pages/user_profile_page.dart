import 'package:flutter/material.dart';

/// User Profile Page - View other users' profiles
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: const Center(
        child: Text('User Profile Page'),
      ),
    );
  }
}

