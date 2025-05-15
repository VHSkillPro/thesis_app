import 'package:flutter/material.dart';
import 'package:thesis_app/features/login/login_repository.dart';

class LoginViewmodel extends ChangeNotifier {
  final LoginRepository _loginRepository;

  LoginViewmodel({required loginRepository})
    : _loginRepository = loginRepository;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _usernameController = TextEditingController();
  TextEditingController get usernameController => _usernameController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = _usernameController.text;
    String password = _passwordController.text;

    final response = await _loginRepository.login(username, password);

    if (response.success) {
      // Handle successful login
      print('Login successful: ${response.message}');
    } else {
      // Handle login failure
      print('Login failed: ${response.message}');
    }
  }
}
