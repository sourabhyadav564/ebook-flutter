import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/ebook.dart';
import '../../../core/theme/app_colors.dart';
import 'ebook_card.dart';

/// Classic iOS-inspired bookshelf: books stand as spines on wooden shelves.
class ShelfWidget extends StatelessWidget {
  const ShelfWidget({super.key, required this.ebooks});

  final List<Ebook> ebooks;

  static const _booksPerShelf = 4;

  @override
  Widget build(BuildContext context) {
    final shelves = <List<Ebook>>[];
    for (var i = 0; i < ebooks.length; i += _booksPerShelf) {
      shelves.add(
        ebooks.sublist(i, (i + _booksPerShelf).clamp(0, ebooks.length)),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [AppColors.bgDark, Color(0xFF0F0A08)],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemCount: shelves.length,
        itemBuilder: (ctx, shelfIdx) => _ShelfRow(
          books:     shelves[shelfIdx],
          shelfIndex: shelfIdx,
        ),
      ),
    );
  }
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({required this.books, required this.shelfIndex});

  final List<Ebook> books;
  final int         shelfIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Books sitting on shelf
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...books.asMap().entries.map((e) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: EbookCard(ebook: e.value)
                      .animate(delay: Duration(milliseconds: 80 * e.key))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, duration: 400.ms),
                ),
              )),
              // Fill empty slots with blank spines
              ...List.generate(
                (4 - books.length).clamp(0, 4),
                (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        ),

        // Wooden shelf plank
        Container(
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B3F1F), Color(0xFF8B5E3C), Color(0xFF5A3010)],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }
}
