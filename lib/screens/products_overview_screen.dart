import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/error_dialog.dart';
import '../widgets/products_grid.dart';
import 'cart_screen.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    _fetchProducts().then((_) {
      setState(() => _isLoading = false);
    });
  }

  Future _fetchProducts() async {
    try {
      await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    } catch (_) {
      await showDialog(
        context: context,
        builder: (_) {
          return const ErrorDialog(
            title: 'An Error Occurred!',
            content: 'Fetching products failed!',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Shop'),
        actions: [
          Consumer<Cart>(
            builder: (_, cartProvider, iconButtonWidget) {
              return Badge(
                value: cartProvider.cartsCount.toString(),
                iconButtonWidget: iconButtonWidget,
              );
            },
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                switch (selectedValue) {
                  case FilterOptions.favorites:
                    _showOnlyFavorites = true;
                    break;
                  case FilterOptions.all:
                    _showOnlyFavorites = false;
                    break;
                  default:
                    throw Exception('Unhandled filter action');
                }
              });
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
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            onRefresh: _fetchProducts,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ProductsGrid(showOnlyFavorites: _showOnlyFavorites),
          );
        },
      ),
    );
  }
}
