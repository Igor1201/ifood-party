import 'package:flutter/material.dart';

import '../data/garnish.dart';

class GarnishOptionDisplay extends StatelessWidget {
  final GarnishOption option;
  final ValueChanged<bool> onChanged;

  GarnishOptionDisplay({this.option, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('${option.name} R\$ ${option.price}'),
      value: option.isSelected,
      onChanged: onChanged,
    );
  }
}
