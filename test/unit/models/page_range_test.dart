import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/page_range.dart';

/// Comprehensive PageRange model tests
/// Target: 100% code coverage
void main() {
  group('PageRange.parse', () {
    test('parses single page', () {
      final range = PageRange.parse('5', 10);
      expect(range.pages, [5]);
      expect(range.pageCount, 1);
    });

    test('parses simple range', () {
      final range = PageRange.parse('1-3', 10);
      expect(range.pages, [1, 2, 3]);
      expect(range.pageCount, 3);
    });

    test('parses complex range', () {
      final range = PageRange.parse('1-3,5,7-9', 10);
      expect(range.pages, [1, 2, 3, 5, 7, 8, 9]);
      expect(range.pageCount, 7);
    });

    test('removes duplicates and sorts', () {
      final range = PageRange.parse('5,1-3,2', 10);
      expect(range.pages, [1, 2, 3, 5]);
    });

    test('handles whitespace in input', () {
      final range = PageRange.parse(' 1 - 3 , 5 , 7 - 9 ', 10);
      expect(range.pages, [1, 2, 3, 5, 7, 8, 9]);
    });

    test('throws on empty string', () {
      expect(
        () => PageRange.parse('', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          'Page range cannot be empty',
        )),
      );
    });

    test('throws on whitespace-only string', () {
      expect(
        () => PageRange.parse('   ', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          'Page range cannot be empty',
        )),
      );
    });

    test('throws on page out of range (too high)', () {
      expect(
        () => PageRange.parse('11', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('out of range'),
        )),
      );
    });

    test('throws on page out of range (zero)', () {
      expect(
        () => PageRange.parse('0', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('out of range'),
        )),
      );
    });

    test('throws on invalid range (start > end)', () {
      expect(
        () => PageRange.parse('5-3', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('invalid'),
        )),
      );
    });

    test('throws on non-numeric input', () {
      expect(
        () => PageRange.parse('abc', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Invalid page number'),
        )),
      );
    });

    test('throws on invalid range format (multiple dashes)', () {
      expect(
        () => PageRange.parse('1-3-5', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Invalid range format'),
        )),
      );
    });

    test('throws on range end out of bounds', () {
      expect(
        () => PageRange.parse('8-12', 10),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('invalid'),
        )),
      );
    });

    test('handles single page at max boundary', () {
      final range = PageRange.parse('10', 10);
      expect(range.pages, [10]);
    });

    test('handles range at boundaries', () {
      final range = PageRange.parse('1-10', 10);
      expect(range.pages, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });
  });

  group('PageRange.formatted', () {
    test('formats single page', () {
      expect(PageRange([5]).formatted, '5');
    });

    test('formats consecutive range', () {
      expect(PageRange([1, 2, 3]).formatted, '1-3');
    });

    test('formats mixed ranges and singles', () {
      expect(PageRange([1, 2, 3, 5, 7, 8, 9]).formatted, '1-3, 5, 7-9');
    });

    test('formats non-consecutive pages', () {
      expect(PageRange([1, 3, 5, 7]).formatted, '1, 3, 5, 7');
    });

    test('formats empty range', () {
      expect(PageRange([]).formatted, '');
    });

    test('formats two consecutive pages as range', () {
      expect(PageRange([5, 6]).formatted, '5-6');
    });
  });

  group('PageRange.toZeroIndexed', () {
    test('converts 1-indexed to 0-indexed', () {
      final range = PageRange([1, 2, 3]);
      expect(range.toZeroIndexed(), [0, 1, 2]);
    });

    test('converts empty range', () {
      final range = PageRange([]);
      expect(range.toZeroIndexed(), []);
    });

    test('converts single page', () {
      final range = PageRange([5]);
      expect(range.toZeroIndexed(), [4]);
    });
  });

  group('PageRange.isValid', () {
    test('returns true for valid range', () {
      final range = PageRange([1, 2, 3]);
      expect(range.isValid(10), true);
    });

    test('returns false for out of range pages', () {
      final range = PageRange([1, 2, 11]);
      expect(range.isValid(10), false);
    });

    test('returns false for zero page', () {
      final range = PageRange([0, 1, 2]);
      expect(range.isValid(10), false);
    });

    test('returns true for single valid page', () {
      final range = PageRange([5]);
      expect(range.isValid(10), true);
    });
  });

  group('PageRange factory constructors', () {
    test('PageRange.all creates all pages', () {
      final range = PageRange.all(5);
      expect(range.pages, [1, 2, 3, 4, 5]);
      expect(range.pageCount, 5);
    });

    test('PageRange.single creates single page', () {
      final range = PageRange.single(3);
      expect(range.pages, [3]);
      expect(range.pageCount, 1);
    });

    test('PageRange direct constructor', () {
      final range = PageRange([2, 4, 6]);
      expect(range.pages, [2, 4, 6]);
      expect(range.pageCount, 3);
    });
  });

  group('PageRange properties', () {
    test('pageCount returns correct count', () {
      expect(PageRange([1, 2, 3]).pageCount, 3);
      expect(PageRange([5]).pageCount, 1);
      expect(PageRange([]).pageCount, 0);
    });

    test('isEmpty returns correct value', () {
      expect(PageRange([]).isEmpty, true);
      expect(PageRange([1]).isEmpty, false);
      expect(PageRange([1, 2, 3]).isEmpty, false);
    });
  });

  group('PageRange equality', () {
    test('equal ranges are equal', () {
      final range1 = PageRange([1, 2, 3]);
      final range2 = PageRange([1, 2, 3]);
      expect(range1, equals(range2));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('different ranges are not equal', () {
      final range1 = PageRange([1, 2, 3]);
      final range2 = PageRange([1, 2, 4]);
      expect(range1, isNot(equals(range2)));
    });

    test('identical ranges are equal', () {
      final range = PageRange([1, 2, 3]);
      expect(range, equals(range));
    });

    test('empty ranges are equal', () {
      final range1 = PageRange([]);
      final range2 = PageRange([]);
      expect(range1, equals(range2));
    });
  });

  group('PageRange toString', () {
    test('toString includes formatted pages and count', () {
      final range = PageRange([1, 2, 3, 5]);
      final str = range.toString();
      expect(str, contains('PageRange'));
      expect(str, contains('1-3, 5'));
      expect(str, contains('count: 4'));
    });

    test('toString for empty range', () {
      final range = PageRange([]);
      final str = range.toString();
      expect(str, contains('PageRange'));
      expect(str, contains('count: 0'));
    });
  });
}
