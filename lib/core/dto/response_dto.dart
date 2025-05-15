class BaseResponse {
  final bool success;
  final int? statusCode;
  final String message;
  BaseResponse({
    required this.success,
    required this.statusCode,
    required this.message,
  });
}

class ShowResponse<T> extends BaseResponse {
  final T? data;
  ShowResponse({
    required super.success,
    required super.statusCode,
    required super.message,
    this.data,
  });
}
