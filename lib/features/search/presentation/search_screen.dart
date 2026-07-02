import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/providers/ebook_providers.dart';
import '../../library/presentation/ebook_card.dart';
import '../../../core/models/ebook.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _selectedType = 'All';
  String _selectedSort = 'Recent';

  static const _types = ['All', 'PDF', 'EPUB'];
  static const _sorts = ['Recent', 'Title', 'Author'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Debounce via provider update
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_ctrl.text == value) {
        ref.read(searchQueryProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: TextField(
          key: const Key('search_field'),
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText:  'Search by title or author…',
            border:    InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _ctrl.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter & sort chips
          _FiltersBar(
            selectedType: _selectedType,
            selectedSort: _selectedSort,
            onTypeChanged: (t) => setState(() => _selectedType = t),
            onSortChanged: (s) => setState(() => _selectedSort = s),
          ),

          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text(err.toString(),
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (results) {
                // Apply local type filter and sort
                var filtered = results.where((e) {
                  if (_selectedType == 'All') return true;
                  return e.fileType?.toLowerCase() ==
                      _selectedType.toLowerCase();
                }).toList();

                filtered.sort((a, b) {
                  return switch (_selectedSort) {
                    'Title'  => (a.title).compareTo(b.title),
                    'Author' => (a.author ?? '').compareTo(b.author ?? ''),
                    _        => (b.uploadDate ?? DateTime(0))
                        .compareTo(a.uploadDate ?? DateTime(0)),
                  };
                });

                if (ref.watch(searchQueryProvider).isEmpty) {
                  return const _SearchHint();
                }

                if (filtered.isEmpty) {
                  return const _NoResults();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _SearchResultTile(ebook: filtered[i])
                      .animate(delay: Duration(milliseconds: 40 * i))
                      .fadeIn()
                      .slideX(begin: 0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.selectedType,
    required this.selectedSort,
    required this.onTypeChanged,
    required this.onSortChanged,
  });
  final String selectedType, selectedSort;
  final ValueChanged<String> onTypeChanged, onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...['All', 'PDF', 'EPUB'].map((t) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              key: Key('type_$t'),
              label: Text(t),
              selected: selectedType == t,
              onSelected: (_) => onTypeChanged(t),
            ),
          )),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: selectedSort,
            onSelected: onSortChanged,
            color: AppColors.cardDark,
            child: Chip(
              avatar: const Icon(Icons.sort_rounded, size: 16),
              label: Text(selectedSort),
            ),
            itemBuilder: (_) => ['Recent', 'Title', 'Author']
                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.ebook});
  final Ebook ebook;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('search_result_${ebook.id}'),
      tileColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: SizedBox(
        width: 40,
        height: 60,
        child: EbookCard(ebook: ebook),
      ),
      title:    Text(ebook.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(ebook.author ?? 'Unknown author'),
      trailing: Text(
        ebook.fileType?.toUpperCase() ?? '',
        style: TextStyle(
          color:      ebook.fileType == 'pdf' ? AppColors.pdfBadge : AppColors.epubBadge,
          fontWeight: FontWeight.w700,
          fontSize:   12,
        ),
      ),
      onTap: () => context.push('/ebook/${ebook.id}'),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('No ebooks found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Try a different keyword', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 64, color: AppColors.secondary),
          SizedBox(height: 16),
          Text('Type to search', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
