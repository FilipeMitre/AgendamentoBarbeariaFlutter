import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RecomendacoesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialProducts;
  final List<Map<String, dynamic>> initialBebidas;
  final double initialProductsTotal;
  final double initialBebidasTotal;

  const RecomendacoesScreen({
    super.key,
    this.initialProducts = const [],
    this.initialBebidas = const [],
    this.initialProductsTotal = 0.0,
    this.initialBebidasTotal = 0.0,
  });

  @override
  State<RecomendacoesScreen> createState() => _RecomendacoesScreenState();
}

class _RecomendacoesScreenState extends State<RecomendacoesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> selectedProducts = {};
  Map<String, int> selectedBebidas = {};
  double productsTotal = 0.0;
  double bebidasTotal = 0.0;

  final List<Map<String, dynamic>> products = [
    {'name': 'Creme de cabelo(cachos)', 'price': 27.89},
    {'name': 'gel para cabelo', 'price': 15.89},
    {'name': 'Esponja Nudred', 'price': 24.98},
    {'name': 'Pata Pata', 'price': 4.99},
  ];

  final List<Map<String, dynamic>> bebidas = [
    {'name': 'Cerveja lata 350 ml', 'price': 8.99},
    {'name': 'Cerveja zero álcool', 'price': 8.99},
    {'name': 'Energético', 'price': 15.89},
    {'name': 'Refrigerante lata 350 ml', 'price': 8.99},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Converter listas iniciais para maps de quantidade
    for (var product in widget.initialProducts) {
      selectedProducts[product['name']] = 1;
    }
    for (var bebida in widget.initialBebidas) {
      selectedBebidas[bebida['name']] = 1;
    }
    
    productsTotal = widget.initialProductsTotal;
    bebidasTotal = widget.initialBebidasTotal;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recomendações',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Produtos'),
            Tab(text: 'Bebidas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildBebidasTab(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Converter maps para listas
                  List<Map<String, dynamic>> productsList = [];
                  List<Map<String, dynamic>> bebidasList = [];
                  
                  selectedProducts.forEach((name, quantity) {
                    final product = products.firstWhere((p) => p['name'] == name);
                    for (int i = 0; i < quantity; i++) {
                      productsList.add(product);
                    }
                  });
                  
                  selectedBebidas.forEach((name, quantity) {
                    final bebida = bebidas.firstWhere((b) => b['name'] == name);
                    for (int i = 0; i < quantity; i++) {
                      bebidasList.add(bebida);
                    }
                  });
                  
                  Navigator.pop(context, {
                    'products': productsList,
                    'bebidas': bebidasList,
                    'productsTotal': productsTotal,
                    'bebidasTotal': bebidasTotal,
                  });
                },
                child: Text('Avançar (R\$ ${(productsTotal + bebidasTotal).toStringAsFixed(2)})'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final quantity = selectedProducts[product['name']] ?? 0;
        return _buildItemCard(product, quantity, true);
      },
    );
  }

  Widget _buildBebidasTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: bebidas.length,
      itemBuilder: (context, index) {
        final bebida = bebidas[index];
        final quantity = selectedBebidas[bebida['name']] ?? 0;
        return _buildItemCard(bebida, quantity, false);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int quantity, bool isProduct) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: quantity > 0 ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: AppColors.inputBackground,
              child: Icon(
                isProduct ? Icons.shopping_bag : Icons.local_drink,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${item['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      quantity > 0
                          ? Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _decreaseQuantity(item, isProduct),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.remove, color: Colors.white, size: 16),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$quantity',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _increaseQuantity(item, isProduct),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add, color: Colors.black, size: 16),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () => _increaseQuantity(item, isProduct),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add, color: Colors.black, size: 20),
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

  void _increaseQuantity(Map<String, dynamic> item, bool isProduct) {
    setState(() {
      if (isProduct) {
        selectedProducts[item['name']] = (selectedProducts[item['name']] ?? 0) + 1;
        productsTotal += item['price'];
      } else {
        selectedBebidas[item['name']] = (selectedBebidas[item['name']] ?? 0) + 1;
        bebidasTotal += item['price'];
      }
    });
  }
  
  void _decreaseQuantity(Map<String, dynamic> item, bool isProduct) {
    setState(() {
      if (isProduct) {
        final currentQuantity = selectedProducts[item['name']] ?? 0;
        if (currentQuantity > 1) {
          selectedProducts[item['name']] = currentQuantity - 1;
        } else {
          selectedProducts.remove(item['name']);
        }
        productsTotal -= item['price'];
      } else {
        final currentQuantity = selectedBebidas[item['name']] ?? 0;
        if (currentQuantity > 1) {
          selectedBebidas[item['name']] = currentQuantity - 1;
        } else {
          selectedBebidas.remove(item['name']);
        }
        bebidasTotal -= item['price'];
      }
    });
  }
}