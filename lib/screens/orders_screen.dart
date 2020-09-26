import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/error_dialog.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<void> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              return RefreshIndicator(
                onRefresh: () async {
                  try {
                    await _fetchOrders();
                  } catch (_) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return const ErrorDialog(
                          title: 'An Error Occurred',
                          content: 'Fetching orders failed!',
                        );
                      },
                    );
                  }
                },
                child: snapshot.hasError
                    ? const Center(child: Text('An error occurred'))
                    : Consumer<Orders>(
                        builder: (_, ordersProvider, __) {
                          return ListView.builder(
                            itemCount: ordersProvider.ordersCount,
                            itemBuilder: (_, i) => OrderItem(ordersProvider.orders[i]),
                          );
                        },
                      ),
              );
            default:
              throw Exception('Unhandled connection state');
          }
        },
      ),
    );
  }
}
