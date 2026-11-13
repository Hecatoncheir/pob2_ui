import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_catalog_repository.dart';
import '../domain/gem_icon.dart';

typedef _ImageState = ({GemIcon? icon, bool loading, String? error});

class _GemImageCubit extends Cubit<_ImageState> {
  _GemImageCubit(this.repository, this.id)
    : super((icon: null, loading: true, error: null));
  final GameCatalogRepository repository;
  final String id;
  Future<void> load() async {
    emit((icon: null, loading: true, error: null));
    try {
      final icon = await repository.icon(id);
      if (!isClosed) emit((icon: icon, loading: false, error: null));
    } catch (error) {
      if (!isClosed) emit((icon: null, loading: false, error: '$error'));
    }
  }
}

class OriginalGemImage extends StatelessWidget {
  const OriginalGemImage({
    super.key,
    required this.id,
    required this.repository,
  });
  final String id;
  final GameCatalogRepository repository;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _GemImageCubit(repository, id)..load(),
    child: BlocBuilder<_GemImageCubit, _ImageState>(
      builder: (context, state) {
        if (state.loading)
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        if (state.icon case final icon?)
          return Image.memory(
            icon.bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
        return Tooltip(
          message: state.error ?? 'Изображение камня недоступно',
          child: IconButton(
            onPressed: context.read<_GemImageCubit>().load,
            icon: const Icon(Icons.broken_image_outlined, size: 18),
          ),
        );
      },
    ),
  );
}
