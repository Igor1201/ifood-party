import 'package:json_annotation/json_annotation.dart';
import './section.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  String name;
  
  List<Section> sections;

  Restaurant();

  factory Restaurant.fromJson(Map<String, dynamic> json) => _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}
