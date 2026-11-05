import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/motion.dart';
import 'core/spark_art.dart';
import 'core/spark_theme.dart';
import 'workshop_cubit.dart';

Future<void> showNewBuild(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(context, _NewBuildDialog(model));
Future<void> showXmlImport(BuildContext context, WorkshopCubit model) =>
    sparkDialog<void>(context, _XmlDialog(model));

class _NewBuildDialog extends StatefulWidget {
  const _NewBuildDialog(this.model);
  final WorkshopCubit model;
  @override
  State<_NewBuildDialog> createState() => _NewBuildDialogState();
}

class _NewBuildDialogState extends State<_NewBuildDialog> {
  final name = TextEditingController(text: 'Новая сборка');
  final level = TextEditingController(text: '90');
  final form = GlobalKey<FormState>();
  int? classId;
  @override
  void dispose() {
    name.dispose();
    level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Новая сборка'),
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
              decoration: const InputDecoration(labelText: 'Название'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Введите название'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              key: const Key('build-class'),
              initialValue: classId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Класс'),
              items: widget.model.state.classes
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry['id'] as int,
                      child: Text('${entry['name']}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => classId = value,
              validator: (value) => value == null ? 'Выберите класс' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: level,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Уровень'),
              validator: _levelError,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(onPressed: _create, child: const Text('Создать сборку')),
    ],
  );
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
    title: const Text('Открыть XML из PoB'),
    content: SizedBox(
      width: 580,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
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
              hintText: '<PathOfBuilding2>…</PathOfBuilding2>',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Закрыть'),
      ),
      FilledButton(
        onPressed: () {
          if (xml.text.trim().isEmpty) return;
          widget.model.importXml(xml.text);
          Navigator.pop(context);
        },
        child: const Text('Открыть и рассчитать'),
      ),
    ],
  );
}

Future<void> exportXml(BuildContext context, WorkshopCubit model) async {
  final xml = await model.exportXml();
  if (!context.mounted || xml == null) return;
  await sparkDialog<void>(
    context,
    AlertDialog(
      title: const Text('XML сборки'),
      content: SizedBox(
        width: 600,
        height: 300,
        child: SingleChildScrollView(
          child: SelectableText(xml, style: Spark.mono.copyWith(fontSize: 11)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
        FilledButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: xml)),
          icon: SparkArt(
            'icons/copy',
            color: Spark.of(context).paper,
            width: 17,
          ),
          label: const Text('Скопировать XML'),
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
      title: const Text('Название сборки'),
      content: TextField(
        controller: field,
        autofocus: true,
        maxLength: 80,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, field.text),
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
  field.dispose();
  if (result != null) await model.renameBuild(result);
}
