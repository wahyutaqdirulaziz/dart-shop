import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

final firebaseDbUrl = DotEnv().env['FIREBASE_DB_URL'];

class OrderItem {
  final String id;
  final double totalPrice;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.totalPrice,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String _authToken;
  List<OrderItem> _orders = [];

  Orders(this._authToken, this._orders);

  List<OrderItem> get orders => [..._orders];

  int get ordersCount => _orders.length;

  Future<void> fetchAndSetOrders() async {
    final response = await http.get('${firebaseDbUrl}orders.json?auth=$_authToken');
    final body = jsonDecode(response.body) as Map<String, dynamic> ?? {};

    final loadedOrders = <OrderItem>[];
    body.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          totalPrice: orderData['totalPrice'] as double,
          dateTime: DateTime.parse(orderData['dateTime'] as String),
          products: (orderData['products'] as List<dynamic>).map((product) {
            return CartItem(
              id: product['id'] as String,
              title: product['title'] as String,
              price: product['price'] as double,
              quantity: product['quantity'] as int,
            );
          }).toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartItems, double totalPrice) async {
    final timestamp = DateTime.now();
    final response = await http.post(
      '${firebaseDbUrl}orders.json?auth=$_authToken',
      body: jsonEncode({
        'totalPrice': totalPrice,
        'dateTime': timestamp.toIso8601String(),
        'products': cartItems.map((cartItem) {
          return {
            'id': cartItem.id,
            'title': cartItem.title,
            'quantity': cartItem.quantity,
            'price': cartItem.price
          };
        }).toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)['name'] as String,
        products: cartItems,
        totalPrice: totalPrice,
        dateTime: timestamp,
      ),
    );

    notifyListeners();
  }
}
