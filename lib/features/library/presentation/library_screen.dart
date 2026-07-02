import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/ebook_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/ebook.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../upload/presentation/upload_sheet.dart';
import 'shelf_widget.dart';
import 'empty_shelf.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebooksAsync = ref.watch(
      ebooksProvider(const EbooksFilter()),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('📚 My Library'),
        actions: [
          IconButton(
            key: const Key('search_button'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search ebooks',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('upload_fab'),
        onPressed: () => _showUpload(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
      ).animate().slideY(begin: 1, duration: 400.ms).fadeIn(),
      body: ebooksAsync.when(
        loading: () => const _ShimmerShelf(),
        error:   (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(ebooksProvider(const EbooksFilter())),
        ),
        data:    (ebooks) => ebooks.isEmpty
            ? const EmptyShelf()
            : ShelfWidget(ebooks: ebooks),
      ),
    );
  }

  void _showUpload(BuildContext ctx, WidgetRef ref) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadSheet(onUploaded: () {
        ref.refresh(ebooksProvider(const EbooksFilter()));
      }),
    );
  }
}

// ─── Shimmer placeholder while loading ────────────────────
class _ShimmerShelf extends StatelessWidget {
  const _ShimmerShelf();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: AppColors.accent.withOpacity(0.15)),
    );
  }
}
