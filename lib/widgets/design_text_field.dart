import 'package:flutter/material.dart';

import '../core/constants.dart';

class DesignTextField extends StatelessWidget {
  const DesignTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,

      style: const TextStyle(fontSize: 16, color: AppColors.text, height: 1),

      cursorColor: AppColors.green,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),

        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),

        isDense: true,

        contentPadding: const EdgeInsets.only(bottom: 6, top: 12),

        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),

        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.green),
        ),

        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
    );
  }
}
