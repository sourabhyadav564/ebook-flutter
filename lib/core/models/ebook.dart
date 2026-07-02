class Ebook {
  final int id;
  final String title;
  final String? author;
  final String? fileType;
  final int? fileSize;
  final DateTime? uploadDate;
  final String? coverUrl;
  final String? fileUrl;
  final String? downloadUrl;
  final String? description;

  const Ebook({
    required this.id,
    required this.title,
    this.author,
    this.fileType,
    this.fileSize,
    this.uploadDate,
    this.coverUrl,
    this.fileUrl,
    this.downloadUrl,
    this.description,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadDate: json['upload_date'] != null
          ? DateTime.parse(json['upload_date'] as String)
          : null,
      coverUrl: json['cover_url'] as String?,
      fileUrl: json['file_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'file_type': fileType,
      'file_size': fileSize,
      'upload_date': uploadDate?.toIso8601String(),
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'download_url': downloadUrl,
      'description': description,
    };
  }

  Ebook copyWith({
    int? id,
    String? title,
    String? author,
    String? fileType,
    int? fileSize,
    DateTime? uploadDate,
    String? coverUrl,
    String? fileUrl,
    String? downloadUrl,
    String? description,
  }) {
    return Ebook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ebook &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          author == other.author &&
          fileType == other.fileType &&
          fileSize == other.fileSize &&
          uploadDate == other.uploadDate &&
          coverUrl == other.coverUrl &&
          fileUrl == other.fileUrl &&
          downloadUrl == other.downloadUrl &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      author.hashCode ^
      fileType.hashCode ^
      fileSize.hashCode ^
      uploadDate.hashCode ^
      coverUrl.hashCode ^
      fileUrl.hashCode ^
      downloadUrl.hashCode ^
      description.hashCode;
}
