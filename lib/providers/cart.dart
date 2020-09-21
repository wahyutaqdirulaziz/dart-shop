import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';

final uuid = Uuid();

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem({String productId, String title, double price}) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (existingCartItem) {
        return CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        );
      });
    } else {
      _items.putIfAbsent(productId, () {
        return CartItem(
          id: uuid.v4(),
          title: title,
          price: price,
          quantity: 1,
        );
      });
    }
    notifyListeners();
  }
}
