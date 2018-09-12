import 'package:json_annotation/json_annotation.dart';

part 'garnish.g.dart';

@JsonSerializable(includeIfNull: false)
class GarnishOption {
  @JsonKey(nullable: false)
  String id;

  @JsonKey(nullable: false)
  String name;

  @JsonKey(nullable: false)
  double price;

  GarnishOption();

  factory GarnishOption.fromJson(Map<String, dynamic> json) => _$GarnishOptionFromJson(json);

  Map<String, dynamic> toJson() => _$GarnishOptionToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Garnish {
  @JsonKey(nullable: false)
  int min;

  @JsonKey(nullable: false)
  int max;

  @JsonKey(nullable: false)
  List<GarnishOption> options;

  Garnish();

  factory Garnish.fromJson(Map<String, dynamic> json) => _$GarnishFromJson(json);

  Map<String, dynamic> toJson() => _$GarnishToJson(this);
}
