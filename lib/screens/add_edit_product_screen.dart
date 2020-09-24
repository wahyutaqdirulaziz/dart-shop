import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/error_dialog.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  var _isEditing = false;
  var _isLoading = false;

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();
  final _inputs = <String, String>{};
  Product _editedProduct;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context).settings.arguments as String;
    if (productId != null) {
      _isEditing = true;
      _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
      _inputs['title'] = _editedProduct.title;
      _inputs['description'] = _editedProduct.description;
      _inputs['price'] = _editedProduct.price.toString();
      _imageUrlController.text = _editedProduct.imageUrl;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty) {
        return;
      } else if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) {
        return;
      } else if (!_imageUrlController.text.endsWith('.png') &&
          !_imageUrlController.text.endsWith('.jpg') &&
          !_imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  Future _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;

    _form.currentState.save();
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        _editedProduct.title = _inputs['title'];
        _editedProduct.description = _inputs['description'];
        _editedProduct.price = double.parse(_inputs['price']);
        _editedProduct.imageUrl = _inputs['imageUrl'];
        await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct);
      } else {
        _editedProduct = Product(
          title: _inputs['title'],
          description: _inputs['description'],
          price: double.parse(_inputs['price']),
          imageUrl: _inputs['imageUrl'],
        );
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      }
    } catch (_) {
      await showDialog(
        context: context,
        builder: (_) {
          return const ErrorDialog(
            title: 'An Error Occurred!',
            content: 'Cannot add/update the product!',
          );
        },
      );
    }

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _inputs['title'],
                        decoration: const InputDecoration(labelText: 'Text'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          return value.isEmpty ? 'Please provide a value' : null;
                        },
                        onSaved: (value) => _inputs['title'] = value,
                      ),
                      TextFormField(
                        initialValue: _inputs['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a price';
                          } else if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _inputs['price'] = value,
                      ),
                      TextFormField(
                        initialValue: _inputs['description'],
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a description';
                          } else if (value.length < 10) {
                            return 'Should be at least 10 characters long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _inputs['description'] = value,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration:
                                BoxDecoration(border: Border.all(color: Colors.grey)),
                            alignment: Alignment.center,
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => _saveForm(),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter an image URL';
                                } else if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL';
                                } else if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid image URL';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) => _inputs['imageUrl'] = value,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
