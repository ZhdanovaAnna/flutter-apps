# Калькулятор ИМТ — Flutter + Supabase

Готовый Flutter-проект для VS Code. Android Studio для редактирования проекта не требуется.

## 1. Что нужно

- Flutter SDK
- VS Code + Flutter/Dart extensions
- Для запуска в Chrome: Google Chrome
- Для запуска на Android-телефоне/сборки APK: Android SDK и подключённое Android-устройство. Android Studio при этом не является обязательной IDE.

## 2. Настройка Supabase

Откройте:

`lib/core/supabase_config.dart`

и замените:

- `PASTE_YOUR_SUPABASE_PROJECT_URL_HERE` на Project URL;
- `PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE` на Publishable key.

Используйте именно Publishable key, не Secret/service-role key.

SQL для существующей таблицы находится в `supabase_schema.sql`.

## 3. Запуск

В терминале VS Code из корня проекта:

```powershell
flutter pub get
flutter run -d chrome
```

Для Android, если Android SDK и устройство уже настроены:

```powershell
flutter devices
flutter run
```

## 4. Структура

- `lib/screens` — экраны входа, регистрации, калькулятора и профиля;
- `lib/services` — работа с Supabase;
- `lib/models` — модели данных;
- `lib/core` — расчёт ИМТ, константы и конфигурация Supabase;
- `lib/widgets` — переиспользуемые элементы интерфейса;
- `assets` — ресурсы приложения;
- `reference` — референс экранов.

Проект использует существующую таблицу `public.body_mass_index_calculations` и Supabase Auth. Отдельная таблица профилей не нужна: имя и фамилия хранятся в user metadata.
