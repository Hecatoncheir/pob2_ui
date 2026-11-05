enum AppLanguage {
  russian('ru', 'Русский'),
  english('en', 'English'),
  french('fr', 'Français'),
  german('de', 'Deutsch'),
  spanish('es', 'Español'),
  portuguese('pt-BR', 'Português (Brasil)'),
  japanese('ja', '日本語'),
  korean('ko', '한국어'),
  thai('th', 'ไทย'),
  chinese('zh-Hant', '繁體中文');

  const AppLanguage(this.code, this.label);
  final String code, label;

  static AppLanguage parse(String? code) =>
      values.where((language) => language.code == code).firstOrNull ?? russian;
}
