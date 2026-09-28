import 'package:flutter/material.dart';

import '../core/constants.dart';

class DesignScreen extends StatelessWidget {
  const DesignScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widthScale = constraints.maxWidth / AppMetrics.designWidth;

            final scale = widthScale.clamp(0.8, 2.0).toDouble();

            final contentWidth = AppMetrics.designWidth * scale;
            final contentHeight = AppMetrics.designHeight * scale;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight < contentHeight
                    ? contentHeight
                    : constraints.maxHeight,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: contentHeight,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: AppMetrics.designWidth,
                        height: AppMetrics.designHeight,
                        child: child,
                      ),
                    ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 7,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
