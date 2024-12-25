import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/urls.dart';
import 'dart:async';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
   String? _token;
   DateTime? _expirydate;                     //expiry date of the token recieved from firebase
   String? _userId; 
   Timer? authtimer;


  bool get isAuth{
    // print(token);
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


  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, Object>;
    final expirydate = DateTime.parse(extractedUserData['expirydate'].toString());
    if (expirydate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expirydate = expirydate;
    notifyListeners();
    autoLogout();
    return true;
  }



  Future<void> authenticate(String email, String password, String url) async {

    try {
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
    _expirydate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn']) ));
    autoLogout();
    notifyListeners();

  // to store the data on the device using shared prefss

    final SharedPreferences prefs = await SharedPreferences.getInstance(); // Obtain shared preferences.
    final userData  = json.encode({
      'token' : _token,
      'userId' : _userId,
      'expirydate' : _expirydate!.toIso8601String()   
    });

    prefs.setString('userData', userData);

    } catch (e) {
      throw e;
    }

    
  }


  // user signup fucntion  

  Future<void> signup(String email, String password) async {

    return authenticate(email, password, signUp);
  
  }

  Future<void> login(String email, String password) async {
   
    try{
      return authenticate(email, password, signin);
   
    }
    catch (error){
      throw error;
    }
  }

  void logout() async{
    _token = null;
    _userId = null;
    _expirydate = null;
    
    if (authtimer != null){
      authtimer!.cancel();
      authtimer = null;
    }

    SnackBar(content: Text('logged out'), duration: Duration(seconds: 3),);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }


  // to automatically logout after the token expires


  void autoLogout(){
    if (authtimer != null){
      authtimer!.cancel();
    }
    final timeToExpiry =_expirydate!.difference(DateTime.now()).inSeconds;
    authtimer = Timer(Duration(seconds: timeToExpiry), logout);

    
  }
}
