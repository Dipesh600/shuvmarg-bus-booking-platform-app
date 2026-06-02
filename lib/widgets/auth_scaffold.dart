import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2A26), // Very dark emerald top
              Color(0xFF0D3530), // Dark emerald
              Color(0xFF0F3E38), // Mid dark
              Color(0xFF134840), // Slightly lighter towards bottom
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
