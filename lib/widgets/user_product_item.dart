import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/add_edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String _id;
  final String _title;
  final String _imageUrl;

  const UserProductItem(this._id, this._title, this._imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    return ListTile(
      title: Text(_title),
      leading: CircleAvatar(backgroundImage: NetworkImage(_imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).pushNamed(
                AddEditProductScreen.routeName,
                arguments: _id,
              ),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false).deleteProduct(_id);
                } catch (_) {
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text('Deleting failed!', textAlign: TextAlign.center),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
