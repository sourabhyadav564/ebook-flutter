import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../lib/core/models/ebook.dart';
import '../../lib/features/library/providers/ebook_providers.dart';
import '../../lib/features/library/presentation/library_screen.dart';

// ─── Sample data ─────────────────────────────────────────────
const _fakeEbooks = [
  Ebook(id: 1, title: 'Clean Code', author: 'Robert C. Martin', fileType: 'pdf', fileSize: 2048000),
  Ebook(id: 2, title: 'Refactoring',  author: 'Martin Fowler',   fileType: 'epub', fileSize: 1024000),
];

// ─── Router stub ─────────────────────────────────────────────
GoRouter _makeRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LibraryScreen()),
        GoRoute(path: '/search',     builder: (_, __) => const SizedBox()),
        GoRoute(path: '/ebook/:id',  builder: (_, __) => const SizedBox()),
      ],
    );

// ─── Provider overrides ──────────────────────────────────────
Override _dataOverride(List<Ebook> books) =>
    ebooksProvider.overrideWith((ref, filter) => Future.value(books));

Override _loadingOverride() =>
    ebooksProvider.overrideWith((ref, filter) => Future.delayed(
          const Duration(days: 999), // never resolves within test
          () => <Ebook>[],
        ));

Override _errorOverride(String message) =>
    ebooksProvider.overrideWith((ref, filter) => Future.error(message));

Widget _wrap(Override dataOverride) => ProviderScope(
      overrides: [dataOverride],
      child: MaterialApp.router(routerConfig: _makeRouter()),
    );

// ────────────────────────────────────────────────────────────
void main() {
  group('LibraryScreen', () {
    // ── AppBar & FAB ─────────────────────────────────────────
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride(_fakeEbooks)));
      await tester.pump(); // first frame

      expect(find.text('📚 My Library'), findsOneWidget);
    });

    testWidgets('shows search icon button in AppBar', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride(_fakeEbooks)));
      await tester.pump();

      expect(find.byKey(const Key('search_button')), findsOneWidget);
    });

    testWidgets('shows Add Book FAB', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride(_fakeEbooks)));
      await tester.pump();

      expect(find.byKey(const Key('upload_fab')), findsOneWidget);
    });

    // ── Loading state ─────────────────────────────────────────
    testWidgets('shows shimmer placeholders while loading', (tester) async {
      await tester.pumpWidget(_wrap(_loadingOverride()));
      await tester.pump(); // loading frame — future never resolves

      // Shimmer rows are plain Containers; check that we have some
      expect(find.byType(Container), findsWidgets);
      // And the shelf / ebook titles are NOT shown yet
      expect(find.text('Clean Code'), findsNothing);
    });

    // ── Empty state ───────────────────────────────────────────
    testWidgets('shows empty shelf when no ebooks', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride([])));
      await tester.pumpAndSettle();

      expect(find.text('Your shelf is empty'), findsOneWidget);
    });

    // ── Data state ────────────────────────────────────────────
    testWidgets('shows ebook titles when data loads', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride(_fakeEbooks)));
      await tester.pumpAndSettle();

      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Refactoring'), findsOneWidget);
    });

    // ── Error state ───────────────────────────────────────────
    testWidgets('shows error widget on failure', (tester) async {
      await tester.pumpWidget(_wrap(_errorOverride('Network error')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Network error'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(_wrap(_errorOverride('Server offline')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('retry_button')), findsOneWidget);
    });

    // ── Navigation ────────────────────────────────────────────
    testWidgets('tapping search icon navigates to search', (tester) async {
      await tester.pumpWidget(_wrap(_dataOverride([])));
      await tester.pump();

      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();

      // Router pushed /search, LibraryScreen no longer on top
      expect(find.byType(LibraryScreen), findsNothing);
    });
  });
}
