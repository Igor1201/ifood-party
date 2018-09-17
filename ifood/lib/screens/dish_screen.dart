import 'package:flutter/material.dart';

import '../data/dish.dart';
import '../components/garnish_display.dart';
import '../components/garnish_option_display.dart';

class DishScreen extends StatefulWidget {
  final Dish dish;

  DishScreen({this.dish});

  State<DishScreen> createState() {
    return DishScreenState(dish: dish);
  }
}

class DishScreenState extends State<DishScreen> {
  final Dish dish;

  DishScreenState({this.dish});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = dish.garnishes
      .map((g) => <Widget>[GarnishDisplay(garnish: g)]..addAll(g.options.map((o) =>
        GarnishOptionDisplay(
          option: o,
          onChanged: (bool value) {
            setState(() {
              o.isSelected = value;
            });
          },
        )
      )))
      .toList()
      .expand((s) => s)
      .toList();

    return SafeArea(
      top: true,
      right: true,
      bottom: true,
      left: true,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) => items.elementAt(index),
              ),
            ),
            Row(
              children: [
                RaisedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text('CANCEL'),
                ),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, Dish.fromJson(dish.toJson())),
                  child: Text('ADD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
