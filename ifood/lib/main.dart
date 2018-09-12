import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './dish.dart';

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

class DishDisplay extends StatelessWidget {
  final Dish _dish;

  DishDisplay(this._dish);

  @override
  Widget build(BuildContext context) {
    Widget image = _dish.image != null ?
      Flexible(
        child: Image.network(_dish.image),
      ) : null;

    return Padding(
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
                  _dish.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _dish.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Flexible(
            child: Text('R\$ ${_dish.price}'),
          ),
        ]..removeWhere((w) => w == null),
      ),
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
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: snapshot.data.dishes.length,
            itemBuilder: (BuildContext context, int index) {
              return DishDisplay(snapshot.data.dishes.elementAt(index));
            },
          );
        },
      ),
    );
  }
}
