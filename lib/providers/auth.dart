import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../helpers/http_exception.dart';

final firebaseApiKey = DotEnv().env['FIREBASE_API_KEY'];

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth => token != null;

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  String get userId => isAuth != null ? _userId : null;

  Future<void> _authenticate(String email, String password, String urlAction) async {
    final response = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:$urlAction?key=$firebaseApiKey',
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message'] as String);
    }

    _token = responseData['idToken'] as String;
    _userId = responseData['localId'] as String;
    _expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(responseData['expiresIn'] as String)),
    );
    notifyListeners();
  }

  Future<void> signup(String email, String password) {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
