import 'package:json_annotation/json_annotation.dart';
import './dish.dart';

part 'section.g.dart';

@JsonSerializable()
class Section {
  @JsonKey(nullable: false)
  String id;
  
  @JsonKey(nullable: false)
  String name;

  List<Dish> dishes;

  Section();

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);

  Map<String, dynamic> toJson() => _$SectionToJson(this);
}
