import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/features/links/models/link_model.dart';

void main() {
  group('LinkModel Test', () {
    test('URL Normalization without https://', () {
      final link = LinkModel(name: 'Google', url: 'google.com');
      expect(link.normalizedUrl, 'https://google.com');
    });

    test('URL Normalization with https:// already', () {
      final link = LinkModel(name: 'GitHub', url: 'https://github.com/kern1028');
      expect(link.normalizedUrl, 'https://github.com/kern1028');
    });

    test('Initial letter fallback', () {
      final link = LinkModel(name: 'Wikipedia', url: 'wikipedia.org');
      expect(link.initialLetter, 'W');
    });
  });
}
