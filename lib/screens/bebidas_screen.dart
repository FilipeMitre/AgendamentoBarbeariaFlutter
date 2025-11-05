import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BebidasScreen extends StatefulWidget {
  const BebidasScreen({super.key});

  @override
  State<BebidasScreen> createState() => _BebidasScreenState();
}

class _BebidasScreenState extends State<BebidasScreen> {
  final List<Map<String, dynamic>> selectedBebidas = [];
  double totalPrice = 0.0;
  
  final List<Map<String, dynamic>> bebidas = [
    {
      'name': 'Cerveja lata 350 ml',
      'price': 8.99,
      'image': 'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=200',
    },
    {
      'name': 'Cerveja zero álcool',
      'price': 8.99,
      'image': 'https://images.unsplash.com/photo-1618885472179-5e474019f2a9?w=200',
    },
    {
      'name': 'Energético',
      'price': 15.89,
      'image': 'https://images.unsplash.com/photo-1622543925917-763c34f5a561?w=200',
    },
    {
      'name': 'Refrigerante lata 350 ml',
      'price': 8.99,
      'image': 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
    },
  ];

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
          'Bebidas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.store, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOATbarber',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.starYellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '5.0',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• 0.5 km',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Aberto',
                        style: TextStyle(
                          color: AppColors.openTag,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bebidas.length,
              itemBuilder: (context, index) {
                final bebida = bebidas[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
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
                          child: Icon(Icons.local_drink, color: AppColors.textSecondary, size: 48),
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
                                bebida['name'],
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
                                    'R\$ ${bebida['price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _addBebida(bebida),
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
              },
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
                  Navigator.pop(context, {
                    'bebidas': selectedBebidas,
                    'total': totalPrice,
                  });
                },
                child: Text('Avançar (R\$ ${totalPrice.toStringAsFixed(2)})'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _addBebida(Map<String, dynamic> bebida) {
    setState(() {
      selectedBebidas.add(bebida);
      totalPrice += bebida['price'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${bebida['name']} adicionado!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }
}