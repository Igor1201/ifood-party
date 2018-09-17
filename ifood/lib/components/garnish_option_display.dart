import 'package:flutter/material.dart';

import '../data/garnish.dart';

class GarnishOptionDisplay extends StatelessWidget {
  final GarnishOption option;

  GarnishOptionDisplay({this.option});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('${option.name} R\$ ${option.price}'),
      value: true,
      onChanged: (bool value) {
        // setState(() { timeDilation = value ? 20.0 : 1.0; });
      },
    );
  }
}
