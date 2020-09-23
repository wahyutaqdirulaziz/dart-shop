import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

final firebaseCollectionUrl = '${DotEnv().env['FIREBASE_DB_URL']}products.json';

class Products with ChangeNotifier {
  List<Product> _products;

  List<Product> get products => [..._products];

  Future fetchAndSetProducts() async {
    final response = await http.get(firebaseCollectionUrl);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final loadedProducts = <Product>[];
    body.forEach((productId, productData) {
      loadedProducts.add(
        Product(
          id: productData['id'] as String,
          title: productData['title'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          imageUrl: productData['imageUrl'] as String,
          isFavorite: productData['isFavorite'] as bool,
        ),
      );
    });
    _products = loadedProducts;
    notifyListeners();
  }

  int get productsCount => _products.length;

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future addProduct(Product product) async {
    final response = await http.post(
      firebaseCollectionUrl,
      body: jsonEncode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }),
    );
    final body = jsonDecode(response.body);
    product.id = body['name'] as String;
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final productIndex = _products.indexWhere((product) {
      return product.id == updatedProduct.id;
    });
    _products[productIndex] = updatedProduct;
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }
}
