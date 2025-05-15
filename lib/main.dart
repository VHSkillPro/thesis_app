import 'package:flutter/material.dart';
import 'package:thesis_app/features/login/login_repository.dart';
import 'package:thesis_app/features/login/login_service.dart';
import 'package:thesis_app/features/login/login_viewmodel.dart';
import 'package:thesis_app/features/login/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loginService = LoginService();
    final loginRepository = LoginRepository(loginService: loginService);
    final viewModel = LoginViewmodel(loginRepository: loginRepository);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(viewModel: viewModel),
    );
  }
}
