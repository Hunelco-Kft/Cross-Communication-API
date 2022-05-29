// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_payload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataPayloadModel _$DataPayloadModelFromJson(Map<String, dynamic> json) =>
    DataPayloadModel(
      endpoint: json['endpoint'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$DataPayloadModelToJson(DataPayloadModel instance) =>
    <String, dynamic>{
      'endpoint': instance.endpoint,
      'data': instance.data,
    };
