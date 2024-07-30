import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String token, String UserID) {
    final url =
        'https://flut-4bebd-default-rtdb.firebaseio.com/product/$UserID/$id.json?auth=$token';
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
