import 'package:flutter/material.dart';

import '../data/garnish.dart';

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
