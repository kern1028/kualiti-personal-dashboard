import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/features/notes/models/note_model.dart';

void main() {
  group('NoteModel & JSON AST Test', () {
    test('Encode and decode blocks with lower-alpha list support', () {
      final blocks = [
        NoteBlock(type: 'heading', text: 'Rencana Belanja'),
        NoteBlock(type: 'bullet', text: 'Kopi', bold: true),
        NoteBlock(type: 'alpha', text: 'Telur', italic: true),
      ];

      final jsonStr = NoteModel.encodeBlocks(blocks);
      expect(jsonStr.contains('lower-alpha'), true);

      final parsed = NoteModel.parseBlocks(jsonStr);
      expect(parsed.length, 3);
      expect(parsed[0].type, 'heading');
      expect(parsed[1].bold, true);
      expect(parsed[2].type, 'alpha');
    });

    test('Tag extraction test', () {
      final note = NoteModel(
        title: 'Judul',
        bodyJson: '[]',
        plainText: 'Isi',
        tags: 'kopi, belanja, penting, rumah, kerja, lebih',
        updatedAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      // Max 5 tags per PRD spec
      expect(note.tagList.length, 5);
      expect(note.tagList, ['kopi', 'belanja', 'penting', 'rumah', 'kerja']);
    });
  });
}
