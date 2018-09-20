import 'package:json_annotation/json_annotation.dart';

part 'garnish.g.dart';

List _optionsToJson(List<GarnishOption> options) => options.map((o) => o.toJson()).toList();

@JsonSerializable(includeIfNull: false)
class GarnishOption {
  @JsonKey(nullable: false)
  String id;

  @JsonKey(nullable: false)
  String name;

  @JsonKey(nullable: false)
  double price;

  @JsonKey(ignore: true)
  bool isSelected = false;

  GarnishOption();

  factory GarnishOption.fromJson(Map<String, dynamic> json) => _$GarnishOptionFromJson(json);

  Map<String, dynamic> toJson() => _$GarnishOptionToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Garnish {
  @JsonKey(nullable: false)
  String id;

  String description;

  @JsonKey(nullable: false)
  int min;

  @JsonKey(nullable: false)
  int max;

  @JsonKey(nullable: false, toJson: _optionsToJson)
  List<GarnishOption> options;

  Garnish();

  factory Garnish.fromJson(Map<String, dynamic> json) => _$GarnishFromJson(json);

  Map<String, dynamic> toJson() => _$GarnishToJson(this);
}
