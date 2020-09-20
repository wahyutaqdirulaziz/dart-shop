import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              switch (selectedValue) {
                case FilterOptions.favorites:
                  productsProvider.showFavoritesOnly();
                  break;
                case FilterOptions.all:
                  productsProvider.showAll();
                  break;
                default:
                  throw ErrorDescription('Unknown action');
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) {
              return const [
                PopupMenuItem(
                  value: FilterOptions.favorites,
                  child: Text('Only Favorites'),
                ),
                PopupMenuItem(
                  value: FilterOptions.all,
                  child: Text('Show All'),
                ),
              ];
            },
          )
        ],
      ),
      body: ProductsGrid(),
    );
  }
}
