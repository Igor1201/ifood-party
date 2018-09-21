import 'dart:convert';

class JSONData {
  String type;
  String sectionId;
  String dishId;
  int garnishIndex;
  int garnishLength;
  List<List<int>> selectedOptions;

  JSONData({
    this.type,
    this.sectionId,
    this.dishId,
    this.garnishIndex,
    this.garnishLength,
    this.selectedOptions = const [],
  });

  factory JSONData.clone(JSONData data) {
    return JSONData(
      type: data.type,
      sectionId: data.sectionId,
      dishId: data.dishId,
      garnishIndex: data.garnishIndex,
      garnishLength: data.garnishLength,
      selectedOptions: data.selectedOptions,
    );
  }
  
  factory JSONData.fromString(String str) {
    Match m = RegExp(r'([a-zA-Z0-9]+)_([a-zA-Z0-9]*)_([a-zA-Z0-9]*)_([a-zA-Z0-9]*)/([a-zA-Z0-9]*)_([0-9,\[\]]*)').firstMatch(str);
    return JSONData(
      type: m[1],
      sectionId: m[2].isEmpty ? null : m[2],
      dishId: m[3].isEmpty ? null : m[3],
      garnishIndex: m[4].isEmpty ? null : int.parse(m[4]),
      garnishLength: m[5].isEmpty ? null : int.parse(m[5]),
      selectedOptions: List.from(json.decode(m[6])).map((l) => List.from<int>(l)).toList(),
    );
  }

  @override
  String toString() {
    return '${type}_${sectionId ?? ''}_${dishId ?? ''}_${garnishIndex ?? ''}/${garnishLength ?? ''}_${json.encode(selectedOptions)}'.replaceAll(' ', '');
  }
}