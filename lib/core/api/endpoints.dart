class ApiEndpoints {
  ApiEndpoints._();

  static const _base = 'https://web-production-57e33c.up.railway.app/api';

  static const ebooks         = '$_base/ebooks';
  static String ebook(int id) => '$_base/ebooks/$id';
  static String download(int id) => '$_base/ebooks/$id/download';
  static String delete(int id)   => '$_base/ebooks/$id';
  static const search           = '$_base/ebooks/search';
}
