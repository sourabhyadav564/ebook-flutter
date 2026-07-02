import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'endpoints.dart';
import '../models/ebook.dart';

class ApiClient {
  ApiClient._() : _dio = _buildDio();

  static final ApiClient instance = ApiClient._();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
    dio.interceptors.add(_ErrorInterceptor());
    return dio;
  }

  // ── GET /api/ebooks ──────────────────────────────────
  Future<List<Ebook>> getEbooks({
    String? query,
    String? sort,
    String? type,
    int page = 1,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.ebooks,
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (sort != null) 'sort': sort,
        if (type != null) 'type': type,
        'page': page,
      },
    );
    final data = resp.data;
    final List list;
    if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    return list.map((e) => Ebook.fromJson(e)).toList();
  }

  // ── GET /api/ebooks/search ───────────────────────────
  Future<List<Ebook>> searchEbooks(String query) async {
    final resp = await _dio.get(
      ApiEndpoints.search,
      queryParameters: {'q': query},
    );
    final data = resp.data;
    final List list;
    if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    return list.map((e) => Ebook.fromJson(e)).toList();
  }

  // ── GET /api/ebooks/:id ──────────────────────────────
  Future<Ebook> getEbook(int id) async {
    final resp = await _dio.get(ApiEndpoints.ebook(id));
    return Ebook.fromJson(resp.data);
  }

  // ── POST /api/ebooks ─────────────────────────────────
  Future<Ebook> uploadEbook({
    required String title,
    String? author,
    String? description,
    required File file,
    File? cover,
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'ebook[title]':  title,
      if (author != null)      'ebook[author]':      author,
      if (description != null) 'ebook[description]': description,
      'ebook[file]': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      if (cover != null)
        'ebook[cover]': await MultipartFile.fromFile(
          cover.path,
          filename: cover.path.split('/').last,
        ),
    });

    final resp = await _dio.post(
      ApiEndpoints.ebooks,
      data: formData,
      onSendProgress: onProgress,
    );
    return Ebook.fromJson(resp.data);
  }

  // ── GET /api/ebooks/:id/download ─────────────────────
  Future<String> downloadEbook(int id, String savePath) async {
    await _dio.download(
      ApiEndpoints.download(id),
      savePath,
      options: Options(followRedirects: true, validateStatus: (s) => s! < 500),
    );
    return savePath;
  }

  // ── DELETE /api/ebooks/:id ───────────────────────────
  Future<void> deleteEbook(int id) async {
    await _dio.delete(ApiEndpoints.delete(id));
  }
}

// ────────────────────────────────────────────────────────────
// Error interceptor — maps DioException to friendly messages
// ────────────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final friendly = switch (err.type) {
      DioExceptionType.connectionTimeout  => 'Connection timed out. Check your network.',
      DioExceptionType.receiveTimeout     => 'Server took too long to respond.',
      DioExceptionType.connectionError    => 'Cannot connect to server. Is it running?',
      DioExceptionType.badResponse        => _fromStatusCode(err.response?.statusCode),
      _                                   => 'Unexpected error: ${err.message}',
    };
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response:       err.response,
      type:           err.type,
      message:        friendly,
    ));
  }

  String _fromStatusCode(int? code) => switch (code) {
    400 => 'Bad request.',
    404 => 'Not found.',
    422 => 'Validation error.',
    500 => 'Server error. Try again later.',
    _   => 'Request failed (HTTP $code).',
  };
}
