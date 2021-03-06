import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<Products>(context, listen: false).findById(productId);
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    _isFavorite = product.isFavorite;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(product.title),
                background: Hero(
                  tag: product.id,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        product.toggleFavorite(auth.token, auth.userId).then((_) {
                          setState(() => _isFavorite = product.isFavorite);
                        }).catchError((_) {
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cannot mark as favorite. Try again later',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        });
                      },
                    );
                  },
                ),
                Chip(
                  backgroundColor: Theme.of(context).primaryColor,
                  label: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  splashColor: Theme.of(context).accentColor,
                  splashRadius: 50,
                  icon: const Icon(Icons.shopping_cart),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    cartProvider.addCart(product.id, product.title, product.price);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Added item to cart!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () => cartProvider.removeSingleCart(product.id),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                product.description,
                textAlign: TextAlign.center,
                softWrap: true,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
