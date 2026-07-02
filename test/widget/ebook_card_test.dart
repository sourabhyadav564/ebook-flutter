import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../lib/core/models/ebook.dart';
import '../../lib/features/library/presentation/ebook_card.dart';

// Minimal router needed for GestureDetector → context.push
final _testRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const _Scaffold()),
    GoRoute(path: '/ebook/:id', builder: (_, __) => const SizedBox()),
  ],
);

class _Scaffold extends StatelessWidget {
  const _Scaffold();
  @override
  Widget build(BuildContext context) => const SizedBox();
}

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp.router(
    routerConfig: _testRouter,
    builder: (_, __) => Scaffold(body: SizedBox(height: 200, child: child)),
  ),
);

const _pdfEbook = Ebook(
  id:         1,
  title:      'Clean Code',
  author:     'Robert C. Martin',
  fileType:   'pdf',
  fileSize:   2048000,
  uploadDate: null,
  coverUrl:   null,
);

const _noAuthorEbook = Ebook(
  id:       2,
  title:    'Unknown Book',
  fileType: 'epub',
  fileSize: 512000,
);

void main() {
  group('EbookCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(EbookCard(ebook: _pdfEbook)));
      expect(find.text('Clean Code'), findsOneWidget);
    });

    testWidgets('renders author when available', (tester) async {
      await tester.pumpWidget(_wrap(EbookCard(ebook: _pdfEbook)));
      expect(find.text('Robert C. Martin'), findsOneWidget);
    });

    testWidgets('shows PDF badge for pdf type', (tester) async {
      await tester.pumpWidget(_wrap(EbookCard(ebook: _pdfEbook)));
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('shows EPUB badge for epub type', (tester) async {
      await tester.pumpWidget(_wrap(EbookCard(ebook: _noAuthorEbook)));
      expect(find.text('EPUB'), findsOneWidget);
    });

    testWidgets('shows placeholder icon when no cover', (tester) async {
      await tester.pumpWidget(_wrap(EbookCard(ebook: _pdfEbook)));
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
    });
  });
}
