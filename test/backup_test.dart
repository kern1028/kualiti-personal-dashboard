import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/features/backup/backup_provider.dart';

void main() {
  group('BackupProvider Test', () {
    test('Filename sanitization test', () {
      expect(
        LocalFileBackupProvider.sanitizeFileName('Rina'),
        'kualitiRinabackup.json',
      );
      expect(
        LocalFileBackupProvider.sanitizeFileName('Asep 123!'),
        'kualitiAsep123backup.json',
      );
      expect(
        LocalFileBackupProvider.sanitizeFileName(''),
        'kualitibackup.json',
      );
    });

    test('Read JSON backup validation test', () async {
      final provider = LocalFileBackupProvider();

      const validJson = '''
      {
        "app": "kualiti",
        "schemaVersion": 1,
        "createdAt": "2026-10-10T12:00:00Z",
        "user": { "name": "Test" }
      }
      ''';

      final res = await provider.readBackupData(validJson);
      expect(res, isNotNull);
      expect(res!['app'], 'kualiti');

      const invalidJson = '''
      {
        "app": "other_app",
        "schemaVersion": 1
      }
      ''';

      final invalidRes = await provider.readBackupData(invalidJson);
      expect(invalidRes, isNull);
    });
  });
}
