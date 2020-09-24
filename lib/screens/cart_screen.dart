import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text(
                      '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                  ),
                  OrderButton(cartProvider),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartsCount,
              itemBuilder: (_, i) {
                return CartItem(
                  cartId: cartProvider.cartIds[i],
                  title: cartProvider.cartItems[i].title,
                  price: cartProvider.cartItems[i].price,
                  quantity: cartProvider.cartItems[i].quantity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;

  const OrderButton(this.cart);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.cart.totalPrice <= 0 || _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.cartItems,
                  widget.cart.totalPrice,
                );
                widget.cart.clear();
              } catch (_) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Cannot add order!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              setState(() => _isLoading = false);
            },
      textColor: Theme.of(context).primaryColor,
      child: _isLoading ? const CircularProgressIndicator() : const Text('ORDER NOW'),
    );
  }
}
