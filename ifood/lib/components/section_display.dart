import 'package:flutter/material.dart';

import '../data/section.dart';

class SectionDisplay extends StatelessWidget {
  final Section section;

  SectionDisplay({this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Text(section.name),
    );
  }
}
