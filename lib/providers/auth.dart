import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/urls.dart';
import 'dart:async';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
   String? _token;
   DateTime? _expirydate;
   String? _userId;
   Timer? authtimer;


  bool get isAuth{
    return token != null;
  }

  String? get token {
    if(_expirydate != null && _expirydate!.isAfter(DateTime.now()) && _token != null){
      return _token;
    }

    return null;
  }

  String? get userID{
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    const url =
        signUp;
   final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {'email': email, 'password': password, 'returnSecureToken': true},
      ),
    );
    //print(json.decode(response.body));
    final responseData = json.decode(response.body);
    if(responseData['error'] != null){
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expirydate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn']),),);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    const url = signin;
    try{
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {'email': email, 'password': password, 'returnSecureToken': true},
      ),
    );
    final responseData = json.decode(response.body);
    if(responseData['error'] != null){
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expirydate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn']),),);
    autoLogout();
    notifyListeners();
    }
    catch (error){
      throw error;
    }
  }

  void logout(){
    _token = null;
    _userId = null;
    _expirydate = null;
    
    if (authtimer != null){
      authtimer!.cancel();
      authtimer = null;
    }
    SnackBar(content: Text('logged out'), duration: Duration(seconds: 3),);
    notifyListeners();
  }

  void autoLogout(){
    if (authtimer != null){
      authtimer!.cancel();
    }
    var timeToExpiry =_expirydate!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);

    
  }
}
