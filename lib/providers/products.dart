import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './product.dart';
import '../providers/auth.dart';
class Products with ChangeNotifier {                 //using changenotifier mixin
  List<Product> _items = [];
  

  List<Product> get items {
    
    return [..._items];                //we are returning a copy of _items by using square brackets and spread operator
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }


  final String authToken;
  final String userID;
  Products(this.authToken, this._items, this.userID);



  Future<void> fetchAndSet([bool filter = false]) async {
   
    var filterstring = filter? 'orderBy="creator"&equalTo="$userID"' : '';
   
    var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product.json?auth=$authToken&$filterstring';
    // var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product.json?auth=$authToken';
  
    try {
      final response = await http.get(Uri.parse(url));
      final extracted = json.decode(response.body) as Map<String, dynamic>;

      url = 'https://flut-4bebd-default-rtdb.firebaseio.com/productfav/$userID.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));

      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedlist = [];

      

      extracted.forEach((ProdId, ProdData) {
        loadedlist.add(
          Product(
              id: ProdId,
              title: ProdData['title'],
              description: ProdData['description'],
              // price: ProdData['price'],
              price: (ProdData['price'] as num).toDouble(),
              
              imageUrl: ProdData['imageUrl'],
              isFavorite: favoriteData == null ? false : favoriteData[ProdId] ?? false,
              ),
              
               
        );
      });
      _items = loadedlist;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }




  Future<void> addProduct(Product product) async {
    var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product.json?auth=$authToken';
    try {
      final value = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creator': userID,
            //'isFavorite': product.isFavorite,
          },
        ),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(value.body)['name'],
        
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url), body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
     var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    http.delete(Uri.parse(url));
    
    notifyListeners();
  }
}
 