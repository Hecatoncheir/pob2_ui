import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('th'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// DPS кровотечения
  ///
  /// In en, this message translates to:
  /// **'Bleed DPS'**
  String get m4577961ef0;

  /// DPS отравления
  ///
  /// In en, this message translates to:
  /// **'Poison DPS'**
  String get m702f584eba;

  /// DPS поджога
  ///
  /// In en, this message translates to:
  /// **'Ignite DPS'**
  String get m1f133cb415;

  /// DPS пронзания и ударов
  ///
  /// In en, this message translates to:
  /// **'Impale + Hit DPS'**
  String get m986eb99e35;

  /// DPS ударов
  ///
  /// In en, this message translates to:
  /// **'Hit DPS'**
  String get m9ec0f47b47;

  /// Lua вернул не все иконки
  ///
  /// In en, this message translates to:
  /// **'Lua did not return all icons'**
  String get m0c63e733f9;

  /// Lua вернул неполный каталог
  ///
  /// In en, this message translates to:
  /// **'Lua returned an incomplete directory'**
  String get m88beda68f0;

  /// Lua вернул пустое дерево
  ///
  /// In en, this message translates to:
  /// **'Lua returned an empty tree'**
  String get m774193669c;

  /// Lua не вернул XML сборки
  ///
  /// In en, this message translates to:
  /// **'Lua did not return XML build'**
  String get mbb582808f3;

  /// Lua не вернул каталог классов
  ///
  /// In en, this message translates to:
  /// **'Lua did not return class directory'**
  String get ma83268a520;

  /// Lua не вернул описание камня
  ///
  /// In en, this message translates to:
  /// **'Lua did not return a gem description'**
  String get me9dd147860;

  /// Lua не вернул описание условия
  ///
  /// In en, this message translates to:
  /// **'Lua did not return condition description'**
  String get m59e00dc2d6;

  /// Lua не вернул отчёт сборки
  ///
  /// In en, this message translates to:
  /// **'Lua did not return the build report'**
  String get m198b0a77f8;

  /// Lua не вернул предупреждений для этого расчёта.
  ///
  /// In en, this message translates to:
  /// **'Lua returned no warnings for this calculation.'**
  String get m5bf96935c9;

  /// Lua не вернул сведения об узле
  ///
  /// In en, this message translates to:
  /// **'Lua did not return node information'**
  String get m1f463483a4;

  /// Lua не вернул совместимость камней
  ///
  /// In en, this message translates to:
  /// **'Lua did not return stone compatibility'**
  String get m35f86d9c5e;

  /// Lua не вернул характеристики
  ///
  /// In en, this message translates to:
  /// **'Lua did not return characteristics'**
  String get mecc0fe5cd1;

  /// Lua не подключён
  ///
  /// In en, this message translates to:
  /// **'Lua not connected'**
  String get mddf65e8cca;

  /// Lua не прошёл проверку
  ///
  /// In en, this message translates to:
  /// **'Lua failed verification'**
  String get m43ddb3a975;

  /// Lua отвечает · {p0} классов · совместимость проверена
  ///
  /// In en, this message translates to:
  /// **'Lua answers · {p0} classes · compatibility checked'**
  String mf01de15993(String p0);

  /// Lua отвечает. Классов в каталоге: {p0}
  ///
  /// In en, this message translates to:
  /// **'Lua answers. Classes in the catalog: {p0}'**
  String md9540a4b84(String p0);

  /// Lua подключён
  ///
  /// In en, this message translates to:
  /// **'Lua connected'**
  String get mbf7bbb22e3;

  /// MCP завершился. {p0}
  ///
  /// In en, this message translates to:
  /// **'MCP has ended. {p0}'**
  String m12e8f27f62(String p0);

  /// PoB II · Мастерская
  ///
  /// In en, this message translates to:
  /// **'PoB II · Workshop'**
  String get mcdf95e40cd;

  /// PoB II при необходимости запустит PoB свёрнутым и запросит путь к сборкам.
  ///
  /// In en, this message translates to:
  /// **'PoB II will start PoB minimized if needed and ask it for the builds folder.'**
  String get m24093f50af;

  /// PoB вернул неверные данные персонажа.
  ///
  /// In en, this message translates to:
  /// **'PoB returned incorrect character data.'**
  String get mebbddaaf16;

  /// PoB вернул неверный список персонажей.
  ///
  /// In en, this message translates to:
  /// **'PoB returned incorrect character list.'**
  String get m16a6aabd6a;

  /// PoB ещё открыт. Сохраните сборку и завершите закрытие в PoB.
  ///
  /// In en, this message translates to:
  /// **'PoB is still open. Save the build and finish closing PoB.'**
  String get m5a8756b562;

  /// PoB запущен, но мост пока не отвечает. Проверьте связь ещё раз.
  ///
  /// In en, this message translates to:
  /// **'PoB started, but the bridge has not responded yet. Check the connection again.'**
  String get m16298d522f;

  /// PoB не вернул корректную ссылку поиска
  ///
  /// In en, this message translates to:
  /// **'PoB did not return the correct search link'**
  String get mb8ddc14d08;

  /// PoB не найден. Выберите папку с приложением.
  ///
  /// In en, this message translates to:
  /// **'PoB was not found. Choose its application folder.'**
  String get m62db50eb37;

  /// PoB не сообщил путь к папке сборок.
  ///
  /// In en, this message translates to:
  /// **'PoB did not report the path to the assembly folder.'**
  String get m917bb579d9;

  /// PoB уже открыт без связи с мостом. Перезапустите его один раз.
  ///
  /// In en, this message translates to:
  /// **'PoB is open without a bridge connection. Restart it once.'**
  String get maaaf9e5923;

  /// XML больше 16 МБ
  ///
  /// In en, this message translates to:
  /// **'XML more than 16 MB'**
  String get m3127345008;

  /// XML пуст
  ///
  /// In en, this message translates to:
  /// **'XML empty'**
  String get m8ed6f8a850;

  /// XML сборки
  ///
  /// In en, this message translates to:
  /// **'XML builds'**
  String get me72be74923;

  /// XML сохранён
  ///
  /// In en, this message translates to:
  /// **'XML saved'**
  String get me097dcd9f8;

  /// import sys, struct; assert sys.version_info >= (3,11) and struct.calcsize("P") == 8, "Нужен 64-битный Python 3.11+"
  ///
  /// In en, this message translates to:
  /// **'import sys, struct; assert sys.version_info >= (3,11) and struct.calcsize(\"P\") == 8, \"Need 64-bit Python 3.11+\"'**
  String get m0aefd8ac88;

  /// {p0} {p1} готов. Git: {p2}
  ///
  /// In en, this message translates to:
  /// **'{p0} {p1} ready. Git: {p2}'**
  String m9cde7cfc3f(String p0, String p1, String p2);

  /// {p0} {p1} установлен
  ///
  /// In en, this message translates to:
  /// **'{p0} {p1} installed'**
  String m606849adbd(String p0, String p1);

  /// {p0} · копия
  ///
  /// In en, this message translates to:
  /// **'{p0} · copy'**
  String m613198439d(String p0);

  /// {p0} · правки PoB II
  ///
  /// In en, this message translates to:
  /// **'{p0} · PoB II edits'**
  String m2fb8d3ac27(String p0);

  /// {p0} · уровень {p1}
  ///
  /// In en, this message translates to:
  /// **'{p0} · level {p1}'**
  String mbefa507d02(String p0, String p1);

  /// {p0}: потрачено {p1} из {p2} очков
  ///
  /// In en, this message translates to:
  /// **'{p0}: {p1} of {p2} points spent'**
  String mb7b217c429(String p0, String p1, String p2);

  /// Актуальная версия
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get mbd1c099ba2;

  /// Амулет
  ///
  /// In en, this message translates to:
  /// **'Amulet'**
  String get m63141a77bf;

  /// База предмета
  ///
  /// In en, this message translates to:
  /// **'Item base'**
  String get mc11be494c0;

  /// Без ограничения
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get m0792a052a1;

  /// Блок
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get mfc52cf98ef;

  /// Броня
  ///
  /// In en, this message translates to:
  /// **'Armour'**
  String get mb1ff29da2c;

  /// Было
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get m4fae346e6c;

  /// Бюджет
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get m84e960d40a;

  /// В {p0} нет {p1}; требуется MCP 0.4.0 или новее
  ///
  /// In en, this message translates to:
  /// **'There is no {p1} in {p0}; requires MCP 0.4.0 or later'**
  String m7daed90e2c(String p0, String p1);

  /// В аккаунте нет доступных персонажей.
  ///
  /// In en, this message translates to:
  /// **'There are no characters available on the account.'**
  String get m2b96f1cb20;

  /// В компоненте отсутствует {p0}. Рабочая версия сохранена.
  ///
  /// In en, this message translates to:
  /// **'The component is missing {p0}. The working version has been saved.'**
  String m1163ee245e(String p0);

  /// Важные показатели
  ///
  /// In en, this message translates to:
  /// **'Important indicators'**
  String get m3e8bb03d9a;

  /// Валюта
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get m6aa14ce33b;

  /// Вариант
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get m84bb1ae656;

  /// Ваша следующая сборка
  ///
  /// In en, this message translates to:
  /// **'Your next build'**
  String get m65d05ab17f;

  /// Введите корректное число
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get mfc903d7f16;

  /// Введите корректный бюджет
  ///
  /// In en, this message translates to:
  /// **'Enter a correct budget'**
  String get m6ac5360d13;

  /// Введите название
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get mbce24a2108;

  /// Введите уровень от 1 до 100
  ///
  /// In en, this message translates to:
  /// **'Enter a level from 1 to 100'**
  String get m7dbeae99bf;

  /// Введите целое число
  ///
  /// In en, this message translates to:
  /// **'Enter an integer'**
  String get mdd0a89ad92;

  /// Введите число
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get m005a65ad56;

  /// Вернуть очко
  ///
  /// In en, this message translates to:
  /// **'Return point'**
  String get m73cac6c239;

  /// Вернуть предыдущую пару
  ///
  /// In en, this message translates to:
  /// **'Return previous pair'**
  String get mea2c4cbc02;

  /// Вернуть узел
  ///
  /// In en, this message translates to:
  /// **'Return node'**
  String get m495763fa3e;

  /// Включено
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get m4d1d43042e;

  /// Включите правки через MCP для открытой сборки.
  ///
  /// In en, this message translates to:
  /// **'Enable edits via MCP for open build.'**
  String get m054b7819ac;

  /// Вместо файла загрузки обнаружена ссылка
  ///
  /// In en, this message translates to:
  /// **'Link detected instead of download file'**
  String get m66b96db6c1;

  /// Возврат узла изменит показатели:
  ///
  /// In en, this message translates to:
  /// **'Unallocating this node will give you:'**
  String get mb087f895b2;

  /// Восстанавливаемый энергощит
  ///
  /// In en, this message translates to:
  /// **'Recoverable ES'**
  String get m25d9d4dc90;

  /// Восстановление здоровья
  ///
  /// In en, this message translates to:
  /// **'Life regen'**
  String get m0265d6c32b;

  /// Восстановление маны
  ///
  /// In en, this message translates to:
  /// **'Mana regen'**
  String get ma22a7367c9;

  /// Восстановление энергощита
  ///
  /// In en, this message translates to:
  /// **'Energy Shield regen'**
  String get md9b57dbdaf;

  /// Восстановленная сборка
  ///
  /// In en, this message translates to:
  /// **'Restored build'**
  String get m497b4d2901;

  /// Восхождение
  ///
  /// In en, this message translates to:
  /// **'Ascendancy'**
  String get m5e4d796025;

  /// Все
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get m215816bf42;

  /// Все показатели Lua
  ///
  /// In en, this message translates to:
  /// **'All indicators Lua'**
  String get m4cd169b3d5;

  /// Все характеристики
  ///
  /// In en, this message translates to:
  /// **'Total Attributes'**
  String get m51651958c6;

  /// Всего здоровья
  ///
  /// In en, this message translates to:
  /// **'Total Life'**
  String get m6fd7c8e4f1;

  /// Всего маны
  ///
  /// In en, this message translates to:
  /// **'Total Mana'**
  String get m8d6001a308;

  /// Вставить
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get mec79f4d0c8;

  /// Вставить XML
  ///
  /// In en, this message translates to:
  /// **'Insert XML'**
  String get me4c25f9a5f;

  /// Вставить найденный предмет
  ///
  /// In en, this message translates to:
  /// **'Insert found item'**
  String get md6ad11ba2b;

  /// Вставьте XML сборки. Она будет проверена и рассчитана в Lua.
  ///
  /// In en, this message translates to:
  /// **'Insert XML assemblies. It will be checked and calculated in Lua.'**
  String get m6bf3b12df4;

  /// Всё для работы
  ///
  /// In en, this message translates to:
  /// **'Everything for work'**
  String get m5b1968a662;

  /// Выберите значение
  ///
  /// In en, this message translates to:
  /// **'Select value'**
  String get m33813b1d8e;

  /// Выберите значение из каталога
  ///
  /// In en, this message translates to:
  /// **'Select a value from the catalog'**
  String get mcc8443a04f;

  /// Выберите камень умения
  ///
  /// In en, this message translates to:
  /// **'Select a skill gem'**
  String get m55a2cd1b28;

  /// Выберите камни для группы
  ///
  /// In en, this message translates to:
  /// **'Choose gems for the group'**
  String get mef96629088;

  /// Выберите класс
  ///
  /// In en, this message translates to:
  /// **'Select class'**
  String get m2ac910bfb3;

  /// Выберите папку с приложением PoB для PoE 2
  ///
  /// In en, this message translates to:
  /// **'Choose the PoB application folder for PoE 2'**
  String get m25511c66c8;

  /// Выберите папку сборок Path of Building.
  ///
  /// In en, this message translates to:
  /// **'Select the Path of Building build folder.'**
  String get m4a02239801;

  /// Выберите ту же папку сборок, которая указана в Path of Building.
  ///
  /// In en, this message translates to:
  /// **'Select the same build folder as specified in the Path of Building.'**
  String get mb5cf5f66bc;

  /// Выберите узлы и сохраните первый этап.
  ///
  /// In en, this message translates to:
  /// **'Allocate nodes and save your first step.'**
  String get md97721c61e;

  /// Выберите умение для подбора поддержек
  ///
  /// In en, this message translates to:
  /// **'Select a skill to select supports'**
  String get m0513479f74;

  /// Выберите установку PoB
  ///
  /// In en, this message translates to:
  /// **'Choose a PoB installation'**
  String get m5d67586b4c;

  /// Выберите установку в разделе «Настроить мост PoB».
  ///
  /// In en, this message translates to:
  /// **'Select an installation under “Configure PoB bridge”.'**
  String get m39b5ac8d00;

  /// Выберите характеристику и нажмите «Найти».
  ///
  /// In en, this message translates to:
  /// **'Select a characteristic and click Find.'**
  String get m2749913680;

  /// Выберите ячейку экипировки
  ///
  /// In en, this message translates to:
  /// **'Select an equipment slot'**
  String get mf99d75f022;

  /// Выбор этого узла не изменит показатели.
  ///
  /// In en, this message translates to:
  /// **'No changes from allocating this node.'**
  String get m8d6db8b168;

  /// Выбор эффекта мастерства пока доступен через XML.
  ///
  /// In en, this message translates to:
  /// **'The choice of mastery effect is currently available through XML.'**
  String get m350c155b79;

  /// Выбрано
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get m9cf249e2a8;

  /// Выбраны
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get m19a610ab93;

  /// Выбрать
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get m38aa0ac1ff;

  /// Выбрать папку
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get m88d4b06d56;

  /// Выбрать папку сборок PoB
  ///
  /// In en, this message translates to:
  /// **'Select PoB build folder'**
  String get md22f8aaed2;

  /// Выбрать путь
  ///
  /// In en, this message translates to:
  /// **'Choose a path'**
  String get m4cb6a01a0e;

  /// Выключено
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get m20494f41ab;

  /// Выполняем операцию…
  ///
  /// In en, this message translates to:
  /// **'Performing the operation...'**
  String get m903bd09e68;

  /// Горячие клавиши
  ///
  /// In en, this message translates to:
  /// **'Hotkeys'**
  String get m13b0a5cc9a;

  /// Готовая сцена загружена не полностью: {p0}
  ///
  /// In en, this message translates to:
  /// **'The finished scene is not fully loaded: {p0}'**
  String m450afec8d6(String p0);

  /// Готово
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mef05d57959;

  /// Группа больше не существует
  ///
  /// In en, this message translates to:
  /// **'The group no longer exists'**
  String get m8eb6bbb41e;

  /// Группа недоступна для редактирования
  ///
  /// In en, this message translates to:
  /// **'Group is not editable'**
  String get m1adc0797f0;

  /// Группы
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get mcd8c587351;

  /// Два компонента. Расчёты на вашем компьютере.
  ///
  /// In en, this message translates to:
  /// **'Two components. Calculations on your computer.'**
  String get ma755f360c2;

  /// Действие недоступно
  ///
  /// In en, this message translates to:
  /// **'Action not available'**
  String get me3c3ea3a85;

  /// Дерево
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get me1daa9e250;

  /// Дерево недоступно: {p0}
  ///
  /// In en, this message translates to:
  /// **'Tree unavailable: {p0}'**
  String m0e1306f92c(String p0);

  /// Дерево пока недоступно
  ///
  /// In en, this message translates to:
  /// **'Tree not yet available'**
  String get m57d9f5cb7c;

  /// Для готового дерева PoB обновите MCP до 0.7.0.
  ///
  /// In en, this message translates to:
  /// **'For a finished PoB tree, update MCP to 0.7.0.'**
  String get m7c2e51e000;

  /// Для дерева нужен MCP 0.5.0. Обновите компонент MCP.
  ///
  /// In en, this message translates to:
  /// **'Tree needs MCP 0.5.0. Update component MCP.'**
  String get mdb491b2fb7;

  /// Для оригинальных иконок обновите MCP до 0.6.0.
  ///
  /// In en, this message translates to:
  /// **'For original icons, update MCP to 0.6.0.'**
  String get m130a0abbfa;

  /// Для поиска по характеристике обновите MCP до 0.9.0 в разделе «Компоненты».
  ///
  /// In en, this message translates to:
  /// **'To search by characteristic, update MCP to 0.9.0 in the Components section.'**
  String get m6f9519e788;

  /// Для управления окном PoB через Wine нужен X11 или XWayland.
  ///
  /// In en, this message translates to:
  /// **'Managing the PoB window through Wine requires X11 or XWayland.'**
  String get mbd97478bba;

  /// Для установки нужны Git и 64-битный Python 3.11+. После загрузки компонентов расчёты работают без сети.
  ///
  /// In en, this message translates to:
  /// **'Installation requires Git and 64-bit Python 3.11+. After loading the components, calculations work without a network.'**
  String get m3e069d1fae;

  /// Для этого умения нельзя добавить поддержки
  ///
  /// In en, this message translates to:
  /// **'This skill cannot be supported'**
  String get m659973f49f;

  /// Для этой платформы нет пакета обновления
  ///
  /// In en, this message translates to:
  /// **'There is no service pack for this platform'**
  String get ma2ab6a340a;

  /// Для этой платформы пока нет установщика
  ///
  /// In en, this message translates to:
  /// **'There is no installer for this platform yet'**
  String get mc0259d55bc;

  /// До узла
  ///
  /// In en, this message translates to:
  /// **'To node'**
  String get m08afe540b9;

  /// До узла: {p0} очков
  ///
  /// In en, this message translates to:
  /// **'{p0} points to node'**
  String m8997ad5a89(String p0);

  /// Добавить
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get m71038c53bb;

  /// Добавить и рассчитать
  ///
  /// In en, this message translates to:
  /// **'Add and calculate'**
  String get ma11b26e5e9;

  /// Добавить предмет
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get m9cef26392f;

  /// Добавьте группу камней, чтобы получить расчёт умения.
  ///
  /// In en, this message translates to:
  /// **'Add a group of stones to get the skill calculation.'**
  String get mbc10505bdf;

  /// Дождитесь завершения текущей операции
  ///
  /// In en, this message translates to:
  /// **'Wait for the current operation to complete'**
  String get mab04eae138;

  /// Дополнительные ячейки
  ///
  /// In en, this message translates to:
  /// **'Additional cells'**
  String get mf0216281b8;

  /// Доступ действует для текущей сборки. Правки можно отменить.
  ///
  /// In en, this message translates to:
  /// **'Access is valid for the current build. Edits can be undone.'**
  String get m4122860034;

  /// Доступ к редактору PoB II отключён.
  ///
  /// In en, this message translates to:
  /// **'Access to the PoB II editor has been disabled.'**
  String get m549a4c810c;

  /// Доступна версия {p0}
  ///
  /// In en, this message translates to:
  /// **'Version {p0} available'**
  String m10b5bc7e91(String p0);

  /// Дух
  ///
  /// In en, this message translates to:
  /// **'Spirit'**
  String get m41a4fa8b6a;

  /// Если PoB попросит сохранить сборку, ответьте в его окне.
  ///
  /// In en, this message translates to:
  /// **'If PoB asks you to save the build, respond in its window.'**
  String get m974eae850c;

  /// Есть обновление
  ///
  /// In en, this message translates to:
  /// **'There is an update'**
  String get mcefa1c56a5;

  /// Ещё
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get m2071fb9905;

  /// Журнал и подробности
  ///
  /// In en, this message translates to:
  /// **'Log and details'**
  String get mf9a38201c0;

  /// Завершите редактирование перед закрытием приложения
  ///
  /// In en, this message translates to:
  /// **'Complete editing before closing the application'**
  String get m0f98334ad1;

  /// Завершите текущую операцию или закройте диалог PoB II.
  ///
  /// In en, this message translates to:
  /// **'Complete the current operation or close the PoB II dialog.'**
  String get me1d20330c5;

  /// Загружать обновления автоматически
  ///
  /// In en, this message translates to:
  /// **'Download updates automatically'**
  String get m230ebdecca;

  /// Загрузка LuaJIT и lua-utf8 для {p0}…
  ///
  /// In en, this message translates to:
  /// **'Loading LuaJIT and lua-utf8 for {p0}...'**
  String m65a1b960c7(String p0);

  /// Загрузка {p0} {p1}…
  ///
  /// In en, this message translates to:
  /// **'Loading {p0} {p1}…'**
  String maafcfa710b(String p0, String p1);

  /// Загрузка не завершена: {p0}
  ///
  /// In en, this message translates to:
  /// **'Loading incomplete: {p0}'**
  String m912da5cc75(String p0);

  /// Загрузка оригинального дерева PoB · {p0} / {p1}
  ///
  /// In en, this message translates to:
  /// **'Loading original PoB tree {p0} / {p1}'**
  String m35c7d57c9f(String p0, String p1);

  /// Загрузка: HTTP {p0}
  ///
  /// In en, this message translates to:
  /// **'Loading: HTTP {p0}'**
  String m7ac5d410c5(String p0);

  /// Заданные
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get m09fef6d0df;

  /// Закрепить показатели
  ///
  /// In en, this message translates to:
  /// **'Fasten indicators'**
  String get m540fb030a9;

  /// Закройте выбранный PoB вручную и повторите запуск.
  ///
  /// In en, this message translates to:
  /// **'Close the selected PoB manually and try again.'**
  String get m7ab4920661;

  /// Закрыть
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get ma7a4033657;

  /// Заменить предмет
  ///
  /// In en, this message translates to:
  /// **'Replace item'**
  String get mbfc7b67eb5;

  /// Заметки к сборке
  ///
  /// In en, this message translates to:
  /// **'Build notes'**
  String get mdc4baf32ac;

  /// Заметки сохраняются автоматически
  ///
  /// In en, this message translates to:
  /// **'Notes are saved automatically'**
  String get mbdb05f34ee;

  /// Запустить подготовку
  ///
  /// In en, this message translates to:
  /// **'Start setup'**
  String get ma2d2d73bb5;

  /// Зачарования
  ///
  /// In en, this message translates to:
  /// **'Enchantments'**
  String get m1107806954;

  /// Защита
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get m792acb40e4;

  /// Здесь будут ваши сборки
  ///
  /// In en, this message translates to:
  /// **'Your builds will go here'**
  String get mfac4030099;

  /// Здоровье
  ///
  /// In en, this message translates to:
  /// **'Life'**
  String get m0cc21de8b8;

  /// Значение
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get mf869293c62;

  /// Значение из текущего отчёта Lua PoB.
  ///
  /// In en, this message translates to:
  /// **'Value from the current Lua PoB report.'**
  String get mf6a527732e;

  /// Игровые переводы загружаются…
  ///
  /// In en, this message translates to:
  /// **'Loading game translations…'**
  String get ma9f9d23dcb;

  /// Идеи, к которым хочется вернуться
  ///
  /// In en, this message translates to:
  /// **'Ideas that you want to return to'**
  String get m5cb66ce618;

  /// Избежание атак вблизи
  ///
  /// In en, this message translates to:
  /// **'Melee avoid chance'**
  String get ma48353b7b1;

  /// Избежание снарядов
  ///
  /// In en, this message translates to:
  /// **'Projectile avoid chance'**
  String get m8a055d1e48;

  /// Избежание чар
  ///
  /// In en, this message translates to:
  /// **'Spell avoid chance'**
  String get mdcd4c2c384;

  /// Изменить уровень этапа
  ///
  /// In en, this message translates to:
  /// **'Edit milestone level'**
  String get m0094a04edd;

  /// Изображение камня не найдено
  ///
  /// In en, this message translates to:
  /// **'Stone image not found'**
  String get md5a9ca934e;

  /// Изображение камня недоступно
  ///
  /// In en, this message translates to:
  /// **'Stone image unavailable'**
  String get m1ccb8777b8;

  /// Импорт персонажа из PoB
  ///
  /// In en, this message translates to:
  /// **'Importing a character from PoB'**
  String get medafd2f9d8;

  /// Импортированная сборка
  ///
  /// In en, this message translates to:
  /// **'Imported assembly'**
  String get m2c72186c20;

  /// Импортировать
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get m848ed36881;

  /// Импортировать из PoB
  ///
  /// In en, this message translates to:
  /// **'Import from PoB'**
  String get mdb8bc611c3;

  /// Импортировать персонажа
  ///
  /// In en, this message translates to:
  /// **'Import character'**
  String get mcaa43cf432;

  /// Интеллект
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get ma8f8e11f0c;

  /// Искать на рынке
  ///
  /// In en, this message translates to:
  /// **'Search the market'**
  String get mb1f4f27181;

  /// Источник
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get m56e46960c1;

  /// Исходный Lua подключён · {p0} классов
  ///
  /// In en, this message translates to:
  /// **'Source Lua connected · {p0} classes'**
  String m8b48ab31e9(String p0);

  /// Исходный Lua-движок и игровые данные
  ///
  /// In en, this message translates to:
  /// **'Source Lua engine and game data'**
  String get m26c6ade68e;

  /// Исходный отчёт
  ///
  /// In en, this message translates to:
  /// **'Original report'**
  String get m95cbeda583;

  /// Камень включён
  ///
  /// In en, this message translates to:
  /// **'Gem enabled'**
  String get mfc105fdc07;

  /// Камни не найдены
  ///
  /// In en, this message translates to:
  /// **'No stones found'**
  String get m05b721e615;

  /// Камни поддержки
  ///
  /// In en, this message translates to:
  /// **'Support stones'**
  String get m566d4d32d7;

  /// Каталог
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get md0ef3540b0;

  /// Качество, %
  ///
  /// In en, this message translates to:
  /// **'Quality, %'**
  String get m74189f93c7;

  /// Класс
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get m1711aecef4;

  /// Кольцо I
  ///
  /// In en, this message translates to:
  /// **'Ring I'**
  String get m209e516133;

  /// Кольцо II
  ///
  /// In en, this message translates to:
  /// **'Ring II'**
  String get m20555cd71a;

  /// Кольцо III
  ///
  /// In en, this message translates to:
  /// **'Ring III'**
  String get m9ca9ef70fe;

  /// Команда недоступна в редакторе PoB II.
  ///
  /// In en, this message translates to:
  /// **'The command is not available in the PoB II editor.'**
  String get m4d1b5babac;

  /// Компоненты
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get m1e8466ebeb;

  /// Компоненты установлены. Можно подключить Lua.
  ///
  /// In en, this message translates to:
  /// **'Components are installed. You can connect Lua.'**
  String get m9c01f77f07;

  /// Контрольная сумма перевода не совпала
  ///
  /// In en, this message translates to:
  /// **'Transfer checksum did not match'**
  String get mcf9fbc3f41;

  /// Крит. шанс
  ///
  /// In en, this message translates to:
  /// **'Crit. chance'**
  String get m6916d088f3;

  /// Левая рука
  ///
  /// In en, this message translates to:
  /// **'Left hand'**
  String get m7bf311d808;

  /// Левая рука II
  ///
  /// In en, this message translates to:
  /// **'Left hand II'**
  String get m7825825def;

  /// Лига
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get m1190db95a3;

  /// Ловкость
  ///
  /// In en, this message translates to:
  /// **'Dexterity'**
  String get m609fc60c74;

  /// Локальная связь интерфейса с расчётами
  ///
  /// In en, this message translates to:
  /// **'Local interface connection with calculations'**
  String get m5da5bd2f47;

  /// Локальный мост PoB
  ///
  /// In en, this message translates to:
  /// **'Local PoB bridge'**
  String get mba18ba5922;

  /// Любая база
  ///
  /// In en, this message translates to:
  /// **'Any base'**
  String get mab7d96eb1a;

  /// Максимальный выдерживаемый удар
  ///
  /// In en, this message translates to:
  /// **'Eff. Maximum Hit Taken'**
  String get m187dafbec4;

  /// Максимум
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get mf33c9a814c;

  /// Мана
  ///
  /// In en, this message translates to:
  /// **'Mana'**
  String get mc73618fdf4;

  /// Мастерская
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get m6c50317db8;

  /// Масштаб 100%
  ///
  /// In en, this message translates to:
  /// **'Scale 100%'**
  String get m7e5029786d;

  /// Масштаб интерфейса
  ///
  /// In en, this message translates to:
  /// **'Interface scale'**
  String get mbe517dba6c;

  /// Минимум
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get m10808f1297;

  /// Множитель критического удара
  ///
  /// In en, this message translates to:
  /// **'Crit Multiplier'**
  String get m22e1e2c7ad;

  /// Мои сборки
  ///
  /// In en, this message translates to:
  /// **'My builds'**
  String get m13e9f80144;

  /// Молния
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get m16d1252699;

  /// Мост установлен. Перезапустите PoB для проверки связи.
  ///
  /// In en, this message translates to:
  /// **'Bridge installed. Restart PoB to check the connection.'**
  String get mf8c37fc77b;

  /// НЕДАВНИЕ
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get m204751ca09;

  /// На очко
  ///
  /// In en, this message translates to:
  /// **'На очко'**
  String get me113ee319c;

  /// На очко: {p0}
  ///
  /// In en, this message translates to:
  /// **'На очко: {p0}'**
  String m1d32e63718(String p0);

  /// На этом расстоянии подходящих узлов нет.
  ///
  /// In en, this message translates to:
  /// **'There are no suitable nodes at this distance.'**
  String get mb862bf4e42;

  /// Набор оружия
  ///
  /// In en, this message translates to:
  /// **'Weapon set'**
  String get mf71a076c69;

  /// Нагрудник
  ///
  /// In en, this message translates to:
  /// **'Bib'**
  String get mff86959fa1;

  /// Нажмите сочетание с Ctrl, Alt или Cmd. Esc — отмена.
  ///
  /// In en, this message translates to:
  /// **'Press the combination with Ctrl, Alt or Cmd. Esc - cancel.'**
  String get m38509ab991;

  /// Название
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get m0918b4ba92;

  /// Название группы
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get md45e66ab55;

  /// Название сборки
  ///
  /// In en, this message translates to:
  /// **'Название сборки'**
  String get m51233393a5;

  /// Найдено несколько папок PoB. Выберите нужную вручную.
  ///
  /// In en, this message translates to:
  /// **'Several PoB folders were found. Choose the one you use.'**
  String get m0bf71e1c90;

  /// Найдено узлов: {p0}
  ///
  /// In en, this message translates to:
  /// **'Nodes found: {p0}'**
  String mbfd148a7e8(String p0);

  /// Найти
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get mbe6156b8e4;

  /// Найти камень
  ///
  /// In en, this message translates to:
  /// **'Search gems'**
  String get m7d4ff2d217;

  /// Найти папку PoB
  ///
  /// In en, this message translates to:
  /// **'Find PoB folder'**
  String get m85b24dddaa;

  /// Найти сборку
  ///
  /// In en, this message translates to:
  /// **'Найти сборку'**
  String get m302605cf87;

  /// Найти узел
  ///
  /// In en, this message translates to:
  /// **'Find node'**
  String get mf211301b5e;

  /// Найти узлы по характеристике
  ///
  /// In en, this message translates to:
  /// **'Find nodes by characteristic'**
  String get m60ea60b326;

  /// Найти условие
  ///
  /// In en, this message translates to:
  /// **'Find condition'**
  String get mb37bd07a8a;

  /// Настроить мост PoB
  ///
  /// In en, this message translates to:
  /// **'Set up PoB bridge'**
  String get m9a92ce1cef;

  /// Настройки
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get m985b5e0f2c;

  /// Нативный выпуск MCP: HTTP {p0}
  ///
  /// In en, this message translates to:
  /// **'Native release MCP: HTTP {p0}'**
  String m5ffb2fa414(String p0);

  /// Не выбраны
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get m28997f7565;

  /// Не назначено
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get mf3120930ea;

  /// Не найден LOCALAPPDATA
  ///
  /// In en, this message translates to:
  /// **'LOCALAPPDATA not found'**
  String get m09823db229;

  /// Не найден домашний каталог
  ///
  /// In en, this message translates to:
  /// **'Home directory not found'**
  String get m0dbf2115c1;

  /// Не распознано Lua
  ///
  /// In en, this message translates to:
  /// **'Not recognized Lua'**
  String get m3427d6812f;

  /// Не удалось включить правки через MCP. Проверьте, что установлен обновлённый MCP.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable edits via MCP. Check that the updated MCP is installed.'**
  String get ma2cd5e5b0a;

  /// Не удалось восстановить состояние после ошибки: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to restore state after error: {p0}'**
  String mcf4205d2e9(String p0);

  /// Не удалось загрузить перевод: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to load translation: {p0}'**
  String m4b1c83eb15(String p0);

  /// Не удалось закрыть PoB.
  ///
  /// In en, this message translates to:
  /// **'Could not close PoB.'**
  String get m6f37ba2ab7;

  /// Не удалось запустить PoB.
  ///
  /// In en, this message translates to:
  /// **'Could not start PoB.'**
  String get m46ed8403b7;

  /// Не удалось защитить каталог подключения MCP
  ///
  /// In en, this message translates to:
  /// **'Failed to protect connection directory MCP'**
  String get m6dc7d664a3;

  /// Не удалось открыть браузер: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to open browser: {p0}'**
  String m725605a944(String p0);

  /// Не удалось открыть или сохранить заметки.
  /// {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to open or save notes.\n{p0}'**
  String m189f5a7238(String p0);

  /// Не удалось открыть план прокачки
  ///
  /// In en, this message translates to:
  /// **'Could not open the leveling plan'**
  String get m58ddf479f1;

  /// Не удалось открыть последнюю сборку, проверяем копию восстановления: {p0}
  ///
  /// In en, this message translates to:
  /// **'Could not open the latest build, check the recovery copy: {p0}'**
  String mfc401e8783(String p0);

  /// Не удалось открыть страницу выпусков: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to open releases page: {p0}'**
  String mce8b7ad723(String p0);

  /// Не удалось показать подсветку: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to show highlight: {p0}'**
  String m0d58180884(String p0);

  /// Не удалось показать тепловую карту: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to show heatmap: {p0}'**
  String ma9bd749aa5(String p0);

  /// Не удалось получить SHA256SUMS
  ///
  /// In en, this message translates to:
  /// **'Failed to get SHA256SUMS'**
  String get mcb5613d7e6;

  /// Не удалось получить ответ сервера
  ///
  /// In en, this message translates to:
  /// **'Failed to get server response'**
  String get m57c6abe340;

  /// Не удалось получить папку через мост PoB: {p0}
  ///
  /// In en, this message translates to:
  /// **'Could not get the folder through the PoB bridge: {p0}'**
  String m4a86054c42(String p0);

  /// Не удалось получить подсказку: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to get hint: {p0}'**
  String mcd252d5275(String p0);

  /// Не удалось применить предмет
  ///
  /// In en, this message translates to:
  /// **'Failed to apply item'**
  String get m57d96c50f4;

  /// Не удалось проверить SHA-256 файла: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to check SHA-256 file: {p0}'**
  String m3ce1fbdad2(String p0);

  /// Не удалось проверить обновления: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates: {p0}'**
  String m4d1a8400d5(String p0);

  /// Не удалось прочитать изображения: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to read images: {p0}'**
  String mfdddf71553(String p0);

  /// Не удалось прочитать каталог: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to read directory: {p0}'**
  String mdace2a4a3b(String p0);

  /// Не удалось прочитать узел: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to read node: {p0}'**
  String mbefc941808(String p0);

  /// Не удалось сохранить группу
  ///
  /// In en, this message translates to:
  /// **'Failed to save group'**
  String get m409f34eb59;

  /// Не удалось сохранить масштаб.
  ///
  /// In en, this message translates to:
  /// **'Failed to save scale.'**
  String get mef9d01550d;

  /// Не удалось сохранить план прокачки
  ///
  /// In en, this message translates to:
  /// **'Could not save the leveling plan'**
  String get mdc2f51b827;

  /// Не удалось сохранить тему.
  ///
  /// In en, this message translates to:
  /// **'Failed to save topic.'**
  String get m92233abcc1;

  /// Не удалось сохранить черновик XML: {p0}
  ///
  /// In en, this message translates to:
  /// **'Failed to save draft XML: {p0}'**
  String m62f5b562c1(String p0);

  /// Не удалось удалить умение
  ///
  /// In en, this message translates to:
  /// **'Failed to remove skill'**
  String get m0dc255f974;

  /// Небезопасный адрес обновления
  ///
  /// In en, this message translates to:
  /// **'Insecure update address'**
  String get m45c78389e9;

  /// Неверная запись каталога Lua
  ///
  /// In en, this message translates to:
  /// **'Invalid directory entry Lua'**
  String get m7a4c30c971;

  /// Неверный диапазон продолжения загрузки
  ///
  /// In en, this message translates to:
  /// **'Invalid boot continuation range'**
  String get m4412eb3d42;

  /// Неверный источник файла выпуска
  ///
  /// In en, this message translates to:
  /// **'Invalid release file source'**
  String get m5426ce4a91;

  /// Неизвестная версия настроек
  ///
  /// In en, this message translates to:
  /// **'Unknown settings version'**
  String get m34f418bb26;

  /// Неизвестный режим сцены PoB: {p0}
  ///
  /// In en, this message translates to:
  /// **'Unknown PoB scene mode: {p0}'**
  String m88bb56b333(String p0);

  /// Неизвестный тип установки
  ///
  /// In en, this message translates to:
  /// **'Unknown installation type'**
  String get me6b70e080e;

  /// Неизвестный формат библиотеки сборок
  ///
  /// In en, this message translates to:
  /// **'Unknown assembly library format'**
  String get me90bfa5f82;

  /// Некорректная иконка Lua
  ///
  /// In en, this message translates to:
  /// **'Incorrect icon Lua'**
  String get mf3a3cbeee9;

  /// Некорректная команда редактора PoB II.
  ///
  /// In en, this message translates to:
  /// **'Incorrect editor command PoB II.'**
  String get me967307c68;

  /// Некорректная связь дерева Lua
  ///
  /// In en, this message translates to:
  /// **'Incorrect tree link Lua'**
  String get mf1703df170;

  /// Некорректная ссылка поиска
  ///
  /// In en, this message translates to:
  /// **'Incorrect search link'**
  String get m57e2535a94;

  /// Некорректная текстура готового дерева
  ///
  /// In en, this message translates to:
  /// **'Incorrect texture of the finished wood'**
  String get m3f7db06826;

  /// Некорректные координаты PoB
  ///
  /// In en, this message translates to:
  /// **'Incorrect PoB coordinates'**
  String get m571195d148;

  /// Некорректный идентификатор заметок
  ///
  /// In en, this message translates to:
  /// **'Incorrect note ID'**
  String get mec07f569e3;

  /// Некорректный идентификатор сборки
  ///
  /// In en, this message translates to:
  /// **'Incorrect assembly ID'**
  String get mc652a6b3a8;

  /// Некорректный ключ кеша дерева
  ///
  /// In en, this message translates to:
  /// **'Incorrect tree cache key'**
  String get m7021e46018;

  /// Некорректный план прокачки
  ///
  /// In en, this message translates to:
  /// **'Invalid leveling plan'**
  String get mac487ef90b;

  /// Некорректный путь к сборке PoB.
  ///
  /// In en, this message translates to:
  /// **'Incorrect path to PoB assembly.'**
  String get mbfa40c4fb1;

  /// Некорректный размер Lua runtime
  ///
  /// In en, this message translates to:
  /// **'Incorrect size Lua runtime'**
  String get m4e15785017;

  /// Некорректный размер файла
  ///
  /// In en, this message translates to:
  /// **'Incorrect file size'**
  String get m6ddcbfade2;

  /// Некорректный узел дерева Lua
  ///
  /// In en, this message translates to:
  /// **'Invalid tree node Lua'**
  String get m2469d9f2a8;

  /// Необязательно
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get mf6d959d4c7;

  /// Неоднозначная контрольная сумма Lua runtime
  ///
  /// In en, this message translates to:
  /// **'Ambiguous checksum Lua runtime'**
  String get m5f5263f78b;

  /// Неожиданный источник Lua runtime
  ///
  /// In en, this message translates to:
  /// **'Unexpected source Lua runtime'**
  String get m14889e0664;

  /// Неподдерживаемый формат тега выпуска
  ///
  /// In en, this message translates to:
  /// **'Unsupported release tag format'**
  String get mab1d20e880;

  /// Неполная команда отрисовки PoB
  ///
  /// In en, this message translates to:
  /// **'Incomplete PoB render command'**
  String get m7b3c2887b7;

  /// Нет Lua runtime для этой архитектуры
  ///
  /// In en, this message translates to:
  /// **'No Lua runtime for this architecture'**
  String get m6f381f6aed;

  /// Нет единственной контрольной суммы пакета
  ///
  /// In en, this message translates to:
  /// **'No single packet checksum'**
  String get ma76f928c09;

  /// Нет контрольной суммы Lua runtime
  ///
  /// In en, this message translates to:
  /// **'No checksum Lua runtime'**
  String get mb71873c826;

  /// Нет ответа MCP. Сессия закрыта; повторно импортируйте XML.
  ///
  /// In en, this message translates to:
  /// **'No answer MCP. The session is closed; re-import XML.'**
  String get m0497e1e404;

  /// Нет перевода — показываем оригинал
  ///
  /// In en, this message translates to:
  /// **'Original text is shown when a translation is unavailable'**
  String get m323494c6da;

  /// Ничего не найдено
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get m480fae1c4b;

  /// Новая группа
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get mc9fd9fc0e5;

  /// Новая группа умений
  ///
  /// In en, this message translates to:
  /// **'New skill group'**
  String get mbfea4c6fd4;

  /// Новая сборка
  ///
  /// In en, this message translates to:
  /// **'New build'**
  String get m282cf4ee16;

  /// Новое сочетание
  ///
  /// In en, this message translates to:
  /// **'New combination'**
  String get ma76e43569d;

  /// Нужна стабильная версия вида 0.2.0
  ///
  /// In en, this message translates to:
  /// **'We need a stable version like 0.2.0'**
  String get md72a4c2675;

  /// Оберег I
  ///
  /// In en, this message translates to:
  /// **'Amulet I'**
  String get m83e9fd7c8a;

  /// Оберег II
  ///
  /// In en, this message translates to:
  /// **'Amulet II'**
  String get mbe485a0526;

  /// Оберег III
  ///
  /// In en, this message translates to:
  /// **'Amulet III'**
  String get m4a1afe7893;

  /// Обновите MCP в разделе «Компоненты».
  ///
  /// In en, this message translates to:
  /// **'Update MCP in the Components section.'**
  String get md65eeeeaab;

  /// Обновите MCP для каталога камней и совместимости
  ///
  /// In en, this message translates to:
  /// **'Update MCP for stone catalog and compatibility'**
  String get m616c984fe4;

  /// Обновите MCP для описаний камней
  ///
  /// In en, this message translates to:
  /// **'Update MCP for gem descriptions'**
  String get m9488a3217c;

  /// Обновите MCP для оригинальных иконок и совместимости
  ///
  /// In en, this message translates to:
  /// **'Update MCP for original icons and compatibility'**
  String get m648c9e0082;

  /// Обновите MCP для оригинальных иконок камней
  ///
  /// In en, this message translates to:
  /// **'Update MCP for original stone icons'**
  String get md423f03f4f;

  /// Обновите MCP для поиска на рынке
  ///
  /// In en, this message translates to:
  /// **'Update MCP for market search'**
  String get m48626fbe0c;

  /// Обновите MCP для редактирования группы
  ///
  /// In en, this message translates to:
  /// **'Update MCP to edit group'**
  String get m2788a17cac;

  /// Обновите MCP для редактора экипировки
  ///
  /// In en, this message translates to:
  /// **'Update MCP for the equipment editor'**
  String get mfa7a72dbc1;

  /// Обновите MCP для сравнения предметов
  ///
  /// In en, this message translates to:
  /// **'Update MCP item comparison'**
  String get md708edb156;

  /// Обновите MCP для удаления умения
  ///
  /// In en, this message translates to:
  /// **'Update MCP to remove skill'**
  String get m124cd4a205;

  /// Обновить
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get m603e460bf5;

  /// Обновить список сборок
  ///
  /// In en, this message translates to:
  /// **'Update build list'**
  String get m3d7df93803;

  /// Обновление PoB II
  ///
  /// In en, this message translates to:
  /// **'Update PoB II'**
  String get mb2712dc98b;

  /// Обновление загружено и проверено. Перед перезапуском сборка и XML будут сохранены.
  ///
  /// In en, this message translates to:
  /// **'The update has been downloaded and verified. The build and XML will be saved before restarting.'**
  String get m452a863748;

  /// Обновление не запущено: {p0}
  ///
  /// In en, this message translates to:
  /// **'Update not started: {p0}'**
  String m425b17d88a(String p0);

  /// Обновления приложения
  ///
  /// In en, this message translates to:
  /// **'Application updates'**
  String get m1eb91e3a52;

  /// Обувь
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get m9e0611bf9b;

  /// Общая карта урона и защиты. Для списка выберите отдельный показатель.
  ///
  /// In en, this message translates to:
  /// **'General damage and defense map. For the list, select an individual metric.'**
  String get mc006d459af;

  /// Огонь
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get m8cb7d50be2;

  /// Ожидает расчёта
  ///
  /// In en, this message translates to:
  /// **'Awaiting calculation'**
  String get m480c4531b2;

  /// Ожидалось описание предмета из Lua
  ///
  /// In en, this message translates to:
  /// **'Expected item description from Lua'**
  String get mdda947ef31;

  /// Ожидался XML сборки Path of Building для PoE 2.
  ///
  /// In en, this message translates to:
  /// **'Expected XML Path of Building builds for PoE 2.'**
  String get mc3bde350c7;

  /// Ожидался отчёт исходного Lua
  ///
  /// In en, this message translates to:
  /// **'Expected report from original Lua'**
  String get mbb08ba5f85;

  /// Ожидался торговый каталог PoB
  ///
  /// In en, this message translates to:
  /// **'PoB trade catalog was expected'**
  String get mab5f9b4d06;

  /// Операций пока нет
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get mb3f794d1cf;

  /// Описание выпуска отсутствует
  ///
  /// In en, this message translates to:
  /// **'No release description'**
  String get m47cd7c0de1;

  /// Оружие
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get m0736fbba4d;

  /// Оружие I
  ///
  /// In en, this message translates to:
  /// **'Weapon I'**
  String get m5bf15d8d42;

  /// Оружие II
  ///
  /// In en, this message translates to:
  /// **'Weapon II'**
  String get m750b8fab71;

  /// Основное умение
  ///
  /// In en, this message translates to:
  /// **'Main skill'**
  String get md579b36c2e;

  /// От 1 до 100
  ///
  /// In en, this message translates to:
  /// **'From 1 to 100'**
  String get m7fc991d63f;

  /// От 1 до 200 очков
  ///
  /// In en, this message translates to:
  /// **'From 1 to 200 points'**
  String get m957e42d5d4;

  /// Ответ превышает допустимый размер
  ///
  /// In en, this message translates to:
  /// **'Response exceeds allowed size'**
  String get mcdc8c3d8af;

  /// Отдалить
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get m8e6a41ecd0;

  /// Открыть
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mea1f408246;

  /// Открыть XML
  ///
  /// In en, this message translates to:
  /// **'Open XML'**
  String get mdccda63f51;

  /// Открыть XML из PoB
  ///
  /// In en, this message translates to:
  /// **'Open XML from PoB'**
  String get m38ec738ed2;

  /// Открыть и рассчитать
  ///
  /// In en, this message translates to:
  /// **'Open and calculate'**
  String get m589c35aaa6;

  /// Открыть или создать сборку
  ///
  /// In en, this message translates to:
  /// **'Open or create a build'**
  String get m5ba3edc059;

  /// Открыть поиск
  ///
  /// In en, this message translates to:
  /// **'Open search'**
  String get mcfc22a4611;

  /// Отмена
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get m8fbe9b75cb;

  /// Отменить действие
  ///
  /// In en, this message translates to:
  /// **'Cancel action'**
  String get mb9b86803ad;

  /// Оформление
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get m1731619efa;

  /// Очистить поиск
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get m6e1f7baa47;

  /// Очки
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get m6cc0ad9655;

  /// Очки: {p0}
  ///
  /// In en, this message translates to:
  /// **'Points: {p0}'**
  String m07817efe16(String p0);

  /// Ошибка: {p0}
  ///
  /// In en, this message translates to:
  /// **'Error: {p0}'**
  String mefe256475e(String p0);

  /// Пакет больше ожидаемого размера
  ///
  /// In en, this message translates to:
  /// **'Packet larger than expected size'**
  String get m7352f28e7e;

  /// Папка сборок
  ///
  /// In en, this message translates to:
  /// **'Builds folder'**
  String get m8ce1a3f4ee;

  /// Папка сборок PoB изменилась.
  ///
  /// In en, this message translates to:
  /// **'The PoB build folder has changed.'**
  String get mcaef3568a0;

  /// Папка сборок PoB недоступна: {p0}
  ///
  /// In en, this message translates to:
  /// **'PoB build folder unavailable: {p0}'**
  String md9960887f8(String p0);

  /// Папка сборок из настроек PoB недоступна.
  ///
  /// In en, this message translates to:
  /// **'The builds folder set in PoB is unavailable.'**
  String get med31458051;

  /// Параметры
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get m75160b86a8;

  /// Пассивные
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get m1971cfb84c;

  /// Перевод больше ожидаемого размера
  ///
  /// In en, this message translates to:
  /// **'Transfer is larger than expected size'**
  String get m8188a57c48;

  /// Перевод: HTTP {p0}
  ///
  /// In en, this message translates to:
  /// **'Translation: HTTP {p0}'**
  String m46c64e6832(String p0);

  /// Передвижение
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get md3c6b76bfd;

  /// Перезапуск — только по вашей команде
  ///
  /// In en, this message translates to:
  /// **'Restart - only at your command'**
  String get mcaceac98e9;

  /// Перезапустите PoB через Wine и нажмите «Проверить связь».
  ///
  /// In en, this message translates to:
  /// **'Restart PoB via Wine and click \"Test Ping\".'**
  String get mfd5aca9906;

  /// Перезапустить PoB
  ///
  /// In en, this message translates to:
  /// **'Restart PoB'**
  String get m46fe82b8cc;

  /// Перезапустить и обновить
  ///
  /// In en, this message translates to:
  /// **'Restart and update'**
  String get m79a3312d3b;

  /// Перенос в список добавляет поддержку, обратно — убирает
  ///
  /// In en, this message translates to:
  /// **'Moving to the list adds support, moving back removes it'**
  String get m9af13a3399;

  /// Пересчитать в Lua
  ///
  /// In en, this message translates to:
  /// **'Convert to Lua'**
  String get m79ab5f1286;

  /// Перетащите камень сюда или нажмите на иконку для настройки
  ///
  /// In en, this message translates to:
  /// **'Drag the stone here or click on the icon to configure'**
  String get m24ad4cc4a3;

  /// Перчатки
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get m98aa5e2776;

  /// Плавные анимации
  ///
  /// In en, this message translates to:
  /// **'Smooth animations'**
  String get m95121a4cc0;

  /// План
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get m610d4c2115;

  /// План прокачки
  ///
  /// In en, this message translates to:
  /// **'Leveling plan'**
  String get m48d5bea474;

  /// Планы, предметы, варианты развития…
  ///
  /// In en, this message translates to:
  /// **'Plans, items, development options...'**
  String get m1474fac529;

  /// По умолчанию
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get mfd0560ebbf;

  /// Повторить
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get m5189135a61;

  /// Повторить действие
  ///
  /// In en, this message translates to:
  /// **'Repeat action'**
  String get madb0c613d6;

  /// Повторить загрузку
  ///
  /// In en, this message translates to:
  /// **'Retry download'**
  String get m298e41327f;

  /// Повторить сохранение
  ///
  /// In en, this message translates to:
  /// **'Save again'**
  String get m3c320d7fe3;

  /// Подавление урона чар
  ///
  /// In en, this message translates to:
  /// **'Spell Suppression Chance'**
  String get mbcc0fdbe14;

  /// Подготовить PoB II
  ///
  /// In en, this message translates to:
  /// **'Set up PoB II'**
  String get mb66419affe;

  /// Подготовка PoB II
  ///
  /// In en, this message translates to:
  /// **'Set up PoB II'**
  String get mc1b2f9e3a6;

  /// Поддерживаются Windows x64, Linux x64 и macOS arm64
  ///
  /// In en, this message translates to:
  /// **'Windows x64, Linux x64 and macOS arm64 supported'**
  String get m52d7142d18;

  /// Поддержки общие для умений этого слота
  ///
  /// In en, this message translates to:
  /// **'Skills in this equipment slot share supports'**
  String get mc2fd54cfce;

  /// Подключена стандартная папка PoB
  ///
  /// In en, this message translates to:
  /// **'Default PoB folder connected'**
  String get m54ab473017;

  /// Подключите Lua
  ///
  /// In en, this message translates to:
  /// **'Connect Lua'**
  String get m67f5d8880e;

  /// Подключите мост заново и перезапустите PoB.
  ///
  /// In en, this message translates to:
  /// **'Reconnect the bridge and restart PoB.'**
  String get m0d8b14b475;

  /// Подключить Lua
  ///
  /// In en, this message translates to:
  /// **'Connect Lua'**
  String get m538d913ee0;

  /// Подключить мост
  ///
  /// In en, this message translates to:
  /// **'Connect bridge'**
  String get m80cc1bdb9b;

  /// Подключить папку сборок
  ///
  /// In en, this message translates to:
  /// **'Connect builds folder'**
  String get m929d292c0e;

  /// Подходящие поддержки
  ///
  /// In en, this message translates to:
  /// **'Matching supports'**
  String get m5f5155bb1f;

  /// Позже
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get m7996f71149;

  /// Поиск
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get m180f58ab97;

  /// Поиск на рынке
  ///
  /// In en, this message translates to:
  /// **'Market search'**
  String get m885946a42e;

  /// Поиск откроется на официальном сайте
  ///
  /// In en, this message translates to:
  /// **'The search will open on the official website'**
  String get md133559e02;

  /// Показатели
  ///
  /// In en, this message translates to:
  /// **'Indicators'**
  String get mbf3c9df646;

  /// Показатели не изменятся
  ///
  /// In en, this message translates to:
  /// **'Indicators will not change'**
  String get mc7fc04e5df;

  /// Показатели текущего состояния сборки
  ///
  /// In en, this message translates to:
  /// **'Indicators of the current build state'**
  String get m53788df38a;

  /// Показатель
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get mfdf0487fc4;

  /// Показать всё дерево
  ///
  /// In en, this message translates to:
  /// **'Show whole tree'**
  String get m21a6bb1840;

  /// Полный DPS
  ///
  /// In en, this message translates to:
  /// **'Full DPS'**
  String get m233d77b731;

  /// Получаемый урон молнией
  ///
  /// In en, this message translates to:
  /// **'Taken Lightning dmg'**
  String get m56f7dfa459;

  /// Получаемый урон огнём
  ///
  /// In en, this message translates to:
  /// **'Taken Fire dmg'**
  String get m767efb71d3;

  /// Получаемый урон хаосом
  ///
  /// In en, this message translates to:
  /// **'Taken Chaos dmg'**
  String get mfac34bf889;

  /// Получаемый урон холодом
  ///
  /// In en, this message translates to:
  /// **'Taken Cold dmg'**
  String get m22ad5a098c;

  /// Получаемый физический урон
  ///
  /// In en, this message translates to:
  /// **'Taken Phys dmg'**
  String get m2ffaee13bd;

  /// Пользовательские модификаторы
  ///
  /// In en, this message translates to:
  /// **'Custom modifiers'**
  String get m8c0ef0f511;

  /// Попробуйте пересчитать сборку.
  ///
  /// In en, this message translates to:
  /// **'Try recalculating the assembly.'**
  String get md90da4d82c;

  /// Последняя: {p0}
  ///
  /// In en, this message translates to:
  /// **'Last: {p0}'**
  String m032a431609(String p0);

  /// Постепенный DPS
  ///
  /// In en, this message translates to:
  /// **'DoT DPS'**
  String get m0f80007ec0;

  /// Потяните, чтобы изменить ширину панели
  ///
  /// In en, this message translates to:
  /// **'Pull to change panel width'**
  String get mb4fd967719;

  /// Похищение здоровья
  ///
  /// In en, this message translates to:
  /// **'Life leech'**
  String get ma01259ad57;

  /// Похищение маны
  ///
  /// In en, this message translates to:
  /// **'Mana leech'**
  String get m3e7c000702;

  /// Похищение энергощита
  ///
  /// In en, this message translates to:
  /// **'Energy Shield leech'**
  String get m6ec2f2eff4;

  /// Пояс
  ///
  /// In en, this message translates to:
  /// **'Belt'**
  String get m51d2753a44;

  /// Правки PoB II сохранены отдельно: {p0}
  ///
  /// In en, this message translates to:
  /// **'PoB II edits saved separately: {p0}'**
  String mdbe17974dd(String p0);

  /// Правки через MCP
  ///
  /// In en, this message translates to:
  /// **'Edits via MCP'**
  String get m50c39b8e33;

  /// Превышено время выполнения {p0}
  ///
  /// In en, this message translates to:
  /// **'Runtime exceeded {p0}'**
  String m1a132e5834(String p0);

  /// Предмет из сборки
  ///
  /// In en, this message translates to:
  /// **'Assembly item'**
  String get m7ba6aa7f66;

  /// Предмет не подходит для этого слота
  ///
  /// In en, this message translates to:
  /// **'Item is not suitable for this slot'**
  String get m9ce35b77ce;

  /// Предметы
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get m10e4fefa12;

  /// Предупреждения Lua
  ///
  /// In en, this message translates to:
  /// **'Warnings Lua'**
  String get m3c2b5cfe97;

  /// Предупреждения · {p0}
  ///
  /// In en, this message translates to:
  /// **'Warnings · {p0}'**
  String m39215290bb(String p0);

  /// Предупреждения: {p0}
  ///
  /// In en, this message translates to:
  /// **'Warnings: {p0}'**
  String m28ba7365b1(String p0);

  /// Предыдущая пара восстановлена и проверена через Lua
  ///
  /// In en, this message translates to:
  /// **'Previous pair restored and verified through Lua'**
  String get mb45f78d483;

  /// Предыдущей полной пары компонентов пока нет
  ///
  /// In en, this message translates to:
  /// **'There is no previous complete pair of components yet'**
  String get mf969e13b83;

  /// Предыдущие результаты · пересчёт Lua
  ///
  /// In en, this message translates to:
  /// **'Previous results · recalculation Lua'**
  String get mec5dbc31fc;

  /// Предыдущий расчёт
  ///
  /// In en, this message translates to:
  /// **'Previous calculation'**
  String get mc0aa51ea34;

  /// Приблизить
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mbfb85a0178;

  /// Приложение остаётся открытым, чтобы сохранить данные: {p0}
  ///
  /// In en, this message translates to:
  /// **'The application remains open to save data: {p0}'**
  String md25ca8974f(String p0);

  /// Применить
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get me15f960d93;

  /// Применить и рассчитать
  ///
  /// In en, this message translates to:
  /// **'Apply and calculate'**
  String get m84028563e4;

  /// Примерка
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get mae2ea1c701;

  /// Приостановить
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get m6aab9e2cb4;

  /// Приспешник · {p0}
  ///
  /// In en, this message translates to:
  /// **'Minion {p0}'**
  String m0680c9d188(String p0);

  /// Проверить
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get me4424a6df6;

  /// Проверить обновления
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get m93b08f7b14;

  /// Проверить предмет
  ///
  /// In en, this message translates to:
  /// **'Check item'**
  String get me269e51359;

  /// Проверить связь
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get m87cb1172f2;

  /// Проверить совместимость
  ///
  /// In en, this message translates to:
  /// **'Check compatibility'**
  String get mfa4af9bbe7;

  /// Проверка выпуска: HTTP {p0}
  ///
  /// In en, this message translates to:
  /// **'Release check: HTTP {p0}'**
  String mfeb5830ec9(String p0);

  /// Проверка выпусков завершена
  ///
  /// In en, this message translates to:
  /// **'Verification of releases completed'**
  String get m25ee4bf0ec;

  /// Проверка ещё не выполнялась
  ///
  /// In en, this message translates to:
  /// **'The check has not been performed yet'**
  String get m3e4c852ed2;

  /// Проверка пакета перед установкой не пройдена
  ///
  /// In en, this message translates to:
  /// **'Package check before installation failed'**
  String get m6f4c708fbf;

  /// Проверка совместимости: запуск исходного Lua…
  ///
  /// In en, this message translates to:
  /// **'Compatibility check: running original Lua...'**
  String get m9353cfd5f6;

  /// Проверьте сеть и лимит запросов.
  ///
  /// In en, this message translates to:
  /// **'Check your network and request limit.'**
  String get md8164e1acb;

  /// Проверьте текст, чтобы увидеть описание и совместимость
  ///
  /// In en, this message translates to:
  /// **'Check text to see description and compatibility'**
  String get m21d9ad659d;

  /// Проверяем выпуски…
  ///
  /// In en, this message translates to:
  /// **'Checking the releases...'**
  String get m1ea3791d9d;

  /// Проверяем…
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get m62ed32eb22;

  /// Работают в окне приложения. Нажмите на сочетание, чтобы изменить его.
  ///
  /// In en, this message translates to:
  /// **'Work in the application window. Click on a combination to change it.'**
  String get m913b373c85;

  /// Рабочая сборка сохранена; не удалось восстановить Lua: {p0}
  ///
  /// In en, this message translates to:
  /// **'Working assembly saved; failed to restore Lua: {p0}'**
  String m0964e41783(String p0);

  /// Радиус освещения
  ///
  /// In en, this message translates to:
  /// **'Light Radius'**
  String get m9aaa2d503d;

  /// Развернуть панель
  ///
  /// In en, this message translates to:
  /// **'Expand panel'**
  String get mf66e719066;

  /// Развернуть результаты
  ///
  /// In en, this message translates to:
  /// **'Expand results'**
  String get m44faae47f6;

  /// Размер или SHA-256 обновления не совпал
  ///
  /// In en, this message translates to:
  /// **'Size or SHA-256 update did not match'**
  String get m8c8ec94283;

  /// Размер противника
  ///
  /// In en, this message translates to:
  /// **'Enemy size'**
  String get meabbc96d71;

  /// Разрешить правки через MCP
  ///
  /// In en, this message translates to:
  /// **'Allow edits via MCP'**
  String get m13601ffe54;

  /// Расстояние до узла
  ///
  /// In en, this message translates to:
  /// **'Distance to node'**
  String get mde6527a5fe;

  /// Рассчитано в Lua PoB
  ///
  /// In en, this message translates to:
  /// **'Calculated in Lua PoB'**
  String get m7846ddb858;

  /// Расчёт Lua · {p0}%
  ///
  /// In en, this message translates to:
  /// **'Calculation Lua · {p0}%'**
  String m33a38de9ff(String p0);

  /// Расчёты
  ///
  /// In en, this message translates to:
  /// **'Calculations'**
  String get m9b9370223c;

  /// Расчёт…
  ///
  /// In en, this message translates to:
  /// **'Calculation…'**
  String get m1e135b51f1;

  /// Регенерация здоровья
  ///
  /// In en, this message translates to:
  /// **'Health regeneration'**
  String get m8d7bd9deb6;

  /// Регенерация маны
  ///
  /// In en, this message translates to:
  /// **'Mana regeneration'**
  String get m40c71efeca;

  /// Редактировать группу
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get mcd085a0260;

  /// Редактор PoB II не выполнил команду.
  ///
  /// In en, this message translates to:
  /// **'Editor PoB II did not complete the command.'**
  String get mb5f6678c99;

  /// Редактор группы умений
  ///
  /// In en, this message translates to:
  /// **'Skill group editor'**
  String get m11dc0e7d04;

  /// Редактор поддерживает одно активное умение в группе
  ///
  /// In en, this message translates to:
  /// **'The editor supports one active skill per group'**
  String get mf35834d767;

  /// Редкость найденных предметов
  ///
  /// In en, this message translates to:
  /// **'Rarity of Items found'**
  String get m3826292e79;

  /// Ресурсы
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get meba267d9f8;

  /// Руническая защита
  ///
  /// In en, this message translates to:
  /// **'Runic Ward'**
  String get ma735c975e0;

  /// Руны
  ///
  /// In en, this message translates to:
  /// **'Runes'**
  String get m9c7a204d54;

  /// Самоцветы
  ///
  /// In en, this message translates to:
  /// **'Jewels'**
  String get m49db3482db;

  /// Сборка
  ///
  /// In en, this message translates to:
  /// **'Assembly'**
  String get m8c39bb691b;

  /// Сборка PoB больше недоступна. Обновите список сборок.
  ///
  /// In en, this message translates to:
  /// **'PoB build is no longer available. Update the build list.'**
  String get m15d7545f05;

  /// Сборка изменена в PoB. Правки PoB II сохранены отдельно: {p0}
  ///
  /// In en, this message translates to:
  /// **'The build changed in PoB. PoB II edits saved separately: {p0}'**
  String mee1bd6d18c(String p0);

  /// Сборка изменилась на диске. Дождитесь обновления из PoB.
  ///
  /// In en, this message translates to:
  /// **'The build changed on disk. Wait for the update from PoB.'**
  String get m7806bb3683;

  /// Сборка изменится после нажатия «Применить»
  ///
  /// In en, this message translates to:
  /// **'The build will change after clicking \"Apply\"'**
  String get m544bec7909;

  /// Сборка не найдена
  ///
  /// In en, this message translates to:
  /// **'Assembly not found'**
  String get m5c8bb47697;

  /// Сборка обновлена из Path of Building
  ///
  /// In en, this message translates to:
  /// **'Build updated from Path of Building'**
  String get ma8f340d211;

  /// Сборка рассчитана исходным Lua
  ///
  /// In en, this message translates to:
  /// **'Assembly calculated by original Lua'**
  String get mc27d8aad03;

  /// Сборка с таким именем уже существует.
  ///
  /// In en, this message translates to:
  /// **'An assembly with the same name already exists.'**
  String get med0b7c459c;

  /// Сборка сохранена в библиотеке, но копия восстановления недоступна: {p0}
  ///
  /// In en, this message translates to:
  /// **'The build is saved in the library, but the recovery copy is not available: {p0}'**
  String mae943799b7(String p0);

  /// Сборка удалена
  ///
  /// In en, this message translates to:
  /// **'Build deleted'**
  String get m187a481844;

  /// Сборки из подключённой папки уже доступны в разделе «Мои сборки».
  ///
  /// In en, this message translates to:
  /// **'Builds in the connected folder are available in My Builds.'**
  String get m9027890a7b;

  /// Сбросить
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get m407f871778;

  /// Сбросить сочетания
  ///
  /// In en, this message translates to:
  /// **'Reset combinations'**
  String get mde7b2b9b0d;

  /// Свернуть панель
  ///
  /// In en, this message translates to:
  /// **'Collapse panel'**
  String get m87b737d42c;

  /// Свернуть результаты
  ///
  /// In en, this message translates to:
  /// **'Collapse results'**
  String get mdbd753f08d;

  /// Светлая
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mf0cd3a6033;

  /// Свои…
  ///
  /// In en, this message translates to:
  /// **'Own...'**
  String get ma50190234a;

  /// Связь с PoB подтверждена
  ///
  /// In en, this message translates to:
  /// **'PoB connection confirmed'**
  String get m02578f2b24;

  /// Связь с PoB подтверждена. Откройте сборку для импорта.
  ///
  /// In en, this message translates to:
  /// **'PoB connection verified. Open a build to import it.'**
  String get mfc68d94f44;

  /// Сдвинуть влево
  ///
  /// In en, this message translates to:
  /// **'Move left'**
  String get m7434b2e81b;

  /// Сдвинуть вправо
  ///
  /// In en, this message translates to:
  /// **'Move right'**
  String get m63a2484f1c;

  /// Сессия закрыта
  ///
  /// In en, this message translates to:
  /// **'Session closed'**
  String get m32bb1c680f;

  /// Сила
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get m69c1590a47;

  /// Системное уменьшение движения имеет приоритет
  ///
  /// In en, this message translates to:
  /// **'System motion reduction takes priority'**
  String get m9ea191ae12;

  /// Скачать Path of Building
  ///
  /// In en, this message translates to:
  /// **'Download Path of Building'**
  String get me7d43ecc6d;

  /// Скачать PoB MCP
  ///
  /// In en, this message translates to:
  /// **'Download PoB MCP'**
  String get m0c90d97433;

  /// Скачать обновление
  ///
  /// In en, this message translates to:
  /// **'Download update'**
  String get m0a8113a0b9;

  /// Скопировать
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get mf02956c165;

  /// Скопировать XML
  ///
  /// In en, this message translates to:
  /// **'Copy XML'**
  String get m332899f398;

  /// Скопировать команду подключения Codex
  ///
  /// In en, this message translates to:
  /// **'Copy Codex connection command'**
  String get m99e87c373f;

  /// Скопировать ссылку
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get m8d81013698;

  /// Скопируйте предмет из игры или PoB
  ///
  /// In en, this message translates to:
  /// **'Copy an item from the game or PoB'**
  String get m052e3a8cc9;

  /// Скорость
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get m70e98e3214;

  /// Скорость атак и чар
  ///
  /// In en, this message translates to:
  /// **'Attack/Cast Speed'**
  String get m43d758cbe5;

  /// Скорость передвижения
  ///
  /// In en, this message translates to:
  /// **'Move speed'**
  String get mf99463341e;

  /// Слишком большая иконка
  ///
  /// In en, this message translates to:
  /// **'Icon is too big'**
  String get m09b17c9d35;

  /// Слишком много перенаправлений
  ///
  /// In en, this message translates to:
  /// **'Too many redirects'**
  String get m126aa994ee;

  /// Сначала получите актуальный отчёт сборки через pob_check_build.
  ///
  /// In en, this message translates to:
  /// **'First get the latest build report via pob_check_build.'**
  String get m70a5cadc50;

  /// Сначала уберите камни поддержки
  ///
  /// In en, this message translates to:
  /// **'Remove support stones first'**
  String get m59b50cc146;

  /// Сначала установите оба компонента
  ///
  /// In en, this message translates to:
  /// **'Install both components first'**
  String get ma386719073;

  /// Снять
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get md4b51f7a04;

  /// Собственные свойства
  ///
  /// In en, this message translates to:
  /// **'Own properties'**
  String get mf3f1d96087;

  /// Соединение с Lua прервано
  ///
  /// In en, this message translates to:
  /// **'Connection to Lua lost'**
  String get m9071a1a6f4;

  /// Создайте персонажа или откройте XML из PoB. Все показатели рассчитает Lua.
  ///
  /// In en, this message translates to:
  /// **'Create a character or unlock XML from PoB. All indicators will be calculated by Lua.'**
  String get m7ab8e7349a;

  /// Создайте персонажа или откройте XML из PoB. Успешные расчёты сохраняются автоматически.
  ///
  /// In en, this message translates to:
  /// **'Create a character or unlock XML from PoB. Successful calculations are saved automatically.'**
  String get mb724f3e4cd;

  /// Создать копию
  ///
  /// In en, this message translates to:
  /// **'Create a copy'**
  String get mc42ccf5a81;

  /// Создать сборку
  ///
  /// In en, this message translates to:
  /// **'Create assembly'**
  String get md79906423b;

  /// Сопротивления
  ///
  /// In en, this message translates to:
  /// **'Resistances'**
  String get m62bb423bd3;

  /// Состав группы изменился; повторите перенос
  ///
  /// In en, this message translates to:
  /// **'The composition of the group has changed; repeat the transfer'**
  String get mcd4e66880d;

  /// Сохранение…
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get mbd97450c85;

  /// Сохранено
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get m2fe8f2fd72;

  /// Сохранить
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mb4d30cae52;

  /// Сохранить и рассчитать
  ///
  /// In en, this message translates to:
  /// **'Save and calculate'**
  String get m9af7509a85;

  /// Сохранить этап
  ///
  /// In en, this message translates to:
  /// **'Save step'**
  String get mfca5aabf85;

  /// Сочетание уже используется: {p0}
  ///
  /// In en, this message translates to:
  /// **'Combination already in use: {p0}'**
  String md7dfb40adb(String p0);

  /// Средний удар
  ///
  /// In en, this message translates to:
  /// **'Average Hit'**
  String get mc4268e6843;

  /// Средний урон
  ///
  /// In en, this message translates to:
  /// **'Average damage'**
  String get ma775dcaa51;

  /// Стабильных выпусков пока нет
  ///
  /// In en, this message translates to:
  /// **'No stable releases yet'**
  String get m91d6208508;

  /// Стало
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get md3ae3e1986;

  /// Стандартная папка PoB не найдена. Выберите папку вручную.
  ///
  /// In en, this message translates to:
  /// **'The default PoB folder was not found. Choose a folder manually.'**
  String get mabdae6b126;

  /// Страница выпусков
  ///
  /// In en, this message translates to:
  /// **'Issues page'**
  String get mf7eaffec2f;

  /// Суммарные свойства
  ///
  /// In en, this message translates to:
  /// **'Summary properties'**
  String get m4ef88e033d;

  /// Суммарный DPS
  ///
  /// In en, this message translates to:
  /// **'Combined DPS'**
  String get m98b6085914;

  /// Текст предмета
  ///
  /// In en, this message translates to:
  /// **'Item text'**
  String get mcda85a1ad9;

  /// Тема
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get m682f961a07;

  /// Тип противника
  ///
  /// In en, this message translates to:
  /// **'Enemy type'**
  String get m7242065c34;

  /// Тип условия пока не поддерживается
  ///
  /// In en, this message translates to:
  /// **'Condition type is not yet supported'**
  String get m0472e6790c;

  /// Только в сети
  ///
  /// In en, this message translates to:
  /// **'Online only'**
  String get m0ba4c8c62f;

  /// Тёмная
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get m1eecfcaa7b;

  /// У перенаправления нет адреса
  ///
  /// In en, this message translates to:
  /// **'Redirect has no address'**
  String get m2ec842e2f5;

  /// Убрать
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get m07cb650874;

  /// Убрать камень
  ///
  /// In en, this message translates to:
  /// **'Remove gem'**
  String get m94fde688e0;

  /// Убрать сочетание
  ///
  /// In en, this message translates to:
  /// **'Remove combination'**
  String get mcfa3d536f8;

  /// Увеличить интерфейс
  ///
  /// In en, this message translates to:
  /// **'Enlarge interface'**
  String get mcacf1f7fd0;

  /// Удалить
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mbe99b13612;

  /// Удалить сборку
  ///
  /// In en, this message translates to:
  /// **'Delete build'**
  String get m9ba95f357c;

  /// Удалить сборку?
  ///
  /// In en, this message translates to:
  /// **'Delete this build?'**
  String get mb3157cbf2b;

  /// Удалить умение
  ///
  /// In en, this message translates to:
  /// **'Remove skill'**
  String get m1c89558239;

  /// Удалить этап
  ///
  /// In en, this message translates to:
  /// **'Delete step'**
  String get md9dc2e9ec2;

  /// Уже выполняется установка
  ///
  /// In en, this message translates to:
  /// **'Installation already in progress'**
  String get m97ac4c501c;

  /// Уже открыта другая установка PoB. Подключите её в разделе «Компоненты».
  ///
  /// In en, this message translates to:
  /// **'Another PoB installation is already open. Connect it in Components.'**
  String get m2748676635;

  /// Узел
  ///
  /// In en, this message translates to:
  /// **'Node'**
  String get me77a383ee5;

  /// Узел не изменит показатели.
  ///
  /// In en, this message translates to:
  /// **'No changes.'**
  String get m8cf5c33b30;

  /// Узлы
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get mf3a46c2f2b;

  /// Узлы без изменений
  ///
  /// In en, this message translates to:
  /// **'No node changes'**
  String get m66e6ee7733;

  /// Укажите папку PoB вручную или попробуйте найти её по стандартному пути.
  ///
  /// In en, this message translates to:
  /// **'Choose the PoB folder manually or look in the default location.'**
  String get mb68ab7d79e;

  /// Укажите число от 1 до 200
  ///
  /// In en, this message translates to:
  /// **'Specify a number from 1 to 200'**
  String get mdba310a980;

  /// Уклонение
  ///
  /// In en, this message translates to:
  /// **'Evasion'**
  String get mdf00fd3d66;

  /// Умение не выбрано
  ///
  /// In en, this message translates to:
  /// **'Skill not selected'**
  String get m1a92bc6899;

  /// Умения
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get ma0c169b941;

  /// Умения ещё не добавлены
  ///
  /// In en, this message translates to:
  /// **'Skills have not been added yet'**
  String get m8af375dfe7;

  /// Уменьшить интерфейс
  ///
  /// In en, this message translates to:
  /// **'Make the interface smaller'**
  String get m7eac5d04d3;

  /// Уровень
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get m7f67af3d6c;

  /// Уровень {p0}
  ///
  /// In en, this message translates to:
  /// **'Level {p0}'**
  String m7ae0591157(String p0);

  /// Уровень {p0} · качество {p1} %
  ///
  /// In en, this message translates to:
  /// **'Level {p0} · quality {p1} %'**
  String m88f6fabbe9(String p0, String p1);

  /// Уровень и качество должны быть целыми числами
  ///
  /// In en, this message translates to:
  /// **'Level and quality must be integers'**
  String get mbb0ceac2d1;

  /// Уровень противника
  ///
  /// In en, this message translates to:
  /// **'Enemy level'**
  String get mecb350422f;

  /// Урон
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get m5883e88858;

  /// Урон / защита
  ///
  /// In en, this message translates to:
  /// **'Offence/Defence'**
  String get m9c6708a566;

  /// Условия
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get m908b6d3a83;

  /// Условия не найдены
  ///
  /// In en, this message translates to:
  /// **'Conditions not found'**
  String get m288545991b;

  /// Условия расчёта
  ///
  /// In en, this message translates to:
  /// **'Calculation conditions'**
  String get m7186793dd5;

  /// Установите 64-битный Python 3.11+ и перезапустите PoB II.
  ///
  /// In en, this message translates to:
  /// **'Install 64-bit Python 3.11 or newer and restart PoB II.'**
  String get m0a3fddcd95;

  /// Установите Git и перезапустите PoB II.
  ///
  /// In en, this message translates to:
  /// **'Install Git and restart PoB II.'**
  String get mdccbb9341b;

  /// Установите компоненты и подключите Lua
  ///
  /// In en, this message translates to:
  /// **'Install components and connect Lua'**
  String get m720408ab97;

  /// Установите компоненты, чтобы открыть сборку и получить настоящий расчёт.
  ///
  /// In en, this message translates to:
  /// **'Install the components to open the assembly and get the real calculation.'**
  String get m4d9acf3506;

  /// Установить
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get mb7cd6fae08;

  /// Установить компоненты
  ///
  /// In en, this message translates to:
  /// **'Install components'**
  String get mfdeaa71380;

  /// Установлена актуальная версия
  ///
  /// In en, this message translates to:
  /// **'Current version installed'**
  String get mfcb7c67f91;

  /// Установлена версия {p0}
  ///
  /// In en, this message translates to:
  /// **'Version {p0} installed'**
  String m44150e69ff(String p0);

  /// Установлена: {p0}
  ///
  /// In en, this message translates to:
  /// **'Installed: {p0}'**
  String mff8616cb20(String p0);

  /// Файл обновления не имеет проверяемой контрольной суммы
  ///
  /// In en, this message translates to:
  /// **'The update file does not have a verifiable checksum'**
  String get m64bd568b72;

  /// Флакон здоровья
  ///
  /// In en, this message translates to:
  /// **'Vial of Health'**
  String get md8a38f5bc2;

  /// Флакон маны
  ///
  /// In en, this message translates to:
  /// **'Mana Vial'**
  String get m5d2173db9c;

  /// Хаос
  ///
  /// In en, this message translates to:
  /// **'Chaos'**
  String get m62d8c4932b;

  /// Характеристика
  ///
  /// In en, this message translates to:
  /// **'Attribute'**
  String get mcf8ae48616;

  /// Характеристики
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get ma07ca1b396;

  /// Холод
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get m8295a5b3a5;

  /// ЧИСЛА И ПРАВИЛА · LUA POB
  ///
  /// In en, this message translates to:
  /// **'NUMBERS AND RULES · LUA POB'**
  String get mb88cddfeb4;

  /// Часть иконок недоступна: {p0}
  ///
  /// In en, this message translates to:
  /// **'Some icons are unavailable: {p0}'**
  String m913d7f855b(String p0);

  /// Шанс блока
  ///
  /// In en, this message translates to:
  /// **'Block Chance'**
  String get mbc55227299;

  /// Шанс блока чар
  ///
  /// In en, this message translates to:
  /// **'Spell Block Chance'**
  String get m7b138318fe;

  /// Шанс заморозки
  ///
  /// In en, this message translates to:
  /// **'Freeze Chance'**
  String get m9c10fb432b;

  /// Шанс критического удара
  ///
  /// In en, this message translates to:
  /// **'Crit Chance'**
  String get mdf8f3ab9d3;

  /// Шанс кровотечения
  ///
  /// In en, this message translates to:
  /// **'Bleed Chance'**
  String get mc82be563bc;

  /// Шанс поджога
  ///
  /// In en, this message translates to:
  /// **'Ignite Chance'**
  String get mdd380bd057;

  /// Шанс попадания
  ///
  /// In en, this message translates to:
  /// **'Chance to hit'**
  String get m75198457b7;

  /// Шанс шока
  ///
  /// In en, this message translates to:
  /// **'Shock Chance'**
  String get m59245fe8a4;

  /// Шлем
  ///
  /// In en, this message translates to:
  /// **'Helmet'**
  String get m53d8cdfa9d;

  /// Штраф сопротивлений
  ///
  /// In en, this message translates to:
  /// **'Resistance penalty'**
  String get me43836c564;

  /// Экспорт XML
  ///
  /// In en, this message translates to:
  /// **'Export XML'**
  String get mae1df2993a;

  /// Энергощит
  ///
  /// In en, this message translates to:
  /// **'Energy Shield'**
  String get mf49983ccf6;

  /// Эта копия запущена без установщика или из каталога без права записи. Установите новую версию со страницы выпусков.
  ///
  /// In en, this message translates to:
  /// **'This copy was launched without an installer or from a non-writable directory. Install the new version from the releases page.'**
  String get m2b2c6df514;

  /// Эта поддержка не подходит выбранному умению
  ///
  /// In en, this message translates to:
  /// **'This support does not match the selected skill'**
  String get m902b19aeea;

  /// Эта сборка уже есть в библиотеке PoB. Выберите другое имя для копии.
  ///
  /// In en, this message translates to:
  /// **'This assembly is already in the PoB library. Choose a different name for the copy.'**
  String get mdfa94e9fd6;

  /// Эти настройки влияют на показатели сборки
  ///
  /// In en, this message translates to:
  /// **'These settings affect build performance'**
  String get mca16b5fe71;

  /// Этот узел даст:
  ///
  /// In en, this message translates to:
  /// **'Allocating this node will give you:'**
  String get m2709d16555;

  /// Этот узел и путь к нему дадут:
  ///
  /// In en, this message translates to:
  /// **'Allocating this node and all nodes leading to it will give you:'**
  String get m428f165db1;

  /// Эффект
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get me39133631f;

  /// Эффективное здоровье
  ///
  /// In en, this message translates to:
  /// **'Effective Hit Pool'**
  String get mf83e6d742f;

  /// Явные свойства
  ///
  /// In en, this message translates to:
  /// **'Explicit properties'**
  String get m612d4e1470;

  /// Язык
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get m5bd57038db;

  /// нет
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get mdc9337ff5b;

  /// ур. {p0}
  ///
  /// In en, this message translates to:
  /// **'lvl. {p0}'**
  String mfc1f7cd547(String p0);

  /// урон в секунду
  ///
  /// In en, this message translates to:
  /// **'damage per second'**
  String get m85436c1ab1;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
