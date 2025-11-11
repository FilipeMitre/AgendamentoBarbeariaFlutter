import 'package:flutter/material.dart';
import 'produtos_screen.dart';
import 'bebidas_screen.dart';
import '../widgets/recomendacao_card.dart';

class RecomendacoesScreen extends StatelessWidget {
  const RecomendacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opções Disponíveis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Card Produtos
              RecomendacaoCard(
                icon: Icons.shopping_bag,
                color: Colors.blue,
                title: 'Produtos',
                subtitle: 'Cremes de cabelo, gel e outros',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProdutosScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Card Bebidas
              RecomendacaoCard(
                icon: Icons.local_bar,
                color: Colors.orange,
                title: 'Bebidas',
                subtitle: 'Cervejas, refrigerante e outras',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BebidasScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
