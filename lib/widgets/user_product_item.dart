import 'package:flutter/material.dart';

class UserProductItem extends StatelessWidget {
  final String _title;
  final String _imageUrl;

  const UserProductItem(this._title, this._imageUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
      leading: CircleAvatar(backgroundImage: NetworkImage(_imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}