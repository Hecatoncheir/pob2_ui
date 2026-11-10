import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../domain/pob_character.dart';
import 'core/app_text.dart';
import 'core/language_scope.dart';
import 'core/motion.dart';
import 'workshop_cubit.dart';

class PobCharacterImportButton extends StatelessWidget {
  const PobCharacterImportButton(this.model, {super.key});
  final WorkshopCubit model;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: model.state.busy || !model.engine.connected
        ? null
        : () => showPobCharacterImport(context, model),
    child: const AppText('Импортировать персонажа'),
  );
}

Future<void> showPobCharacterImport(
  BuildContext context,
  WorkshopCubit model,
) async {
  final name = await sparkDialog<String>(
    context,
    BlocProvider(
      create: (_) => _CharacterPicker(
        () => model.pobWindow.listCharacters(model.components.active),
      )..load(),
      child: const _CharacterDialog(),
    ),
  );
  if (name != null && !model.isClosed) await model.importPobCharacter(name);
}

typedef _PickerState = ({
  bool busy,
  List<PobCharacter> characters,
  String? selected,
  String? error,
});

class _CharacterPicker extends Cubit<_PickerState> {
  _CharacterPicker(this._load)
    : super((busy: false, characters: const [], selected: null, error: null));

  final Future<List<PobCharacter>> Function() _load;

  Future<void> load() async {
    emit((busy: true, characters: const [], selected: null, error: null));
    try {
      final characters = await _load();
      if (!isClosed)
        emit((
          busy: false,
          characters: characters,
          selected: null,
          error: null,
        ));
    } catch (error) {
      if (!isClosed)
        emit((
          busy: false,
          characters: const [],
          selected: null,
          error: mcpErrorMessage(error),
        ));
    }
  }

  void select(String name) => emit((
    busy: false,
    characters: state.characters,
    selected: name,
    error: null,
  ));
}

class _CharacterDialog extends StatelessWidget {
  const _CharacterDialog();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<_CharacterPicker, _PickerState>(
        builder: (context, state) => AlertDialog(
          title: const AppText('Импорт персонажа из PoB'),
          content: SizedBox(
            width: 450,
            height: 300,
            child: _content(context, state),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText('Закрыть'),
            ),
            FilledButton(
              onPressed: state.selected == null
                  ? null
                  : () => Navigator.pop(context, state.selected),
              child: const AppText('Импортировать'),
            ),
          ],
        ),
      );

  Widget _content(BuildContext context, _PickerState state) {
    if (state.busy) return const Center(child: CircularProgressIndicator());
    if (state.characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              state.error ?? 'В аккаунте нет доступных персонажей.',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: context.read<_CharacterPicker>().load,
              child: const AppText('Повторить'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: state.characters.length,
      itemBuilder: (context, index) {
        final character = state.characters[index];
        final details = [
          translateGame(context, character.characterClass),
          '${character.level}',
          if (character.league case final league?)
            translateGame(context, league),
        ];
        final selected = character.name == state.selected;
        return ListTile(
          selected: selected,
          title: AppText(character.name, localize: false),
          subtitle: AppText(details.join(' · '), localize: false),
          trailing: selected ? const Icon(Icons.check) : null,
          onTap: () => context.read<_CharacterPicker>().select(character.name),
        );
      },
    );
  }
}
