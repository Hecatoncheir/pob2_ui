import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/mcp_error_message.dart';
import '../data/trade_search_repository.dart';
import '../domain/trade_search.dart';

typedef TradeSearchForm = ({
  String league,
  String price,
  String? base,
  String? currency,
  bool online,
  List<TradeFilterDraft> filters,
});
typedef TradeSearchState = ({
  TradeCatalog? catalog,
  TradeSearchForm form,
  bool loading,
  bool busy,
  Uri? url,
  String? error,
});

class TradeSearchCubit extends Cubit<TradeSearchState> {
  TradeSearchCubit(
    this.repository,
    this.slot,
    this.openBrowser, {
    this.initialBase,
  }) : super((
         catalog: null,
         form: (
           league: 'Standard',
           price: '',
           base: null,
           currency: null,
           online: true,
           filters: const [],
         ),
         loading: true,
         busy: false,
         url: null,
         error: null,
       ));
  final TradeSearchRepository repository;
  final String slot;
  final Future<void> Function(Uri) openBrowser;
  final String? initialBase;

  Future<void> load() async {
    try {
      final catalog = await repository.catalog(slot);
      if (isClosed) return;
      emit((
        catalog: catalog,
        form: state.form,
        loading: false,
        busy: false,
        url: null,
        error: null,
      ));
      update(
        base: catalog.bases.contains(initialBase) ? initialBase : null,
        currency: catalog.currencies.firstOrNull?.id,
      );
    } catch (error) {
      _emit(loading: false, error: mcpErrorMessage(error));
    }
  }

  void update({
    String? league,
    String? price,
    String? base,
    bool clearBase = false,
    String? currency,
    bool? online,
    List<TradeFilterDraft>? filters,
  }) {
    if (state.busy) return;
    final previous = state.form;
    _emit(
      form: (
        league: league ?? previous.league,
        price: price ?? previous.price,
        base: clearBase ? null : base ?? previous.base,
        currency: currency ?? previous.currency,
        online: online ?? previous.online,
        filters: List.unmodifiable(filters ?? previous.filters),
      ),
    );
  }

  void add(TradeStat stat) {
    if (state.form.filters.length >= 12 ||
        state.form.filters.any((filter) => filter.stat.id == stat.id))
      return;
    update(
      filters: [
        ...state.form.filters,
        TradeFilterDraft(stat, option: stat.options.firstOrNull?.id),
      ],
    );
  }

  void edit(String id, {String? min, String? max, String? option}) => update(
    filters: [
      for (final filter in state.form.filters)
        filter.stat.id == id
            ? filter.copyWith(min: min, max: max, option: option)
            : filter,
    ],
  );
  void remove(String id) => update(
    filters: state.form.filters
        .where((filter) => filter.stat.id != id)
        .toList(),
  );

  Future<Uri?> link() async {
    if (state.busy || state.catalog == null) return null;
    if (state.url case final url?) return url;
    _emit(busy: true);
    try {
      final form = state.form;
      final uri = await repository.prepare({
        'slot': slot,
        'league': form.league.trim(),
        'online': form.online,
        if (form.base != null) 'base': form.base,
        if (form.price.trim().isNotEmpty) 'maxPrice': _price(form.price),
        if (form.currency != null) 'currency': form.currency,
        'filters': form.filters.map((filter) => filter.toJson()).toList(),
      });
      _emit(url: uri, busy: false);
      return isClosed ? null : uri;
    } catch (error) {
      _emit(busy: false, error: mcpErrorMessage(error));
      return null;
    }
  }

  Future<void> open() async {
    final uri = await link();
    if (uri == null) return;
    _emit(busy: true, url: uri);
    try {
      await openBrowser(uri);
      _emit(busy: false, url: uri);
    } catch (error) {
      _emit(
        url: uri,
        busy: false,
        error: 'Не удалось открыть браузер: ${mcpErrorMessage(error)}',
      );
    }
  }

  num _price(String text) {
    final value = num.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0)
      throw const FormatException('Введите корректный бюджет');
    return value;
  }

  void _emit({
    TradeSearchForm? form,
    bool? loading,
    bool? busy,
    Uri? url,
    String? error,
  }) {
    if (isClosed) return;
    emit((
      catalog: state.catalog,
      form: form ?? state.form,
      loading: loading ?? state.loading,
      busy: busy ?? state.busy,
      url: url,
      error: error,
    ));
  }
}
