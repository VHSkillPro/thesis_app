import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:thesis_app/core/config.dart';

class LoginService {
  Future<Response<dynamic>> login(String username, String password) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"username": username, "password": password});

    try {
      var dio = Dio();
      var response = await dio.post(
        '${Config.baseApiUrl}/auth/login',
        options: Options(headers: headers),
        data: data,
      );

      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
