import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import 'note_editor_view.dart';

class NoteTile extends StatelessWidget {
  final NoteModel note;

  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final displayTitle = note.title.trim().isNotEmpty
        ? note.title
        : (note.plainText.trim().isNotEmpty
            ? note.snippet
            : 'Catatan Tanpa Judul');

    final updatedDate = DateTime.parse(note.updatedAt);
    final formattedDate = DateTimeFormatter.formatDate(updatedDate);

    return Dismissible(
      key: ValueKey('note_${note.id}_${note.updatedAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tokens.priorityHigh.withOpacity(0.15),
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
        child: Icon(Icons.delete_outline_rounded, color: tokens.priorityHigh),
      ),
      onDismissed: (_) async {
        await noteProvider.deleteNote(note);

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('${l10n.deleted} - $displayTitle'),
              action: SnackBarAction(
                label: l10n.undo,
                textColor: tokens.accent,
                onPressed: () {
                  noteProvider.undoDelete();
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: tokens.line, width: tokens.borderWidth),
          boxShadow: tokens.isPixel
              ? [
                  BoxShadow(
                    color: tokens.line,
                    offset: const Offset(2, 2),
                  )
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteEditorView(note: note)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Pin icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontFamily: tokens.fontTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tokens.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.pinned)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: tokens.accent,
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Content Snippet
                Text(
                  note.snippet,
                  style: TextStyle(
                    fontFamily: tokens.fontBody,
                    fontSize: 13,
                    color: tokens.inkMuted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Tags & Date Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (note.tagList.isNotEmpty)
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: note.tagList.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontFamily: tokens.fontBody,
                                  fontSize: 10,
                                  color: tokens.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      const Spacer(),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontFamily: tokens.fontBody,
                        fontSize: 11,
                        color: tokens.inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
