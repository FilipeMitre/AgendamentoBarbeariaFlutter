import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              _getIconFromPath(icon),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconFromPath(String path) {
    if (path.contains('google')) return Icons.account_circle; // Representa conta Google
    if (path.contains('apple')) return Icons.apple; // Ícone Apple nativo
    if (path.contains('facebook')) return Icons.facebook; // Ícone Facebook nativo
    return Icons.login;
  }
}
