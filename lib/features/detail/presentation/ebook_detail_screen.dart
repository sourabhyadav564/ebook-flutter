import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/ebook.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/providers/ebook_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../../../shared/utils/file_size_formatter.dart';
import 'package:intl/intl.dart';

class EbookDetailScreen extends ConsumerWidget {
  const EbookDetailScreen({super.key, required this.ebookId});
  final int ebookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebookAsync = ref.watch(ebookDetailProvider(ebookId));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: ebookAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(err.toString(), style: const TextStyle(color: AppColors.error)),
        ),
        data: (ebook) => _DetailBody(ebook: ebook),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.ebook});
  final Ebook ebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Hero cover app bar
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.surfaceDark,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(ebook.title, style: const TextStyle(fontSize: 14)),
            background: ebook.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: ebook.coverUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.surfaceDark, AppColors.bgDark],
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                      ),
                    ),
                    child: const Icon(Icons.auto_stories_rounded,
                        size: 80, color: AppColors.secondary),
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & author
                Text(ebook.title, style: Theme.of(context).textTheme.headlineMedium)
                    .animate().fadeIn(),
                if (ebook.author != null) ...[
                  const SizedBox(height: 4),
                  Text('by ${ebook.author}',
                      style: const TextStyle(color: AppColors.textSecondary))
                      .animate().fadeIn(delay: 100.ms),
                ],

                const SizedBox(height: 20),

                // Metadata chips
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    if (ebook.fileType != null)
                      _MetaChip(
                        icon:  Icons.description_rounded,
                        label: ebook.fileType!.toUpperCase(),
                        color: ebook.fileType == 'pdf'
                            ? AppColors.pdfBadge
                            : AppColors.epubBadge,
                      ),
                    if (ebook.fileSize != null)
                      _MetaChip(
                        icon:  Icons.data_usage_rounded,
                        label: FileSizeFormatter.format(ebook.fileSize!),
                        color: AppColors.secondary,
                      ),
                    if (ebook.uploadDate != null)
                      _MetaChip(
                        icon:  Icons.calendar_today_rounded,
                        label: DateFormat('MMM d, yyyy').format(ebook.uploadDate!),
                        color: AppColors.secondary,
                      ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                if (ebook.description != null) ...[
                  const SizedBox(height: 20),
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(ebook.description!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        key: const Key('read_button'),
                        onPressed: () => _openReader(context, ref, ebook),
                        icon:  const Icon(Icons.menu_book_rounded),
                        label: const Text('Read'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('download_button'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _download(context, ref, ebook),
                        icon:  const Icon(Icons.download_rounded),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('delete_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _confirmDelete(context, ref, ebook),
                    icon:  const Icon(Icons.delete_rounded),
                    label: const Text('Delete'),
                  ),
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openReader(BuildContext ctx, WidgetRef ref, Ebook ebook) {
    if (ebook.fileUrl == null) {
      showErrorSnackbar(ctx, 'File URL not available');
      return;
    }

    ctx.push(
      '/ebook/${ebook.id}/read',
      extra: {
        'path':   ebook.fileUrl,
        'name': ebook.title,
      },
    );
  }

  Future<void> _openEpubNatively(BuildContext ctx, WidgetRef ref, Ebook ebook) async {
    Directory? dir;
    try {
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
        }
      } else {
        dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
      }
    } catch (_) {}

    final path = '${dir?.path ?? ""}/${ebook.title}.${ebook.fileType ?? "epub"}';
    
    if (path.isNotEmpty) {
      final file = File(path);
      try {
        if (await file.exists()) {
          final result = await OpenFilex.open(path);
          if (result.type != ResultType.done && ctx.mounted) {
            showErrorSnackbar(ctx, 'Could not open EPUB: ${result.message}');
          }
          return;
        }
      } catch (_) {}
    }

    if (!ctx.mounted) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Downloading EPUB for reading...'),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(downloadProvider.notifier).download(ebook.id, path);
      if (ctx.mounted) {
        Navigator.of(ctx).pop(); // Dismiss loader
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done) {
          showErrorSnackbar(ctx, 'Could not open EPUB: ${result.message}');
        }
      }
    } catch (e) {
      if (ctx.mounted) {
        Navigator.of(ctx).pop(); // Dismiss loader
        showErrorSnackbar(ctx, 'Failed to open EPUB: $e');
      }
    }
  }

  Future<void> _download(BuildContext ctx, WidgetRef ref, Ebook ebook) async {
    Directory? dir;
    try {
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
        }
      } else {
        dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
      }
    } catch (_) {}

    final path = '${dir?.path ?? ""}/${ebook.title}.${ebook.fileType ?? "pdf"}';
    if (path.isNotEmpty) {
      final file = File(path);
      try {
        if (await file.exists()) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('File already downloaded to $path'),
              backgroundColor: AppColors.success,
            ),
          );
          return;
        }
      } catch (_) {}
    }

    if (!ctx.mounted) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Downloading ebook...'),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(downloadProvider.notifier).download(ebook.id, path);
      if (ctx.mounted) {
        Navigator.of(ctx).pop(); // Dismiss loader
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Downloaded to $path'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        Navigator.of(ctx).pop(); // Dismiss loader
        showErrorSnackbar(ctx, 'Download failed: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref, Ebook ebook) async {
    final confirmed = await showConfirmDialog(
      ctx,
      title:   'Delete "${ebook.title}"?',
      message: 'This will permanently remove the ebook from your library.',
    );
    if (confirmed != true) return;

    final ok = await ref.read(deleteProvider.notifier).delete(ebook.id, ref);
    if (ctx.mounted) {
      if (ok) {
        ctx.pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Ebook deleted'), backgroundColor: AppColors.success),
        );
      } else {
        showErrorSnackbar(ctx, 'Failed to delete ebook. Please try again.');
      }
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
