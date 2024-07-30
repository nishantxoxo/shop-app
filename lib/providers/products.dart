import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './product.dart';
import '../providers/auth.dart';
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  final String authToken;
  final String userID;
  Products(this.authToken, this._items, this.userID);
  Future<void> fetchAndSet([bool filter = false]) async {
    var filterstring = filter? 'orderBy="creator"&equalTo="$userID"' : '';
    var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product.json?auth=$authToken&$filterstring';
    //var url2 = 'https://flut-4bebd-default-rtdb.firebaseio.com/product.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extracted = json.decode(response.body) as Map<String, dynamic>;

      url = 'https://flut-4bebd-default-rtdb.firebaseio.com/product/$userID.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));

      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedlist = [];
      extracted.forEach((ProdId, ProdData) {
        loadedlist.add(
          Product(
              id: ProdId,
              title: ProdData['title'],
              description: ProdData['description'],
              price: ProdData['price'],
              
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
      var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/$id.json?auth=$authToken';
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
     var url = 'https://flut-4bebd-default-rtdb.firebaseio.com/$id.json?auth=$authToken';
    http.delete(Uri.parse(url));
    
    notifyListeners();
  }
}
 