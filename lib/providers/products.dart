import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../helpers/http_exception.dart';
import 'product.dart';

final firebaseDbUrl = DotEnv().env['FIREBASE_DB_URL'];

class Products with ChangeNotifier {
  final String _authToken;
  final String _userId;
  List<Product> _products = [];

  Products(this._authToken, this._userId, this._products);

  List<Product> get products => [..._products];

  int get productsCount => _products.length;

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterParams = filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    final responses = await Future.wait([
      http.get('${firebaseDbUrl}products.json?auth=$_authToken$filterParams'),
      http.get('${firebaseDbUrl}userFavorites/$_userId.json?auth=$_authToken'),
    ]);
    final productsBody = jsonDecode(responses[0].body) as Map<String, dynamic> ?? {};
    final userFavoritesBody = jsonDecode(responses[1].body) as Map<String, dynamic> ?? {};

    final loadedProducts = <Product>[];
    productsBody.forEach((productId, productData) {
      loadedProducts.add(
        Product(
          id: productId,
          title: productData['title'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          imageUrl: productData['imageUrl'] as String,
          isFavorite: userFavoritesBody[productId] as bool ?? false,
        ),
      );
    });
    _products = loadedProducts.reversed.toList();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      '${firebaseDbUrl}products.json?auth=$_authToken',
      body: jsonEncode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'creatorId': _userId,
      }),
    );
    final body = jsonDecode(response.body);
    product.id = body['name'] as String;
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final response = await http.patch(
      '${firebaseDbUrl}products/${updatedProduct.id}.json?auth=$_authToken',
      body: jsonEncode({
        'title': updatedProduct.title,
        'description': updatedProduct.description,
        'price': updatedProduct.price,
        'imageUrl': updatedProduct.imageUrl,
      }),
    );
    if (response.statusCode >= 400) {
      throw HttpException('Could not update product');
    }
    final productIndex = _products.indexWhere((product) {
      return product.id == updatedProduct.id;
    });
    _products[productIndex] = updatedProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final existingProductIndex = _products.indexWhere((product) {
      return product.id == productId;
    });
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(
      '${firebaseDbUrl}products/$productId.json?auth=$_authToken',
    );
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    } else {
      existingProduct = null;
    }
  }
}
