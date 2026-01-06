class BibleReading {
  final int? id;
  final int month;
  final int day;
  final String youtubeUrl;
  final String title;
  final String? chapterInfo;
  final bool isSpecial;

  BibleReading({
    this.id,
    required this.month,
    required this.day,
    required this.youtubeUrl,
    required this.title,
    this.chapterInfo,
    this.isSpecial = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'day': day,
      'youtube_url': youtubeUrl,
      'title': title,
      'chapter_info': chapterInfo,
      'is_special': isSpecial ? 1 : 0,
    };
  }

  factory BibleReading.fromMap(Map<String, dynamic> map) {
    return BibleReading(
      id: map['id'],
      month: map['month'],
      day: map['day'],
      youtubeUrl: map['youtube_url'],
      title: map['title'],
      chapterInfo: map['chapter_info'],
      isSpecial: map['is_special'] == 1,
    );
  }

  bool isAvailableForYear(int year) {
    if (month == 2 && day == 29) {
      return _isLeapYear(year);
    }
    return true;
  }

  bool _isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    if (year % 4 == 0) return true;
    return false;
  }
}

class BibleBook {
  final int? id;
  final int bookNumber;
  final String testament;
  final String koreanName;
  final String englishName;
  final String youtubeUrl;
  final String? author;
  final int chaptersCount;
  final String? summary;

  BibleBook({
    this.id,
    required this.bookNumber,
    required this.testament,
    required this.koreanName,
    required this.englishName,
    required this.youtubeUrl,
    this.author,
    required this.chaptersCount,
    this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_number': bookNumber,
      'testament': testament,
      'korean_name': koreanName,
      'english_name': englishName,
      'youtube_url': youtubeUrl,
      'author': author,
      'chapters_count': chaptersCount,
      'summary': summary,
    };
  }

  factory BibleBook.fromMap(Map<String, dynamic> map) {
    return BibleBook(
      id: map['id'],
      bookNumber: map['book_number'],
      testament: map['testament'],
      koreanName: map['korean_name'],
      englishName: map['english_name'],
      youtubeUrl: map['youtube_url'],
      author: map['author'],
      chaptersCount: map['chapters_count'],
      summary: map['summary'],
    );
  }
}

class ReadingHistory {
  final int? id;
  final int year;
  final int month;
  final int day;
  final bool isCompleted;
  final DateTime? completedAt;

  ReadingHistory({
    this.id,
    required this.year,
    required this.month,
    required this.day,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'day': day,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      id: map['id'],
      year: map['year'],
      month: map['month'],
      day: map['day'],
      isCompleted: map['is_completed'] == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }
}

class UserNote {
  final int? id;
  final int year;
  final int month;
  final int day;
  final String? verseReference;
  final String noteContent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserNote({
    this.id,
    required this.year,
    required this.month,
    required this.day,
    this.verseReference,
    required this.noteContent,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'day': day,
      'verse_reference': verseReference,
      'note_content': noteContent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserNote.fromMap(Map<String, dynamic> map) {
    return UserNote(
      id: map['id'],
      year: map['year'],
      month: map['month'],
      day: map['day'],
      verseReference: map['verse_reference'],
      noteContent: map['note_content'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}

class BookNote {
  final int? id;
  final int bookId;
  final String noteContent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookNote({
    this.id,
    required this.bookId,
    required this.noteContent,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'note_content': noteContent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BookNote.fromMap(Map<String, dynamic> map) {
    return BookNote(
      id: map['id'],
      bookId: map['book_id'],
      noteContent: map['note_content'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
