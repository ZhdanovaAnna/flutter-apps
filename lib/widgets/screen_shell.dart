import 'package:flutter/material.dart';

import '../core/constants.dart';

class DesignScreen extends StatelessWidget {
  const DesignScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ВАЖНО:
      // клавиатура должна уменьшать доступную область,
      // чтобы SingleChildScrollView мог прокрутить форму.
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Масштабируем дизайн только по ширине.
            //
            // Нельзя учитывать height:
            // при открытии клавиатуры высота резко уменьшается,
            // из-за этого раньше весь экран начинал пересчитывать масштаб.
            final scale = (constraints.maxWidth / AppMetrics.designWidth)
                .clamp(0.8, 2.0)
                .toDouble();

            final contentWidth = AppMetrics.designWidth * scale;
            final contentHeight = AppMetrics.designHeight * scale;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              // Небольшое место снизу, чтобы кнопку/поле
              // можно было полностью вывести над клавиатурой.
              padding: const EdgeInsets.only(bottom: 24),

              child: SizedBox(
                width: constraints.maxWidth,

                // Если экран выше макета — растягиваем область.
                // Если клавиатура уменьшила экран — макет остаётся
                // полноценного размера и его можно прокручивать.
                height: contentHeight > constraints.maxHeight
                    ? contentHeight
                    : constraints.maxHeight,

                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    height: contentHeight,

                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,

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
