import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/proxy_settings.dart';
import 'core/app_text.dart';
import 'core/motion.dart';
import 'core/ui_translation.dart';
import 'proxy_cubit.dart';

class ProxySettingsButton extends StatelessWidget {
  const ProxySettingsButton({super.key, required this.proxy});

  final ProxyCubit proxy;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProxyCubit, ProxySettings>(
    bloc: proxy,
    builder: (context, settings) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: const AppText('Прокси'),
      subtitle: AppText(_modeLabel(settings.mode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => sparkDialog<void>(
        context,
        _ProxySettingsDialog(proxy),
        barrierDismissible: false,
      ),
    ),
  );
}

String _modeLabel(ProxyMode mode) => switch (mode) {
  ProxyMode.automatic => 'Автоматически',
  ProxyMode.direct => 'Без прокси',
  ProxyMode.manual => 'HTTP-прокси',
};

class _ProxySettingsDialog extends StatefulWidget {
  const _ProxySettingsDialog(this.proxy);

  final ProxyCubit proxy;

  @override
  State<_ProxySettingsDialog> createState() => _ProxySettingsDialogState();
}

class _ProxySettingsDialogState extends State<_ProxySettingsDialog> {
  late ProxyMode _mode = widget.proxy.state.mode;
  late final _address = TextEditingController(text: widget.proxy.state.address);
  bool _saving = false;
  bool _invalidAddress = false;
  bool _saveFailed = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _chooseMode(ProxyMode? mode) {
    if (mode == null) return;
    setState(() {
      _mode = mode;
      _invalidAddress = false;
      _saveFailed = false;
    });
  }

  ProxySettings _settings() => switch (_mode) {
    ProxyMode.automatic => const ProxySettings.automatic(),
    ProxyMode.direct => const ProxySettings.direct(),
    ProxyMode.manual => ProxySettings.manual(_address.text),
  };

  Future<void> _save() async {
    if (_saving) return;
    final ProxySettings settings;
    try {
      settings = _settings();
    } on FormatException {
      setState(() => _invalidAddress = true);
      return;
    }
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.proxy.save(settings);
      if (mounted) Navigator.pop(context);
    } on FileSystemException {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      scrollable: true,
      title: const AppText('Прокси'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<ProxyMode>(
              groupValue: _mode,
              onChanged: _chooseMode,
              child: Column(
                children: [
                  for (final mode in ProxyMode.values)
                    RadioListTile<ProxyMode>(
                      value: mode,
                      title: AppText(_modeLabel(mode)),
                      contentPadding: EdgeInsets.zero,
                      enabled: !_saving,
                    ),
                ],
              ),
            ),
            if (_mode == ProxyMode.manual) ...[
              const SizedBox(height: 12),
              _addressField(context),
            ],
            if (_saveFailed) ...[
              const SizedBox(height: 12),
              AppText(
                'Не удалось сохранить настройки прокси',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const AppText('Отмена'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const AppText('Сохранить'),
        ),
      ],
    ),
  );

  Widget _addressField(BuildContext context) => TextField(
    controller: _address,
    enabled: !_saving,
    autocorrect: false,
    keyboardType: TextInputType.url,
    onChanged: (_) {
      if (_invalidAddress) setState(() => _invalidAddress = false);
    },
    decoration: InputDecoration(
      labelText: translateUi(context, 'Адрес и порт'),
      hintText: '127.0.0.1:8080',
      errorText: _invalidAddress
          ? translateUi(
              context,
              'Введите адрес HTTP-прокси в формате хост:порт.',
            )
          : null,
      errorMaxLines: 3,
    ),
  );
}
