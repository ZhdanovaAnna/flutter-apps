import 'package:flutter/material.dart';

import '../core/constants.dart';

class DesignScreen extends StatelessWidget {
  const DesignScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Не уменьшаем весь интерфейс при появлении клавиатуры.
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Масштабируем дизайн ТОЛЬКО по ширине.
            //
            // Раньше здесь учитывалась ещё и высота:
            //
            // constraints.maxHeight / AppMetrics.designHeight
            //
            // Из-за этого при открытии клавиатуры весь экран
            // резко уменьшался.
            final scale = (constraints.maxWidth / AppMetrics.designWidth)
                .clamp(1.0, 2.0)
                .toDouble();

            final width = AppMetrics.designWidth * scale;
            final height = AppMetrics.designHeight * scale;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: constraints.maxWidth,
                height: height > constraints.maxHeight
                    ? height
                    : constraints.maxHeight,
                child: Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: FittedBox(
                      fit: BoxFit.fill,
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
