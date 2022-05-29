// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationBody _$VerificationBodyFromJson(Map<String, dynamic> json) =>
    VerificationBody(
      code: json['code'] as String,
      args: Map<String, String>.from(json['args'] as Map),
    );

Map<String, dynamic> _$VerificationBodyToJson(VerificationBody instance) =>
    <String, dynamic>{
      'code': instance.code,
      'args': instance.args,
    };
