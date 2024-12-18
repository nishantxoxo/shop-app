import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;  //should be a network image
  bool isFavorite;  //shouldnt be final as this will change after the product has been created   

  Product({
    required this.id, 
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });                 //named argumets   

  void toggleFavoriteStatus(String token, String UserID) {
    final url =
        'https://flut-4bebd-default-rtdb.firebaseio.com/productfav/$UserID/$id.json?auth=$token';
    final oldstatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    http.put(
      Uri.parse(url),
      body: json.encode(
        
          isFavorite,
        
      ),
    );
  }
}
