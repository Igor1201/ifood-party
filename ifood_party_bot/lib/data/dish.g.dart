// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dish _$DishFromJson(Map<String, dynamic> json) {
  return Dish()
    ..id = json['id'] as String
    ..image = json['image'] as String
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..price = (json['price'] as num).toDouble()
    ..garnishes = (json['garnishes'] as List)
        ?.map((e) =>
            e == null ? null : Garnish.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$DishToJson(Dish instance) {
  var val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('image', instance.image);
  val['name'] = instance.name;
  writeNotNull('description', instance.description);
  val['price'] = instance.price;
  writeNotNull('garnishes',
      instance.garnishes == null ? null : _garnishesToJson(instance.garnishes));
  return val;
}
