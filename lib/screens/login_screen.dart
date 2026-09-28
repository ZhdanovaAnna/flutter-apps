import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../widgets/design_button.dart';
import '../widgets/design_text_field.dart';
import '../widgets/screen_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? '' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : '';
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = 'Заполните все поля');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.instance.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Неверный email или пароль');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignScreen(
      child: Column(
        children: [
          const SizedBox(height: 167),
          const Text(
            'Вход в приложение',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 190,
            height: 136,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 7,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 39,
                    child: DesignTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'example@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 39,
                    child: DesignTextField(
                      controller: _password,
                      label: 'Пароль',
                      hint: 'Введите пароль',
                      obscureText: true,
                      validator: _required,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 18,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: DesignButton(
              text: _loading ? 'ВХОД...' : 'ВОЙТИ',
              onPressed: _loading ? null : _login,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _error ?? 'Неверный email или пароль!',
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
