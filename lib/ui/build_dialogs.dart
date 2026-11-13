import 'core/dialog_close_button.dart';
import 'core/app_text.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'core/motion.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'core/ui_translation.dart';
import 'workshop_cubit.dart';

Future<void> showNewBuild(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(context, _NewBuildDialog(model));
Future<void> showXmlImport(BuildContext context, WorkshopCubit model) =>
    model.openXmlFile();
Future<void> showXmlPaste(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(context, _XmlDialog(model));

class _NewBuildDialog extends StatefulWidget {
  const _NewBuildDialog(this.model);
  final WorkshopCubit model;
  @override
  State<_NewBuildDialog> createState() => _NewBuildDialogState();
}

class _NewBuildDialogState extends State<_NewBuildDialog> {
  final name = TextEditingController();
  bool initialized = false;
  final level = TextEditingController(text: '90');
  final form = GlobalKey<FormState>();
  int? classId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    name.text = translateUi(context, 'Новая сборка');
  }

  @override
  void dispose() {
    name.dispose();
    level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const AppText('Новая сборка'),
    content: SizedBox(
      width: 380,
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('build-name'),
              controller: name,
              autofocus: true,
              maxLength: 80,
              decoration: const InputDecoration(label: AppText('Название')),
              validator: (value) => translateUiError(
                context,
                value == null || value.trim().isEmpty
                    ? 'Введите название'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _classPicker(context),
            const SizedBox(height: 16),
            TextFormField(
              controller: level,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(label: AppText('Уровень')),
              validator: (value) =>
                  translateUiError(context, _levelError(value)),
            ),
          ],
        ),
      ),
    ),
    actions: [
      const DialogCloseButton(label: 'Отмена'),
      FilledButton(onPressed: _create, child: const AppText('Создать сборку')),
    ],
  );
  Widget _classPicker(BuildContext context) => FormField<int>(
    key: const Key('build-class'),
    validator: (value) =>
        translateUiError(context, value == null ? 'Выберите класс' : null),
    builder: (field) => InputDecorator(
      decoration: InputDecoration(
        label: const AppText('Класс'),
        errorText: field.errorText,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final entry in widget.model.state.classes)
            _classChoice(field, entry['id'] as int, '${entry['name']}'),
        ],
      ),
    ),
  );

  Widget _classChoice(FormFieldState<int> field, int id, String name) =>
      ChoiceChip(
        key: ValueKey('build-class-$id'),
        avatar: Icon(_classIcon(name), size: 18),
        label: AppText(name, game: true),
        selected: field.value == id,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) {
          field.didChange(id);
          classId = id;
        },
      );

  IconData _classIcon(String name) => switch (name) {
    'Warrior' => Icons.gavel_rounded,
    'Witch' => Icons.dark_mode_outlined,
    'Ranger' => Icons.gps_fixed_rounded,
    'Mercenary' => Icons.shield_outlined,
    'Monk' => Icons.self_improvement_rounded,
    'Sorceress' => Icons.bolt_rounded,
    'Huntress' => Icons.near_me_outlined,
    'Druid' => Icons.park_outlined,
    _ => Icons.person_outline_rounded,
  };

  String? _levelError(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 1 || number > 100 ? 'От 1 до 100' : null;
  }

  void _create() {
    if (!form.currentState!.validate()) return;
    widget.model.createBuild(
      classId!,
      int.parse(level.text),
      name: name.text.trim(),
    );
    Navigator.pop(context);
  }
}

class _XmlDialog extends StatefulWidget {
  const _XmlDialog(this.model);
  final WorkshopCubit model;
  @override
  State<_XmlDialog> createState() => _XmlDialogState();
}

class _XmlDialogState extends State<_XmlDialog> {
  late final xml = TextEditingController(text: widget.model.state.draftXml);
  @override
  void dispose() {
    xml.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const AppText('Открыть XML из PoB'),
    content: SizedBox(
      width: 580,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Вставьте XML сборки. Она будет проверена и рассчитана в Lua.',
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('xml-input'),
            controller: xml,
            minLines: 6,
            maxLines: 10,
            onChanged: widget.model.editDraft,
            style: Spark.mono.copyWith(fontSize: 11),
            decoration: const InputDecoration(
              hint: AppText('<PathOfBuilding2>…</PathOfBuilding2>'),
            ),
          ),
        ],
      ),
    ),
    actions: [
      const DialogCloseButton(label: 'Закрыть'),
      FilledButton(
        onPressed: () {
          if (xml.text.trim().isEmpty) return;
          widget.model.importXml(xml.text);
          Navigator.pop(context);
        },
        child: const AppText('Открыть и рассчитать'),
      ),
    ],
  );
}

Future<void> exportXml(BuildContext context, WorkshopCubit model) =>
    model.saveXmlFile();

Future<void> showXmlCopy(BuildContext context, WorkshopCubit model) async {
  final xml = await model.exportXml();
  if (!context.mounted || xml == null) return;
  await sparkDialog<void>(
    context,
    AlertDialog(
      title: const AppText('XML сборки'),
      content: SizedBox(
        width: 600,
        height: 300,
        child: SingleChildScrollView(
          child: SelectableText(xml, style: Spark.mono.copyWith(fontSize: 11)),
        ),
      ),
      actions: [
        const DialogCloseButton(label: 'Закрыть'),
        FilledButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: xml)),
          icon: SparkArt(
            'icons/copy',
            color: Spark.of(context).paper,
            width: 17,
          ),
          label: const AppText('Скопировать XML'),
        ),
      ],
    ),
  );
}

Future<void> renameBuild(BuildContext context, WorkshopCubit model) async {
  final field = TextEditingController(
    text: model.state.library.active?.title ?? model.state.report?.name,
  );
  final result = await sparkDialog<String>(
    context,
    AlertDialog(
      title: const AppText('Название сборки'),
      content: TextField(
        controller: field,
        autofocus: true,
        maxLength: 80,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        const DialogCloseButton(label: 'Отмена'),
        FilledButton(
          onPressed: () => Navigator.pop(context, field.text),
          child: const AppText('Сохранить'),
        ),
      ],
    ),
  );
  field.dispose();
  if (result != null) await model.renameBuild(result);
}
