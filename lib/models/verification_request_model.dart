class VerificationRequest {
  String code;
  Map<String, String> args;

  VerificationRequest(this.code, this.args);

  Map toJson() => {
        'code': code,
        'args': args,
      };
}
