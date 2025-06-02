import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:thesis_app/core/config.dart';

class AttendanceService {
  final dio = Dio();
  final baseUrl = '${Config.baseApiUrl}/find-student';

  /// Sends a POST request with the provided [embedding] to the server to find attendance information.
  ///
  /// The [embedding] parameter is a list of doubles representing the embedding vector.
  ///
  /// Returns a [Future] that resolves to a [Map] containing:
  /// - `"success"`: a [bool] indicating if the request was successful,
  /// - `"statusCode"`: the HTTP status code of the response,
  /// - `"data"`: the response data if successful,
  /// - `"message"`: an error message if the request failed.
  ///
  /// Handles [DioException] and returns appropriate error information.
  Future<Map<String, dynamic>> find(List<double> embedding) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: json.encode({'embedding': embedding}),
        options: Options(headers: {'x-api-key': Config.apiKey}),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "message": response.data['message'] ?? 'Request successful',
          "data": response.data['data'] ?? {},
        };
      } else {
        return {
          "success": false,
          "statusCode": response.statusCode ?? 500,
          "message": response.data ?? 'An error occurred',
        };
      }
    } on DioException catch (e) {
      return {
        "success": false,
        "statusCode": e.response?.statusCode ?? 500,
        "message": e.response?.data ?? 'An error occurred',
      };
    }
  }
}
