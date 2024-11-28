import 'package:flutter/widgets.dart';
import 'package:fluxtube/core/model/language_model.dart';

const fallbackLocale = Locale('en');

final supportedLocales = [
  const Locale('en'), // English
  const Locale('ml'), // Malayalam
  const Locale('tr'), //Turkish
  const Locale('ru'), //Russian
  const Locale('zh'), //Chinese (Simplified)
  const Locale('pt'), //Portuguese (Brazil)
  const Locale('ar'), //Arabic
  const Locale('ja'), //Japanese
  const Locale('ko'), //Korean

// Add more locales as needed
];

final List<LanguageModel> languages = [
  LanguageModel(name: "English", code: "en"),
  LanguageModel(name: "മലയാളം", code: "ml"),
  LanguageModel(name: "Türkçe", code: "tr"),
  LanguageModel(name: "Русский", code: "ru"),
  LanguageModel(name: "中文", code: "zh"),
  LanguageModel(name: "Português", code: "pt"),
  LanguageModel(name: "العربية", code: "ar"),
  LanguageModel(name: "日本語", code: "ja"),
  LanguageModel(name: "한국어", code: "ko"),
];
