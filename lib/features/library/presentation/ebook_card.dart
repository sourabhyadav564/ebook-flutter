import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/ebook.dart';
import '../../../core/theme/app_colors.dart';

class EbookCard extends StatelessWidget {
  const EbookCard({super.key, required this.ebook});

  final Ebook ebook;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ebook/${ebook.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover image or generated cover
              ebook.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: ebook.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _PlaceholderCover(ebook: ebook),
                      errorWidget:   (_, __, ___) => _PlaceholderCover(ebook: ebook),
                    )
                  : _PlaceholderCover(ebook: ebook),

              // File type badge
              Positioned(
                top:   6,
                right: 6,
                child: _FileTypeBadge(type: ebook.fileType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gradient placeholder cover with title ────────────────
class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.ebook});

  final Ebook ebook;

  static const _coverColors = [
    [Color(0xFF8E3434), Color(0xFF4A1010)],
    [Color(0xFF2D5A8B), Color(0xFF0D2B4D)],
    [Color(0xFF3B7A57), Color(0xFF1A3D2A)],
    [Color(0xFF7B5EA7), Color(0xFF3A2060)],
    [Color(0xFF8B6914), Color(0xFF4A3500)],
    [Color(0xFF5A7A8B), Color(0xFF1E3A47)],
  ];

  @override
  Widget build(BuildContext context) {
    final colorPair = _coverColors[ebook.id % _coverColors.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: colorPair,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white38, size: 28),
          const SizedBox(height: 8),
          Text(
            ebook.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color:      Colors.white,
              fontSize:   10,
              fontWeight: FontWeight.w700,
              height:     1.3,
            ),
          ),
          if (ebook.author != null) ...[
            const SizedBox(height: 4),
            Text(
              ebook.author!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color:    Colors.white54,
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── File type badge ──────────────────────────────────────
class _FileTypeBadge extends StatelessWidget {
  const _FileTypeBadge({required this.type});
  final String? type;

  @override
  Widget build(BuildContext context) {
    if (type == null) return const SizedBox.shrink();
    final isPdf  = type!.toLowerCase() == 'pdf';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color:        isPdf ? AppColors.pdfBadge : AppColors.epubBadge,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type!.toUpperCase(),
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
