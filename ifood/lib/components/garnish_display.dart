import 'package:flutter/material.dart';

import '../data/garnish.dart';
import 'garnish_option_display.dart';

class GarnishDisplay extends StatelessWidget {
  final Garnish garnish;

  GarnishDisplay({this.garnish});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Text(
        '${garnish.description} min ${garnish.min}, max ${garnish.max}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class GarnishesDisplay extends StatelessWidget {
  final List<Garnish> garnishes;

  GarnishesDisplay({this.garnishes});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = garnishes
      // .map((g) => GarnishDisplay(garnish: g))
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
