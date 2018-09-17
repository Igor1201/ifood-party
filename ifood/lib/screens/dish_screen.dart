import 'package:flutter/material.dart';

import '../data/dish.dart';
import '../components/garnish_display.dart';
import '../components/garnish_option_display.dart';

class DishScreen extends StatelessWidget {
  final Dish dish;

  DishScreen({this.dish});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = dish.garnishes
      .map((g) => <Widget>[GarnishDisplay(garnish: g)]..addAll(g.options.map((o) => GarnishOptionDisplay(option: o))))
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
                  onPressed: () => Navigator.pop(context, []),
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
