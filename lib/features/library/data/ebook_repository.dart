import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/models/ebook.dart';

class EbookRepository {
  const EbookRepository(this._client);
  final ApiClient _client;

  Future<List<Ebook>> fetchAll({String? query, String? sort, String? type}) =>
      _client.getEbooks(query: query, sort: sort, type: type);

  Future<List<Ebook>> search(String query) =>
      _client.searchEbooks(query);

  Future<Ebook> fetchOne(int id) => _client.getEbook(id);

  Future<Ebook> upload({
    required String title,
    String? author,
    String? description,
    required File file,
    File? cover,
    void Function(int, int)? onProgress,
  }) => _client.uploadEbook(
    title:       title,
    author:      author,
    description: description,
    file:        file,
    cover:       cover,
    onProgress:  onProgress,
  );

  Future<String> download(int id, String savePath) =>
      _client.downloadEbook(id, savePath);

  Future<void> delete(int id) => _client.deleteEbook(id);
}
