import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/blinking_cursor.dart';

import '../constants.dart';
import '../models/product.dart';
import '../services/search_service.dart';
import 'product.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  static const _historyKey = 'searchHistory';

  final FocusNode _focusNode = FocusNode();
  Future<List<String>>? _historyFuture;
  final ValueNotifier<List<String>> _historyNotifier = ValueNotifier([]);

  ProductSearchDelegate() {
    _loadHistory();

    // Rebuild when focus changes so the cursor and hint text update
    _focusNode.addListener(() {
      // Trigger a rebuild without altering the query value
      query = query;
    });
    // Request focus after the delegate builds so the caret shows
    Future.microtask(() => _focusNode.requestFocus());
    _historyFuture = _getHistory(); // Initialize history future
  }
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _historyNotifier.value = prefs.getStringList(_historyKey) ?? [];
  }

  @override
  FocusNode? get searchFieldFocusNode => _focusNode;

  Timer? _debounce;

  final StreamController<List<Product>> _resultsController =
      StreamController<List<Product>>.broadcast();
  List<Product> _currentResults = [];
  String _lastQuery = '';
  bool _isLoading = false;

  TextSpan _highlight(
      BuildContext context, String source, String query, TextStyle style) {
    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty || !lowerSource.contains(lowerQuery)) {
      return TextSpan(text: source, style: style);
    }
    final spans = <TextSpan>[];
    int start = 0;
    final highlightColor =
        Theme.of(context).colorScheme.secondaryContainer;
    while (true) {
      final index = lowerSource.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: source.substring(start), style: style));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: source.substring(start, index), style: style));
      }
      spans.add(TextSpan(
          text: source.substring(index, index + query.length),
          style: style.copyWith(backgroundColor: highlightColor)));
      start = index + query.length;
    }
    return TextSpan(children: spans);
  }

  String _matchReason(Product product, String q) {
    final lower = q.toLowerCase();
    bool contains(String? t) => t?.toLowerCase().contains(lower) ?? false;
    if (contains(product.ad)) return 'matchName'.tr;
    if (contains(product.alinti)) return 'matchSummary'.tr;
    if (contains(product.aciklama)) return 'matchDescription'.tr;
    if (product.malzemeler?.any((m) => contains(m.stokKodu)) ?? false) {
      return 'matchStock'.tr;
    }
    return '';
  }

  @override
  void close(BuildContext context, Product? result) {
    _debounce?.cancel();
    _resultsController.close();
    _focusNode.dispose();
    super.close(context, result);
  }

  Future<void> _saveQuery(String query) async {
    debugPrint('[ProductSearchDelegate] _saveQuery start: $query');
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? <String>[];
    history.remove(query);
    history.insert(0, query);
    if (history.length > 10) history.removeLast();
    await prefs.setStringList(_historyKey, history);
    debugPrint('[ProductSearchDelegate] _saveQuery updated history: $history');
    _historyFuture = _getHistory(); // Update future after saving
    debugPrint('[ProductSearchDelegate] _saveQuery history future reset');
  }

  Future<List<String>> _getHistory() async {
    debugPrint('[ProductSearchDelegate] _getHistory start');
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? <String>[];
    debugPrint('[ProductSearchDelegate] _getHistory result: $history');
    return history;
  }

  // Tüm geçmişi temizler ve önerileri yeniden çizdirir
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    _historyNotifier.value = [];
  }


  // Tek bir maddeyi siler ve önerileri yeniden çizdirir
  Future<void> _removeHistoryItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    history.remove(item);
    await prefs.setStringList(_historyKey, history);
    _historyNotifier.value = history;
  }


  

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: theme.colorScheme.onPrimary,
        displayColor: theme.colorScheme.onPrimary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.colorScheme.onPrimary, // Ensure cursor is visible
      ),
    );
  }


  void _search(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_resultsController.isClosed) return;
      _isLoading = true;
      _resultsController.add(_currentResults);
      final products = await SearchService.searchProducts(value);
      if (_resultsController.isClosed) return;
      _currentResults = products;
      _isLoading = false;
      _resultsController.add(_currentResults);
    });
  }
  @override
  String get searchFieldLabel =>
      _focusNode.hasFocus && query.isEmpty ? '' : 'productSearch'.tr;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ValueListenableBuilder<List<String>>(
        valueListenable: _historyNotifier,
        builder: (context, history, _) {
          if (history.isEmpty) {
            return Center(child: Text('recentSearches'.tr));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('recentSearches'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _clearHistory,
                    child: Text('clearHistory'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...history.map((item) => ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeHistoryItem(item),
                ),
                onTap: () {
                  query = item;
                  showResults(context);
                },
              )),
            ],
          );
        },
      );
    }
    return _buildResultStream();
  }

  @override
  Widget buildResults(BuildContext context) {
    _saveQuery(query);
    return _buildResultStream();
  }

  Widget _buildResultStream() {
    if (query != _lastQuery) {
      _lastQuery = query;
      _search(query);
    }
    return StreamBuilder<List<Product>>(
      stream: _resultsController.stream,
      initialData: _currentResults,
      builder: (context, snapshot) {
        final products = snapshot.data ?? <Product>[];
        if (_isLoading && products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = _buildList(context, products);
        if (_isLoading) {
          return Stack(
            children: [
              list,
              const Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        return list;
      },
    );
  }

  Widget _buildList(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return Center(child: Text('noResults'.tr));
    }
    final sorted = [...products];
    sorted.sort((a, b) {
      final aMatch = _matchReason(a, query).isNotEmpty;
      final bMatch = _matchReason(b, query).isNotEmpty;
      if (aMatch == bMatch) return 0;
      return aMatch ? -1 : 1;
    });
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final product = sorted[index];
        return Card(
          elevation: 1.0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(product: product),
                ),
              );
            },
            leading: AspectRatio(
              aspectRatio: 16 / 9,
              child: product.urunFoto?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: Constants.DOMAIN + product.urunFoto!.first.foto,
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/images/unnamed.png', fit: BoxFit.cover),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: _highlight(
                    context,
                    product.ad,
                    query,
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (product.alinti.isNotEmpty)
                  RichText(
                    text: _highlight(
                        context,
                        product.alinti,
                        query,
                        TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                  )
                else if (product.aciklama.isNotEmpty)
                  RichText(
                    text: _highlight(
                        context,
                        product.aciklama,
                        query,
                        TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                  ),
                if (_matchReason(product, query).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _matchReason(product, query),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
