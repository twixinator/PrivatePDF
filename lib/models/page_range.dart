/// Represents a range of pages to extract from a PDF
/// Supports various formats: "1-3,5,7-9"
class PageRange {
  final List<int> pages;

  const PageRange(this.pages);

  /// Parse a page range string like "1-3,5,7-9" into individual page numbers
  /// Page numbers are 1-indexed
  factory PageRange.parse(String input, int maxPages) {
    if (input.trim().isEmpty) {
      throw FormatException('Page range cannot be empty');
    }

    final pages = <int>{};
    final parts = input.split(',');

    for (final part in parts) {
      final trimmed = part.trim();

      if (trimmed.contains('-')) {
        // Range format: "1-3"
        final rangeParts = trimmed.split('-');
        if (rangeParts.length != 2) {
          throw FormatException('Invalid range format: $trimmed');
        }

        final start = int.tryParse(rangeParts[0].trim());
        final end = int.tryParse(rangeParts[1].trim());

        if (start == null || end == null) {
          throw FormatException('Invalid numbers in range: $trimmed');
        }

        if (start < 1 || end > maxPages || start > end) {
          throw FormatException(
            'Range $start-$end is invalid (valid: 1-$maxPages)',
          );
        }

        for (int i = start; i <= end; i++) {
          pages.add(i);
        }
      } else {
        // Single page: "5"
        final page = int.tryParse(trimmed);
        if (page == null) {
          throw FormatException('Invalid page number: $trimmed');
        }

        if (page < 1 || page > maxPages) {
          throw FormatException(
            'Page $page is out of range (valid: 1-$maxPages)',
          );
        }

        pages.add(page);
      }
    }

    if (pages.isEmpty) {
      throw FormatException('No valid pages found');
    }

    // Return sorted unique pages
    final sortedPages = pages.toList()..sort();
    return PageRange(sortedPages);
  }

  /// Create PageRange from all pages
  factory PageRange.all(int totalPages) {
    return PageRange(List.generate(totalPages, (i) => i + 1));
  }

  /// Create PageRange from a single page
  factory PageRange.single(int page) {
    return PageRange([page]);
  }

  /// Validate if all pages are within the total page count
  bool isValid(int totalPages) {
    return pages.every((page) => page >= 1 && page <= totalPages);
  }

  /// Get formatted string representation (e.g., "1-3, 5, 7-9")
  String get formatted {
    if (pages.isEmpty) return '';
    if (pages.length == 1) return pages.first.toString();

    final ranges = <String>[];
    int? rangeStart;
    int? rangeEnd;

    for (int i = 0; i < pages.length; i++) {
      final current = pages[i];

      if (rangeStart == null) {
        rangeStart = current;
        rangeEnd = current;
      } else if (current == rangeEnd! + 1) {
        rangeEnd = current;
      } else {
        // End of range
        if (rangeStart == rangeEnd) {
          ranges.add(rangeStart.toString());
        } else {
          ranges.add('$rangeStart-$rangeEnd');
        }
        rangeStart = current;
        rangeEnd = current;
      }
    }

    // Add final range
    if (rangeStart != null && rangeEnd != null) {
      if (rangeStart == rangeEnd) {
        ranges.add(rangeStart.toString());
      } else {
        ranges.add('$rangeStart-$rangeEnd');
      }
    }

    return ranges.join(', ');
  }

  /// Get page count
  int get pageCount => pages.length;

  /// Check if range is empty
  bool get isEmpty => pages.isEmpty;

  /// Convert to 0-indexed pages for pdf-lib
  List<int> toZeroIndexed() {
    return pages.map((page) => page - 1).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageRange &&
          runtimeType == other.runtimeType &&
          _listEquals(pages, other.pages);

  @override
  int get hashCode => Object.hashAll(pages);

  @override
  String toString() {
    return 'PageRange{pages: $formatted, count: $pageCount}';
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
