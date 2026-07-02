import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../lib/core/models/ebook.dart';
import '../../lib/features/library/providers/ebook_providers.dart';
import '../../lib/features/search/presentation/search_screen.dart';

// ─── Fake data ──────────────────────────────────────────────
const _rubyBook = Ebook(
  id: 1,
  title: 'Ruby on Rails',
  author: 'DHH',
  fileType: 'pdf',
  fileSize: 1024000,
);

const _pythonBook = Ebook(
  id: 2,
  title: 'Python Tricks',
  author: 'Dan Bader',
  fileType: 'epub',
  fileSize: 512000,
);

// ─── Router stub ────────────────────────────────────────────
final _testRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/ebook/:id', builder: (_, __) => const SizedBox()),
  ],
);

// ─── Provider override helpers ───────────────────────────────

/// Returns [books] when query matches any word in title/author, else [].
Override _searchOverride(List<Ebook> books) =>
    searchResultsProvider.overrideWith((ref) {
      final q = ref.watch(searchQueryProvider).trim().toLowerCase();
      if (q.isEmpty) return Future.value([]);
      return Future.value(books
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              (e.author?.toLowerCase().contains(q) ?? false))
          .toList());
    });

Widget _wrap({List<Ebook> results = const []}) => ProviderScope(
      overrides: [_searchOverride(results)],
      child: MaterialApp.router(routerConfig: _testRouter),
    );

// ────────────────────────────────────────────────────────────
void main() {
  group('SearchScreen', () {
    // ── Initial / hint state ─────────────────────────────────
    testWidgets('shows hint when query is empty', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Type to search'), findsOneWidget);
    });

    testWidgets('search field is auto-focused on open', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byKey(const Key('search_field')));
      expect(field.autofocus, isTrue);
    });

    // ── Filter chips rendered ────────────────────────────────
    testWidgets('shows All, PDF, EPUB filter chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('type_All')), findsOneWidget);
      expect(find.byKey(const Key('type_PDF')), findsOneWidget);
      expect(find.byKey(const Key('type_EPUB')), findsOneWidget);
    });

    testWidgets('All chip is selected by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final chip = tester.widget<FilterChip>(
        find.byKey(const Key('type_All')),
      );
      expect(chip.selected, isTrue);
    });

    // ── No results state ─────────────────────────────────────
    testWidgets('shows no-results state when search returns empty', (tester) async {
      await tester.pumpWidget(_wrap(results: []));
      await tester.pumpAndSettle();

      // Type a query so we're no longer in hint state
      await tester.enterText(find.byKey(const Key('search_field')), 'xyz');
      // Trigger the debounced provider update directly
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );
      container.read(searchQueryProvider.notifier).state = 'xyz';
      await tester.pumpAndSettle();

      expect(find.text('No ebooks found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    // ── Results rendered ─────────────────────────────────────
    testWidgets('shows results when search matches', (tester) async {
      await tester.pumpWidget(_wrap(results: [_rubyBook, _pythonBook]));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );
      container.read(searchQueryProvider.notifier).state = 'ruby';
      await tester.pumpAndSettle();

      expect(find.text('Ruby on Rails'), findsOneWidget);
      expect(find.text('DHH'), findsOneWidget);
    });

    testWidgets('result tile shows file type badge', (tester) async {
      await tester.pumpWidget(_wrap(results: [_rubyBook]));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SearchScreen)),
      );
      container.read(searchQueryProvider.notifier).state = 'ruby';
      await tester.pumpAndSettle();

      expect(find.text('PDF'), findsWidgets);
    });

    // ── Clear button ─────────────────────────────────────────
    testWidgets('clear button appears when text is entered', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_field')), 'test');
      await tester.pump();

      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
    });

    // ── Filter chip interaction ──────────────────────────────
    testWidgets('tapping PDF chip marks it selected', (tester) async {
      await tester.pumpWidget(_wrap(results: [_rubyBook, _pythonBook]));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('type_PDF')));
      await tester.pumpAndSettle();

      final pdfChip = tester.widget<FilterChip>(
        find.byKey(const Key('type_PDF')),
      );
      expect(pdfChip.selected, isTrue);
    });

    testWidgets('tapping EPUB chip deselects PDF chip', (tester) async {
      await tester.pumpWidget(_wrap(results: [_rubyBook, _pythonBook]));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('type_EPUB')));
      await tester.pumpAndSettle();

      final pdfChip = tester.widget<FilterChip>(
        find.byKey(const Key('type_PDF')),
      );
      expect(pdfChip.selected, isFalse);
    });
  });
}
