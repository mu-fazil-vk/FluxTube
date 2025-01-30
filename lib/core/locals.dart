import 'package:flutter/widgets.dart';
import 'package:fluxtube/core/model/language_model.dart';

const fallbackLocale = Locale('en');

final supportedLocales = [
  const Locale('ar'), //Arabic
  const Locale('en'), // English
  const Locale('fr'), //French
  const Locale('ja'), //Japanese
  const Locale('ko'), //Korean
  const Locale('ml'), // Malayalam
  const Locale('pl'), //Polish
  const Locale('pt'), //Portuguese (Brazil)
  const Locale('ru'), //Russian
  const Locale('tr'), //Turkish
  const Locale('zh'), //Chinese (Simplified)

// Add more locales as needed
];

final List<LanguageModel> languages = [
  LanguageModel(name: "العربية", code: "ar"),
  LanguageModel(name: "English", code: "en"),
  LanguageModel(name: "Français", code: "fr"),
  LanguageModel(name: "日本語", code: "ja"),
  LanguageModel(name: "한국어", code: "ko"),
  LanguageModel(name: "മലയാളം", code: "ml"),
  LanguageModel(name: "Polski", code: "pl"),
  LanguageModel(name: "Português", code: "pt"),
  LanguageModel(name: "Русский", code: "ru"),
  LanguageModel(name: "Türkçe", code: "tr"),
  LanguageModel(name: "中文", code: "zh"),
];
