import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../helpers/http_exception.dart';

final firebaseDbUrl = DotEnv().env['FIREBASE_DB_URL'];

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final oldState = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    try {
      final response = await http.patch(
        '${firebaseDbUrl}products/$id.json',
        body: json.encode({'isFavorite': isFavorite}),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Cannot mark the product as favorite');
      }
    } catch (_) {
      isFavorite = oldState;
      notifyListeners();
    }
  }
}
