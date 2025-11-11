import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../widgets/produto_card.dart';

class BebidasScreen extends StatefulWidget {
  const BebidasScreen({super.key});

  @override
  State<BebidasScreen> createState() => _BebidasScreenState();
}

class _BebidasScreenState extends State<BebidasScreen> {
  final Map<int, int> _carrinho = {}; // produtoId: quantidade

  // Dados mockados - depois virão da API
  final List<ProdutoModel> _bebidas = [
    ProdutoModel(
      id: 5,
      nome: 'Cerveja lata 350 ml',
      preco: 8.99,
      estoque: 100,
      imagemUrl: 'assets/images/cerveja.png',
      categoriaNome: 'Cervejas',
      categoriaTipo: 'bebida',
      destaque: true,
    ),
    ProdutoModel(
      id: 6,
      nome: 'Cerveja zero álcool',
      preco: 15.99,
      estoque: 60,
      imagemUrl: 'assets/images/cerveja_zero.png',
      categoriaNome: 'Cervejas',
      categoriaTipo: 'bebida',
    ),
    ProdutoModel(
      id: 7,
      nome: 'Refrigerante lata 350 ml',
      preco: 6.99,
      estoque: 120,
      imagemUrl: 'assets/images/refrigerante.png',
      categoriaNome: 'Refrigerantes',
      categoriaTipo: 'bebida',
      destaque: true,
    ),
  ];

  double get _valorTotal {
    double total = 0;
    _carrinho.forEach((produtoId, quantidade) {
      final bebida = _bebidas.firstWhere((b) => b.id == produtoId);
      total += bebida.preco * quantidade;
    });
    return total;
  }

  int get _totalItens {
    return _carrinho.values.fold(0, (sum, quantidade) => sum + quantidade);
  }

  void _adicionarAoCarrinho(int produtoId) {
    setState(() {
      _carrinho[produtoId] = (_carrinho[produtoId] ?? 0) + 1;
    });
  }

  void _removerDoCarrinho(int produtoId) {
    setState(() {
      if (_carrinho[produtoId] != null) {
        if (_carrinho[produtoId]! > 1) {
          _carrinho[produtoId] = _carrinho[produtoId]! - 1;
        } else {
          _carrinho.remove(produtoId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bebidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Informações da barbearia
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Row(
              children: [
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
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOATbarber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Color(0xFFFFB84D)),
                          SizedBox(width: 4),
                          Text(
                            '5.0',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '0.5 km',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4CAF50)),
                  ),
                  child: const Text(
                    'Aberto',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de bebidas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _bebidas.length,
              itemBuilder: (context, index) {
                final bebida = _bebidas[index];
                final quantidade = _carrinho[bebida.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProdutoCard(
                    produto: bebida,
                    quantidade: quantidade,
                    onAdicionar: () => _adicionarAoCarrinho(bebida.id),
                    onRemover: () => _removerDoCarrinho(bebida.id),
                  ),
                );
              },
            ),
          ),

          // Botão Avançar
          if (_carrinho.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_totalItens ${_totalItens == 1 ? 'item' : 'itens'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${_valorTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFB84D),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Finalizar compra
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bebidas adicionadas ao agendamento!'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Avançar'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

