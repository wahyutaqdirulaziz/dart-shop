import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'cart.dart';

final uuid = Uuid();

class OrderItem {
  final String id;
  final double totalPrice;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.products,
    @required this.totalPrice,
  })  : id = uuid.v4(),
        dateTime = DateTime.now();
}

class Orders with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  int get ordersCount => _orders.length;

  void addOrder(List<CartItem> cartItems, double totalPrice) {
    _orders.insert(0, OrderItem(products: cartItems, totalPrice: totalPrice));
    notifyListeners();
  }
}
