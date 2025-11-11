import 'package:flutter/material.dart';
import '../models/produto_model.dart';

class ProdutoCard extends StatelessWidget {
  final ProdutoModel produto;
  final int quantidade;
  final VoidCallback onAdicionar;
  final VoidCallback onRemover;

  const ProdutoCard({
    super.key,
    required this.produto,
    required this.quantidade,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          // Imagem do produto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                produto.imagemUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.shopping_bag,
                    color: Color(0xFFFFB84D),
                    size: 32,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Informações do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${produto.preco.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFB84D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Controles de quantidade
          if (quantidade > 0)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    color: Colors.black,
                    onPressed: onRemover,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$quantidade',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    color: Colors.black,
                    onPressed: onAdicionar,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: Colors.black,
                onPressed: onAdicionar,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
