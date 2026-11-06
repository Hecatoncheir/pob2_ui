import '../domain/trade_search.dart';
import '../domain/build_report.dart';
import 'mcp_client.dart';

class TradeSearchRepository {
  TradeSearchRepository(this.engine);
  final McpClient engine;
  bool get available =>
      engine.tools.containsAll({'pob_trade_catalog', 'pob_trade_search'});

  Future<TradeCatalog> catalog(String slot) async {
    if (!available)
      throw const FormatException('Обновите MCP для поиска на торговле');
    return TradeCatalog.fromJson(
      await engine.call('pob_trade_catalog', {'slot': slot}),
    );
  }

  Future<Uri> prepare(JsonMap arguments) async {
    final result = await engine.call('pob_trade_search', arguments);
    if (result case {'source': 'original-lua', 'url': final String text}) {
      final uri = Uri.tryParse(text);
      if (uri != null && validTradeLink(uri)) return uri;
    }
    throw const FormatException('PoB не вернул корректную ссылку поиска');
  }
}

bool validTradeLink(Uri uri) =>
    uri.scheme == 'https' &&
    uri.host == 'www.pathofexile.com' &&
    !uri.hasPort &&
    uri.userInfo.isEmpty &&
    uri.fragment.isEmpty &&
    uri.path.startsWith('/trade2/search/poe2/') &&
    uri.queryParametersAll.length == 1 &&
    uri.queryParametersAll['q']?.length == 1;
