import 'package:flutter_bloc/flutter_bloc.dart';

typedef CatalogState<T> = ({
  List<T> entries,
  bool loading,
  String query,
  bool configuredOnly,
  String? error,
});

class CatalogCubit<T> extends Cubit<CatalogState<T>> {
  CatalogCubit(this.fetch)
    : super((
        entries: const [],
        loading: true,
        query: '',
        configuredOnly: false,
        error: null,
      ));
  final Future<List<T>> Function() fetch;

  Future<void> load() async {
    emit((
      entries: state.entries,
      loading: true,
      query: state.query,
      configuredOnly: state.configuredOnly,
      error: null,
    ));
    try {
      final entries = await fetch();
      if (!isClosed)
        emit((
          entries: List.unmodifiable(entries),
          loading: false,
          query: state.query,
          configuredOnly: state.configuredOnly,
          error: null,
        ));
    } catch (error) {
      if (!isClosed)
        emit((
          entries: state.entries,
          loading: false,
          query: state.query,
          configuredOnly: state.configuredOnly,
          error: '$error',
        ));
    }
  }

  void search(String query) => emit((
    entries: state.entries,
    loading: state.loading,
    query: query,
    configuredOnly: state.configuredOnly,
    error: state.error,
  ));
  void configured(bool value) => emit((
    entries: state.entries,
    loading: state.loading,
    query: state.query,
    configuredOnly: value,
    error: state.error,
  ));
}
