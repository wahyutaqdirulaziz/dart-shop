import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  Product({
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  }) : id = uuid.v4();

  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
