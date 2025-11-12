import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../widgets/produto_card.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final Map<int, int> _carrinho = {}; // produtoId: quantidade

  // Dados mockados - depois virão da API
  final List<ProdutoModel> _produtos = [
    ProdutoModel(
      id: 1,
      nome: 'Creme de cabelo(cachop)',
      preco: 27.99,
      estoque: 50,
      imagemUrl: 'assets/images/creme_cachop.png',
      categoriaNome: 'Cremes e Pomadas',
      categoriaTipo: 'produto',
      destaque: true,
    ),
    ProdutoModel(
      id: 2,
      nome: 'gel para cabelo',
      preco: 15.99,
      estoque: 80,
      imagemUrl: 'assets/images/gel.png',
      categoriaNome: 'Gel para Cabelo',
      categoriaTipo: 'produto',
      destaque: true,
    ),
    ProdutoModel(
      id: 3,
      nome: 'Esponja Nudred',
      preco: 24.99,
      estoque: 30,
      imagemUrl: 'assets/images/esponja.png',
      categoriaNome: 'Esponjas e Acessórios',
      categoriaTipo: 'produto',
    ),
    ProdutoModel(
      id: 4,
      nome: 'Pata Pata',
      preco: 4.99,
      estoque: 25,
      imagemUrl: 'assets/images/pata_pata.png',
      categoriaNome: 'Esponjas e Acessórios',
      categoriaTipo: 'produto',
    ),
  ];

  double get _valorTotal {
    double total = 0;
    _carrinho.forEach((produtoId, quantidade) {
      final produto = _produtos.firstWhere((p) => p.id == produtoId);
      total += produto.preco * quantidade;
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
          'Produtos',
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

          // Lista de produtos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _produtos.length,
              itemBuilder: (context, index) {
                final produto = _produtos[index];
                final quantidade = _carrinho[produto.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProdutoCard(
                    produto: produto,
                    quantidade: quantidade,
                    onAdicionar: () => _adicionarAoCarrinho(produto.id),
                    onRemover: () => _removerDoCarrinho(produto.id),
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
                                // Retornar produtos selecionados
                                Map<String, double> produtosSelecionados = {};
                                _carrinho.forEach((produtoId, quantidade) {
                                  final produto = _produtos.firstWhere((p) => p.id == produtoId);
                                  produtosSelecionados[produto.nome] = produto.preco * quantidade;
                                });
                                
                                Navigator.pop(context, produtosSelecionados);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Produtos adicionados ao agendamento!'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
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
