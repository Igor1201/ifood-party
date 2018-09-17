// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) {
  return Section()
    ..name = json['name'] as String
    ..dishes = (json['dishes'] as List)
        ?.map(
            (e) => e == null ? null : Dish.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$SectionToJson(Section instance) =>
    <String, dynamic>{'name': instance.name, 'dishes': instance.dishes};
