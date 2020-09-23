import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

final firebaseDbUrl = DotEnv().env['FIREBASE_DB_URL'];

class Products with ChangeNotifier {
  final List<Product> _products = [
    Product(
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  List<Product> get products => [..._products];

  int get productsCount => _products.length;

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future addProduct(Product product) async {
    final response = await http.post(
      '${firebaseDbUrl}products.json',
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
