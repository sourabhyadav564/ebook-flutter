import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/ebook.dart';
import '../data/ebook_repository.dart';

// ─── Repository Provider ───────────────────────────────────
final ebookRepositoryProvider = Provider<EbookRepository>(
  (ref) => EbookRepository(ApiClient.instance),
);

// ─── Library List ──────────────────────────────────────────
final ebooksProvider = FutureProvider.family<List<Ebook>, EbooksFilter>(
  (ref, filter) => ref.watch(ebookRepositoryProvider).fetchAll(
    query: filter.query,
    sort:  filter.sort,
    type:  filter.type,
  ),
);

class EbooksFilter {
  const EbooksFilter({this.query, this.sort, this.type});
  final String? query;
  final String? sort;
  final String? type;

  @override
  bool operator ==(Object other) =>
      other is EbooksFilter &&
      other.query == query &&
      other.sort == sort &&
      other.type == type;

  @override
  int get hashCode => Object.hash(query, sort, type);
}

// ─── Search ────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Ebook>>((ref) {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return Future.value([]);
  return ref.watch(ebookRepositoryProvider).search(q);
});

// ─── Single Ebook ──────────────────────────────────────────
final ebookDetailProvider = FutureProvider.family<Ebook, int>(
  (ref, id) => ref.watch(ebookRepositoryProvider).fetchOne(id),
);

// ─── Upload Notifier ───────────────────────────────────────
class UploadState {
  const UploadState({
    this.isUploading = false,
    this.progress    = 0.0,
    this.error,
    this.uploaded,
  });

  final bool    isUploading;
  final double  progress;
  final String? error;
  final Ebook?  uploaded;

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
    Ebook? uploaded,
  }) => UploadState(
    isUploading: isUploading ?? this.isUploading,
    progress:    progress    ?? this.progress,
    error:       error,
    uploaded:    uploaded    ?? this.uploaded,
  );
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._repo) : super(const UploadState());

  final EbookRepository _repo;

  Future<bool> upload({
    required String title,
    String? author,
    String? description,
    required File file,
    File? cover,
  }) async {
    state = const UploadState(isUploading: true, progress: 0);
    try {
      final ebook = await _repo.upload(
        title:       title,
        author:      author,
        description: description,
        file:        file,
        cover:       cover,
        onProgress:  (sent, total) {
          state = state.copyWith(progress: sent / total);
        },
      );
      state = UploadState(uploaded: ebook);
      return true;
    } catch (e) {
      state = UploadState(error: e.toString());
      return false;
    }
  }

  void reset() => state = const UploadState();
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref.watch(ebookRepositoryProvider)),
);

// ─── Download Notifier ─────────────────────────────────────
class DownloadNotifier extends StateNotifier<AsyncValue<String?>> {
  DownloadNotifier(this._repo) : super(const AsyncValue.data(null));

  final EbookRepository _repo;

  Future<void> download(int id, String savePath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.download(id, savePath));
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, AsyncValue<String?>>(
  (ref) => DownloadNotifier(ref.watch(ebookRepositoryProvider)),
);

// ─── Delete Notifier ───────────────────────────────────────
class DeleteNotifier extends StateNotifier<AsyncValue<void>> {
  DeleteNotifier(this._repo) : super(const AsyncValue.data(null));

  final EbookRepository _repo;

  Future<bool> delete(int id, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      state = const AsyncValue.data(null);
      // Invalidate library so it reloads
      ref.invalidate(ebooksProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final deleteProvider =
    StateNotifierProvider<DeleteNotifier, AsyncValue<void>>(
  (ref) => DeleteNotifier(ref.watch(ebookRepositoryProvider)),
);
