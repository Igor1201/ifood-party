// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garnish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GarnishOption _$GarnishOptionFromJson(Map<String, dynamic> json) {
  return GarnishOption()
    ..id = json['id'] as String
    ..name = json['name'] as String;
}

Map<String, dynamic> _$GarnishOptionToJson(GarnishOption instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

Garnish _$GarnishFromJson(Map<String, dynamic> json) {
  return Garnish()
    ..min = json['min'] as int
    ..max = json['max'] as int
    ..options = (json['options'] as List)
        .map((e) => GarnishOption.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$GarnishToJson(Garnish instance) => <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'options': instance.options
    };
