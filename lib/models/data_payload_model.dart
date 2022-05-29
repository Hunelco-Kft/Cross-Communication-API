import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_payload_model.g.dart';

@JsonSerializable()
class DataPayloadModel extends Equatable {
  final String endpoint;
  final String data;

  const DataPayloadModel({required this.endpoint, required this.data});

  factory DataPayloadModel.fromJson(Map<String, dynamic> json) => _$DataPayloadModelFromJson(json);
  Map<String, dynamic> toJson() => _$DataPayloadModelToJson(this);

  @override
  List<Object?> get props => <Object?>[endpoint, data];
}
