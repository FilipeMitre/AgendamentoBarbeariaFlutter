import 'package:flutter/material.dart';
import '../models/barbeiro_model.dart';

class BarbeiroCard extends StatelessWidget {
  final BarbeiroModel barbeiro;
  final VoidCallback onTap;

  const BarbeiroCard({
    super.key,
    required this.barbeiro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAberto = barbeiro.status == 'Aberto';

    return GestureDetector(
      onTap: isAberto ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.content_cut,
                color: Color(0xFFFFB84D),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barbeiro.nome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFB84D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        barbeiro.avaliacao.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${barbeiro.distancia.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barbeiro.endereco ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAberto
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAberto ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
              child: Text(
                barbeiro.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAberto ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
            ),

            if (isAberto) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
