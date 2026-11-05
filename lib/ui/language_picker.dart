import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_language.dart';
import 'core/app_text.dart';
import 'core/spark_theme.dart';
import 'language_cubit.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<LanguageCubit, LanguageState>(
    builder: (context, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<AppLanguage>(
          key: const Key('app-language'),
          initialValue: state.language,
          isExpanded: true,
          decoration: const InputDecoration(label: AppText('Язык')),
          dropdownColor: Spark.of(context).surface,
          style: TextStyle(
            color: Spark.of(context).ink,
            fontFamily: 'Nunito Sans',
          ),
          items: [
            for (final language in AppLanguage.values)
              DropdownMenuItem(value: language, child: Text(language.label)),
          ],
          onChanged: (language) {
            if (language != null)
              context.read<LanguageCubit>().selectLanguage(language);
          },
        ),
        if (state.loading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const AppText(
            'Игровые переводы загружаются…',
            style: TextStyle(fontSize: 11),
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: 8),
          AppText(
            'Не удалось загрузить перевод: ${state.error}',
            maxLines: 2,
            style: TextStyle(color: Spark.of(context).danger, fontSize: 11),
          ),
          TextButton(
            onPressed: () =>
                context.read<LanguageCubit>().selectLanguage(state.language),
            child: const AppText('Повторить'),
          ),
        ],
      ],
    ),
  );
}

Locale languageLocale(AppLanguage language) => switch (language) {
  AppLanguage.chinese => const Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  ),
  AppLanguage.portuguese => const Locale('pt', 'BR'),
  _ => Locale(language.code),
};
