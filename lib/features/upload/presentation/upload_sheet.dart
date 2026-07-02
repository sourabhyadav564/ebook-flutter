import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/providers/ebook_providers.dart';
import '../../../shared/widgets/error_snackbar.dart';

class UploadSheet extends ConsumerStatefulWidget {
  const UploadSheet({super.key, required this.onUploaded});
  final VoidCallback onUploaded;

  @override
  ConsumerState<UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<UploadSheet> {
  static const _maxFileSizeBytes = 50 * 1024 * 1024; // 50 MB

  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();

  File? _selectedFile;
  String? _fileName;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );
    if (result == null || result.files.single.path == null) return;

    final pickedFile = File(result.files.single.path!);
    final fileSize   = await pickedFile.length();

    if (fileSize > _maxFileSizeBytes) {
      if (mounted) {
        showErrorSnackbar(
          context,
          'File is too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB). '
          'Maximum allowed size is 50 MB.',
        );
      }
      return;
    }

    setState(() {
      _selectedFile = pickedFile;
      _fileName     = result.files.single.name;
      // Pre-fill title from filename if empty
      if (_titleCtrl.text.isEmpty) {
        _titleCtrl.text = result.files.single.name
            .replaceAll(RegExp(r'\.(pdf|epub)$', caseSensitive: false), '')
            .replaceAll('_', ' ')
            .replaceAll('-', ' ');
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      showErrorSnackbar(context, 'Please select a PDF or EPUB file');
      return;
    }

    final ok = await ref.read(uploadProvider.notifier).upload(
      title:  _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      file:   _selectedFile!,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onUploaded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ebook uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Ebook', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),

              // File picker
              GestureDetector(
                key: const Key('file_picker_area'),
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFile != null
                          ? AppColors.success
                          : AppColors.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.cardDark,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFile != null
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        color: _selectedFile != null
                            ? AppColors.success
                            : AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fileName ?? 'Tap to select PDF or EPUB',
                          style: TextStyle(
                            color: _selectedFile != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                key: const Key('title_field'),
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: Icon(Icons.book_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),

              // Author
              TextFormField(
                key: const Key('author_field'),
                controller: _authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Author (optional)',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                key: const Key('description_field'),
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Progress bar
              if (uploadState.isUploading) ...[
                LinearProgressIndicator(
                  value: uploadState.progress > 0 ? uploadState.progress : null,
                  backgroundColor: AppColors.cardDark,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  uploadState.progress > 0
                      ? 'Uploading ${(uploadState.progress * 100).toStringAsFixed(0)}%...'
                      : 'Uploading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
              ],

              // Error
              if (uploadState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Text(
                    uploadState.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Submit button
              ElevatedButton.icon(
                key: const Key('upload_button'),
                onPressed: uploadState.isUploading ? null : _submit,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Upload Ebook'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
