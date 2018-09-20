// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JSONData _$JSONDataFromJson(Map<String, dynamic> json) {
  return JSONData(
      type: json['type'] as String,
      sectionId: json['sectionId'] as String,
      dishId: json['dishId'] as String,
      garnishId: json['garnishId'] as String,
      selectedOptions:
          (json['selectedOptions'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$JSONDataToJson(JSONData instance) {
  var val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sectionId', instance.sectionId);
  writeNotNull('dishId', instance.dishId);
  writeNotNull('garnishId', instance.garnishId);
  writeNotNull('selectedOptions', instance.selectedOptions);
  return val;
}
