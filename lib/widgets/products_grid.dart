import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);                                    //listing to the products provider

    final products = showFavs ? productsData.favoriteItems : productsData.items;         // fetching data from the products provider

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(                                  //setting up provider for single products
            // builder: (c) => products[i],  
            value: products[i],
            child: ProductItem( 
                // products[i].id,
                // products[i].title,
                // products[i].imageUrl,
                ),
          ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,                                              //the amount of columns we want
        childAspectRatio: 3 / 2,                                     //aspec ratio
        crossAxisSpacing: 10,                                  // width between columns
        mainAxisSpacing: 10,                                 // width between rows
      ),
    );
  }
}
