import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../widgets/design_button.dart';
import '../widgets/design_text_field.dart';
import '../widgets/screen_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? '' : null;

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : '';
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = 'Заполните все поля');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Пароль должен содержать минимум 6 символов');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await SupabaseService.instance.signUp(
        firstName: _name.text,
        lastName: _surname.text,
        email: _email.text,
        password: _password.text,
      );

      if (!mounted) return;
      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Регистрация успешна. Подтвердите email и войдите.'),
          ),
        );
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Не удалось создать аккаунт');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignScreen(
      child: Column(
        children: [
          const SizedBox(height: 119),
          const Text(
            'Регистрация',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            width: 190,
            height: 212,
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
                      controller: _name,
                      label: 'Имя',
                      hint: 'Введите ваше имя',
                      validator: _required,
                    ),
                  ),
                  SizedBox(
                    height: 39,
                    child: DesignTextField(
                      controller: _surname,
                      label: 'Фамилия',
                      hint: 'Введите вашу фамилию',
                      validator: _required,
                    ),
                  ),
                  SizedBox(
                    height: 39,
                    child: DesignTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'example@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                  ),
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
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Вернуться к странице входа',
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
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: DesignButton(
              text: _loading ? 'СОЗДАНИЕ...' : 'СОЗДАТЬ АККАУНТ',
              onPressed: _loading ? null : _register,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 10,
            child: Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.red, fontSize: 7),
            ),
          ),
        ],
      ),
    );
  }
}
