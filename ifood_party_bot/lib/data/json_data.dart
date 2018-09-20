import 'package:json_annotation/json_annotation.dart';

part 'json_data.g.dart';

@JsonSerializable(includeIfNull: false)
class JSONData {
  @JsonKey(nullable: false)
  String type;
  String sectionId;
  String dishId;
  String garnishId;
  List<String> selectedOptions;

  JSONData({
    this.type,
    this.sectionId,
    this.dishId,
    this.garnishId,
    this.selectedOptions = const [],
  });

  factory JSONData.fromJson(Map<String, dynamic> json) => _$JSONDataFromJson(json);
  
  factory JSONData.fromString(String str) {
    Match m = RegExp(r'([a-zA-Z0-9]+)_([a-zA-Z0-9]*)_([a-zA-Z0-9]*)_([a-zA-Z0-9]*)_([a-zA-Z0-9,]*)').firstMatch(str);
    return JSONData(
      type: m[1],
      sectionId: m[2],
      dishId: m[3],
      garnishId: m[4],
      selectedOptions: m[5].split(',')..removeWhere((s) => s == null),
    );
  }

  Map<String, dynamic> toJson() => _$JSONDataToJson(this);

  @override
  String toString() {
    return '${type}_${sectionId}_${dishId}_${garnishId}_${selectedOptions.where((s) => s != null).join(',')}';
  }
}