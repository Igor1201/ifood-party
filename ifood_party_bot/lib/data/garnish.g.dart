// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garnish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GarnishOption _$GarnishOptionFromJson(Map<String, dynamic> json) {
  return GarnishOption()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..price = (json['price'] as num).toDouble();
}

Map<String, dynamic> _$GarnishOptionToJson(GarnishOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price
    };

Garnish _$GarnishFromJson(Map<String, dynamic> json) {
  return Garnish()
    ..id = json['id'] as String
    ..description = json['description'] as String
    ..min = json['min'] as int
    ..max = json['max'] as int
    ..options = (json['options'] as List)
        .map((e) => GarnishOption.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$GarnishToJson(Garnish instance) {
  var val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['min'] = instance.min;
  val['max'] = instance.max;
  val['options'] = _optionsToJson(instance.options);
  return val;
}
