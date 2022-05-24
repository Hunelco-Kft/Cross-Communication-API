class DataPayload {
  String endpoint;
  String data;

  DataPayload(this.endpoint, this.data);

  Map toJson() => {
        'endpoint': endpoint,
        'data': data,
      };
}
