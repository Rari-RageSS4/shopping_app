import 'package:flutter/material.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';

/// ProductDetailPage — stub for Stage 1 compilation check.
/// Full implementation in Stage 9.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: const Center(child: Text('Product Detail — Stage 9')),
    );
  }
}
