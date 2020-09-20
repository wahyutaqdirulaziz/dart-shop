import 'package:flutter/material.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final String _id;
  final String _title;
  final String _imageUrl;

  const ProductItem(this._id, this._title, this._imageUrl);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(_title, textAlign: TextAlign.center),
          leading: IconButton(
            icon: const Icon(Icons.favorite),
            color: Theme.of(context).accentColor,
            onPressed: () {},
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {},
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: _id,
            );
          },
          child: Image.network(_imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
