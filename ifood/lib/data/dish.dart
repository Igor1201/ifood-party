import 'package:json_annotation/json_annotation.dart';
import 'garnish.dart';

part 'dish.g.dart';

@JsonSerializable(includeIfNull: false)
class Dish {
  @JsonKey(nullable: false)
  String id;

  String image;

  @JsonKey(nullable: false)
  String name;

  String description;

  @JsonKey(nullable: false)
  double price;

  List<Garnish> garnishes;

  Dish();

  factory Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);

  Map<String, dynamic> toJson() => _$DishToJson(this);
}
