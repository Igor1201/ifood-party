import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'data/restaurant.dart';
import 'components/section_display.dart';
import 'components/dish_display.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iFood Party',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}

class App extends StatelessWidget {
  Future<Restaurant> _getDataFromServer() {
    return http.get('http://localhost:3000/')
      .then((response) => Restaurant.fromJson(json.decode(response.body)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Restaurant>(
        future: _getDataFromServer(),
        builder: (BuildContext context, AsyncSnapshot<Restaurant> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          }

          List<Widget> items = snapshot.data.sections
            .map((s) => <Widget>[SectionDisplay(section: s)]..addAll(s.dishes.map((d) => DishDisplay(dish: d))))
            .toList()
            .expand((s) => s)
            .toList();

          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return items.elementAt(index);
            },
          );
        },
      ),
    );
  }
}
