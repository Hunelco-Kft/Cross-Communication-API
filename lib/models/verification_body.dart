import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_body.g.dart';

@JsonSerializable()
class VerificationBody extends Equatable {
  final String code;
  final Map<String, String> args;

  const VerificationBody({required this.code, required this.args});

  factory VerificationBody.fromJson(Map<String, dynamic> json) => _$VerificationBodyFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationBodyToJson(this);

  @override
  List<Object?> get props => <Object?>[code, args];
}
