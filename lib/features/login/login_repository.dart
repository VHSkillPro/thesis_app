import 'package:thesis_app/features/login/login_service.dart';
import 'package:thesis_app/features/login/model/login_model.dart';

class LoginRepository {
  LoginRepository({required loginService}) : _loginService = loginService;

  final LoginService _loginService;

  Future<LoginModel> login(String username, String password) async {
    final response = await _loginService.login(username, password);
    return LoginModel.fromResponse(response);
  }
}
