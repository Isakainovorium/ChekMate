import 'package:flutter/material.dart';

/// Profile Photo Screen - Onboarding step for profile photo
class ProfilePhotoScreen extends StatelessWidget {
  const ProfilePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Photo'),
      ),
      body: const Center(
        child: Text('Profile Photo Screen'),
      ),
    );
  }
}

