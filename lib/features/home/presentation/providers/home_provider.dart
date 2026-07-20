import 'package:flutter_riverpod/flutter_riverpod.dart';

// Home screen has no async state — categories and featured products
// are loaded from shop providers directly. This provider holds UI state
// such as the in-screen search query.

final homeSearchQueryProvider =
    NotifierProvider<HomeSearchQueryNotifier, String>(
  HomeSearchQueryNotifier.new,
);

class HomeSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}
