import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/error_dialog.dart';
import '../widgets/user_product_item.dart';
import 'add_edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  Future _userProductsFuture;

  @override
  void initState() {
    super.initState();
    _userProductsFuture = _fetchUserProducts();
  }

  Future<void> _fetchUserProducts() async {
    return Provider.of<Products>(context, listen: false).fetchAndSetProducts(
      filterByUser: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddEditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _userProductsFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              return RefreshIndicator(
                onRefresh: () async {
                  try {
                    await _fetchUserProducts();
                  } catch (_) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return const ErrorDialog(
                          title: 'An Error Occurred',
                          content: 'Fetching products failed!',
                        );
                      },
                    );
                  }
                },
                child: snapshot.hasError
                    ? const Center(child: Text('An error occurred'))
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<Products>(
                          builder: (_, productsProvider, __) {
                            return ListView.builder(
                              itemCount: productsProvider.productsCount,
                              itemBuilder: (context, i) {
                                return Column(
                                  children: [
                                    UserProductItem(
                                      productsProvider.products[i].id,
                                      productsProvider.products[i].title,
                                      productsProvider.products[i].imageUrl,
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
              );
            default:
              throw Exception('Unknown Future connection state');
          }
        },
      ),
    );
  }
}
