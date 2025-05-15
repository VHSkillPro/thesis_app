import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:thesis_app/core/entities/token.dart';

class LoginModel {
  late bool success;
  late int statusCode;
  late String message;
  late Token? token;

  LoginModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.token,
  });

  factory LoginModel.fromResponse(Response<dynamic> response) {
    final responseData = response.data as Map<String, dynamic>;

    return LoginModel(
      success: response.statusCode == 200,
      statusCode: response.statusCode ?? 500,
      message: responseData["message"] ?? "Lỗi máy chủ",
      token:
          response.statusCode == 200
              ? Token.fromJson(responseData["data"])
              : null,
    );
  }
}
