import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/http_exception.dart';

final firebaseApiKey = DotEnv().env['FIREBASE_API_KEY'];

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

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
    _autoLogoutTimer();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userSession = jsonEncode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate.toIso8601String(),
    });
    prefs.setString('userSession', userSession);
  }

  Future<void> signup(String email, String password) {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userSession')) {
      return false;
    }

    final userSession = jsonDecode(prefs.getString('userSession')) as Map<String, Object>;
    final expiryDate = DateTime.parse(userSession['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userSession['token'] as String;
    _userId = userSession['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogoutTimer();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void _autoLogoutTimer() {
    _authTimer?.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
