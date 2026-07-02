import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epub_view/epub_view.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/providers/ebook_providers.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.ebookId,
    required this.fileUrl,
    required this.title,
  });

  final int    ebookId;
  final String fileUrl;
  final String title;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  // PDF fields
  final _pdfKey        = GlobalKey<SfPdfViewerState>();
  final _pdfController = PdfViewerController();
  int   _currentPage   = 1;
  int   _totalPages    = 0;

  // EPUB fields
  EpubController? _epubController;
  bool            _loadingEpub   = false;
  String?         _epubError;

  bool  _fullScreen    = false;

  String get _prefKey => 'last_page_${widget.ebookId}';
  bool get _isPdf => widget.fileUrl.toLowerCase().contains('.pdf');

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _restoreLastPage();
    } else {
      _loadEpub();
    }
  }

  Future<void> _restoreLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final page  = prefs.getInt(_prefKey) ?? 1;
    if (page > 1) {
      setState(() => _currentPage = page);
    }
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, page);
  }

  Future<void> _loadEpub() async {
    setState(() {
      _loadingEpub = true;
      _epubError = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final tempPath = '${dir.path}/temp_${widget.ebookId}.epub';
      final file = File(tempPath);

      if (!await file.exists()) {
        await ref.read(ebookRepositoryProvider).download(widget.ebookId, tempPath);
      }

      final bytes = await file.readAsBytes();
      
      if (mounted) {
        _epubController = EpubController(
          document: EpubDocument.openData(bytes),
        );
        setState(() {
          _loadingEpub = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingEpub = false;
          _epubError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _fullScreen
          ? null
          : AppBar(
              title: _epubController != null
                  ? EpubViewActualChapter(
                      controller: _epubController!,
                      builder: (chapterValue) => Text(
                        chapterValue?.chapter?.Title?.trim() ?? widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                if (_isPdf && _totalPages > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        '$_currentPage / $_totalPages',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                IconButton(
                  key: const Key('fullscreen_button'),
                  icon: const Icon(Icons.fullscreen_rounded),
                  onPressed: () => setState(() => _fullScreen = true),
                ),
              ],
            ),
      drawer: (!_isPdf && _epubController != null)
          ? Drawer(
              child: SafeArea(
                child: EpubViewTableOfContents(controller: _epubController!),
              ),
            )
          : null,
      body: widget.fileUrl.trim().isEmpty
          ? const Center(
              child: Text(
                'Ebook file URL is invalid or empty.',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            )
          : _isPdf
              ? Stack(
                  children: [
                    SfPdfViewer.network(
                      widget.fileUrl,
                      key:        _pdfKey,
                      controller: _pdfController,
                      initialScrollOffset: Offset.zero,
                      onDocumentLoaded: (details) {
                        setState(() => _totalPages = details.document.pages.count);
                        if (_currentPage > 1) {
                          _pdfController.jumpToPage(_currentPage);
                        }
                      },
                      onPageChanged: (details) {
                        setState(() => _currentPage = details.newPageNumber);
                        _saveLastPage(details.newPageNumber);
                      },
                    ),

                    if (_fullScreen)
                      Positioned(
                        top:   MediaQuery.of(context).padding.top + 8,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag:          'exit_fs',
                          backgroundColor:  Colors.black54,
                          onPressed:        () => setState(() => _fullScreen = false),
                          child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                        ),
                      ),
                  ],
                )
              : _loadingEpub
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Loading EPUB book...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : _epubError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Error: $_epubError',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            EpubView(
                              controller: _epubController!,
                            ),

                            if (_fullScreen)
                              Positioned(
                                top:   MediaQuery.of(context).padding.top + 8,
                                right: 16,
                                child: FloatingActionButton.small(
                                  heroTag:          'exit_fs',
                                  backgroundColor:  Colors.black54,
                                  onPressed:        () => setState(() => _fullScreen = false),
                                  child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
    );
  }
}
