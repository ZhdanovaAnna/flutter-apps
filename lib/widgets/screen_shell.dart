import 'package:flutter/material.dart';

import '../core/constants.dart';

class DesignScreen extends StatelessWidget {
  const DesignScreen({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: keyboardOpen ? null : bottomNavigationBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 52
                      ? constraints.maxHeight - 52
                      : 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DesignCard extends StatelessWidget {
  const DesignCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}
