import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/detail/presentation/ebook_detail_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'library',
        builder: (ctx, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (ctx, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/ebook/:id',
        name: 'detail',
        builder: (ctx, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EbookDetailScreen(ebookId: id);
        },
      ),
      GoRoute(
        path: '/ebook/:id/read',
        name: 'reader',
        builder: (ctx, state) {
          final id      = int.parse(state.pathParameters['id']!);
          print('GoRouter builder ebook/:id/read: id=$id, extra=${state.extra} (${state.extra?.runtimeType}), query=${state.uri.queryParameters}');
          final extra   = state.extra as Map?;
          final fileUrl = extra?['url']?.toString() ?? extra?['path']?.toString() ?? state.uri.queryParameters['url'] ?? '';
          final title   = extra?['title']?.toString() ?? extra?['name']?.toString() ?? state.uri.queryParameters['title'] ?? 'Ebook';
          print('GoRouter builder resolved: fileUrl=$fileUrl, title=$title');
          return ReaderScreen(ebookId: id, fileUrl: fileUrl, title: title);
        },
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
