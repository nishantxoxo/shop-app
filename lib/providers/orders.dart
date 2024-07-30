import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/providers/product.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;

  Orders(this.token, this._orders, this.userId);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetorder() async {
    final url =
        'https://flut-4bebd-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
    final response = await http.get(Uri.parse(url));
    // print(json.encode(response.body));

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((OrderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: OrderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flut-4bebd-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
    final dte = DateTime.now().toIso8601String();
    final value = await http.post(
      Uri.parse(url),
      body: json.encode({
        'amount': total,
        'dateTime': dte,
        'products': cartProducts
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(value.body)['name'],
        amount: total,
        dateTime: DateTime.parse(dte),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
