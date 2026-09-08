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
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _currentResults = [];
      _isLoading = false;
      if (!_resultsController.isClosed) _resultsController.add([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (_resultsController.isClosed) return;
      _isLoading = true;
      _resultsController.add(_currentResults);
      final products = await SearchService.searchProducts(trimmed);
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
        final list = SearchResultsList(
          key: ValueKey('${query}_${products.length}'),
          query: query,
          products: products,
          highlightBuilder: _highlight,
        );
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
}

typedef HighlightBuilder = TextSpan Function(
    BuildContext context, String source, String query, TextStyle style);

class SearchResultsList extends StatefulWidget {
  final String query;
  final List<Product> products;
  final HighlightBuilder highlightBuilder;

  const SearchResultsList({
    Key? key,
    required this.query,
    required this.products,
    required this.highlightBuilder,
  }) : super(key: key);

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  bool _isRelatedExpanded = false;

  static String _normalize(String? s) => SearchService.normalizeText(s);

  static String? _getExactMatchedStockCode(Product product, String q) {
    final cleanQ = q.trim().toLowerCase();
    final normCode = cleanQ.replaceAll(RegExp(r'[\s\-_./]'), '');
    if (cleanQ.isEmpty) return null;

    if (product.malzemeler != null) {
      for (var m in product.malzemeler!) {
        final code = m.stokKodu.trim().toLowerCase();
        final normM = code.replaceAll(RegExp(r'[\s\-_./]'), '');
        if (code == cleanQ || (normCode.length >= 3 && normM == normCode)) {
          return m.stokKodu;
        }
      }
    }
    return null;
  }

  static bool _titleMatches(Product product, String q) {
    final normQ = _normalize(q);
    if (normQ.isEmpty) return false;
    final normAd = _normalize(product.ad);
    if (normAd.contains(normQ)) return true;
    final words = normQ.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length > 1 && words.every((w) => normAd.contains(w))) {
      return true;
    }
    return false;
  }

  String _matchReason(Product product, String q) {
    final normQ = _normalize(q);
    bool contains(String? t) => _normalize(t).contains(normQ);
    final exactCode = _getExactMatchedStockCode(product, q);
    if (exactCode != null) {
      return '${"exactMatch".tr}: $exactCode';
    }
    if (contains(product.ad)) return 'matchName'.tr;
    if (contains(product.alinti)) return 'matchSummary'.tr;
    if (contains(product.aciklama)) return 'matchDescription'.tr;
    if (product.malzemeler?.any((m) => contains(m.stokKodu)) ?? false) {
      return 'matchStock'.tr;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(child: Text('noResults'.tr));
    }

    final query = widget.query.trim();

    // Check if ANY product has an exact stock code match
    final bool hasCodeMatch =
        widget.products.any((p) => _getExactMatchedStockCode(p, query) != null);

    final List<Product> primaryMatches;
    final List<Product> relatedMatches;
    final bool isCodeSearch;

    if (hasCodeMatch) {
      // CODE SEARCH MODE:
      // Primary: Products whose stock code matches exactly
      // Related: Other products containing this code in parts/sub-models
      isCodeSearch = true;
      primaryMatches = widget.products
          .where((p) => _getExactMatchedStockCode(p, query) != null)
          .toList();
      relatedMatches = widget.products
          .where((p) => _getExactMatchedStockCode(p, query) == null)
          .toList();
    } else {
      // NAME / KEYWORD SEARCH MODE:
      isCodeSearch = false;
      final titleList =
          widget.products.where((p) => _titleMatches(p, query)).toList();
      if (titleList.isNotEmpty) {
        // Products whose title explicitly contains the search term(s)
        primaryMatches = titleList;
        relatedMatches =
            widget.products.where((p) => !_titleMatches(p, query)).toList();
      } else {
        // Fallback: If no product has it in title, show all results directly so nothing is hidden
        primaryMatches = widget.products;
        relatedMatches = [];
      }
    }

    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isCodeSearch ? Icons.check_circle : Icons.search,
                size: 18,
                color: isCodeSearch
                    ? Colors.green.shade700
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                (isCodeSearch ? 'exactMatch'.tr : 'productResults'.tr)
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isCodeSearch
                      ? Colors.green.shade800
                      : theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${primaryMatches.length} ${"products".tr.toLowerCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        ...primaryMatches.map(
          (product) => _buildProductCard(
            context,
            product,
            isExactCode: isCodeSearch,
          ),
        ),
        if (relatedMatches.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildRelatedButton(
            context,
            relatedMatches.length,
            isCodeSearch: isCodeSearch,
          ),
          if (_isRelatedExpanded) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.alt_route,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'relatedProductsHeader'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            ...relatedMatches.map((product) =>
                _buildProductCard(context, product, isExactCode: false)),
          ],
        ],
      ],
    );
  }

  Widget _buildRelatedButton(BuildContext context, int count,
      {required bool isCodeSearch}) {
    final theme = Theme.of(context);
    final subtitle = isCodeSearch
        ? 'relatedProductsSubtitle'.tr
        : 'relatedDescSubtitle'.tr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _isRelatedExpanded = !_isRelatedExpanded;
            });
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRelatedExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRelatedExpanded
                            ? 'hideRelatedProducts'.tr
                            : '${"showRelatedProducts".tr} ($count)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isRelatedExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product, {
    required bool isExactCode,
  }) {
    final exactCode =
        isExactCode ? _getExactMatchedStockCode(product, widget.query) : null;
    final theme = Theme.of(context);

    return Card(
      elevation: isExactCode ? 2.5 : 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isExactCode
            ? BorderSide(color: Colors.green.shade500, width: 1.5)
            : BorderSide(color: Colors.grey.shade200, width: 0.8),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(product: product),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: product.urunFoto?.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: Constants.DOMAIN + product.urunFoto!.first.foto,
                    fit: BoxFit.cover,
                  )
                : Image.asset('assets/images/unnamed.png', fit: BoxFit.cover),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: widget.highlightBuilder(
                context,
                product.ad,
                widget.query,
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isExactCode
                      ? Colors.green.shade900
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            if (exactCode != null)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade600, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 13, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${"exactMatch".tr}: $exactCode',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            if (product.alinti.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RichText(
                  text: widget.highlightBuilder(
                    context,
                    product.alinti,
                    widget.query,
                    TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              )
            else if (product.aciklama.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RichText(
                  text: widget.highlightBuilder(
                    context,
                    product.aciklama,
                    widget.query,
                    TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            if (!isExactCode &&
                _matchReason(product, widget.query).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _matchReason(product, widget.query),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
