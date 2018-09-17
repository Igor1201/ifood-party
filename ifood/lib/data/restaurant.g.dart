// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) {
  return Restaurant()
    ..name = json['name'] as String
    ..sections = (json['sections'] as List)
        ?.map((e) =>
            e == null ? null : Section.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{'name': instance.name, 'sections': instance.sections};
