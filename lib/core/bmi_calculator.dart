class BmiResult {
  const BmiResult({
    required this.value,
    required this.category,
    required this.recommendation,
  });

  final double value;
  final String category;
  final String recommendation;
}

class BmiCalculator {
  static BmiResult calculate({
    required double heightCm,
    required double weightKg,
  }) {
    final heightM = heightCm / 100;
    final value = weightKg / (heightM * heightM);

    if (value <= 16) {
      return BmiResult(
        value: value,
        category: 'Выраженный дефицит массы тела',
        recommendation: 'Советуем набрать вес для здоровья.',
      );
    }
    if (value < 18.5) {
      return BmiResult(
        value: value,
        category: 'Недостаточная масса тела',
        recommendation: 'Рекомендуется увеличить массу тела.',
      );
    }
    if (value < 25) {
      return BmiResult(
        value: value,
        category: 'Норма',
        recommendation: 'Ваш вес в здоровом диапазоне — поддерживайте его!',
      );
    }
    if (value < 30) {
      return BmiResult(
        value: value,
        category: 'Избыточная масса тела или предожирение',
        recommendation: 'Желательно снизить вес для улучшения самочувствия.',
      );
    }
    if (value < 35) {
      return BmiResult(
        value: value,
        category: 'Ожирение',
        recommendation: 'Рекомендуется уменьшить вес под контролем специалиста.',
      );
    }
    if (value < 40) {
      return BmiResult(
        value: value,
        category: 'Ожирение резкое',
        recommendation: 'Необходимо снижение веса с медицинской поддержкой.',
      );
    }
    return BmiResult(
      value: value,
      category: 'Очень резкое ожирение',
      recommendation: 'Требуется срочная коррекция веса под наблюдением врача.',
    );
  }
}
