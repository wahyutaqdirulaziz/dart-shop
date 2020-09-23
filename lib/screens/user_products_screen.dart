import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import 'add_edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

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
      body: Builder(
        builder: (context) {
          final scaffold = Scaffold.of(context);
          return RefreshIndicator(
            onRefresh: () async {
              try {
                await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
              } catch (_) {
                scaffold.hideCurrentSnackBar();
                scaffold.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fetching products failed!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            child: Padding(
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
        },
      ),
    );
  }
}
