import 'dart:async';
import 'package:flutter/material.dart';

import '../data/dish.dart';
import '../screens/dish_screen.dart';

class DishDisplay extends StatelessWidget {
  final Dish dish;

  DishDisplay({this.dish});

  Future<Null> _showGarnishesPanel(BuildContext context) async {
    if (dish.garnishes != null && dish.garnishes.length > 0) {
      Navigator.push<Dish>(context, MaterialPageRoute(
        builder: (BuildContext context) {
          return DishScreen(dish: dish);
        },
      )).then((Dish dish) {
        print(dish);
      });
    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget image = dish.image != null ?
      Flexible(
        child: Image.network(dish.image),
      ) : null;

    return FlatButton(
      onPressed: () => _showGarnishesPanel(context),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            image,
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dish.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dish.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text('R\$ ${dish.price}'),
            ),
          ]..removeWhere((w) => w == null),
        ),
      ),
    );
  }
}
