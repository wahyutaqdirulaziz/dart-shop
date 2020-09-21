import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  const CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _carts = {};

  Map<String, CartItem> get carts => {..._carts};

  List<String> get cartIds => _carts.keys.toList();

  List<CartItem> get cartItems => _carts.values.toList();

  int get cartsCount => _carts.length;

  double get totalPrice {
    var total = 0.0;
    _carts.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addCart(String productId, String title, double price) {
    if (_carts.containsKey(productId)) {
      _carts.update(productId, (existingCartItem) {
        return CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        );
      });
    } else {
      _carts.putIfAbsent(productId, () {
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

  void removeCart(String productId) {
    _carts.remove(productId);
    notifyListeners();
  }

  void clear() {
    _carts.clear();
    notifyListeners();
  }
}
