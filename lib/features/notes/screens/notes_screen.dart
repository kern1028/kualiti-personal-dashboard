import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../widgets/note_editor_view.dart';
import '../widgets/note_tile.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _createNewNote(BuildContext context) async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final newNote = await noteProvider.createEmptyNote();

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoteEditorView(note: newNote)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final noteProvider = Provider.of<NoteProvider>(context);

    final allTags = noteProvider.allTags;
    final filtered = noteProvider.filteredNotes;

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(l10n.navNotes),
        backgroundColor: tokens.bg,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radius),
                border: Border.all(color: tokens.line, width: tokens.borderWidth),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: tokens.inkMuted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontFamily: tokens.fontBody,
                        fontSize: 14,
                        color: tokens.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchNotes,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: tokens.inkMuted,
                          fontFamily: tokens.fontBody,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (q) => noteProvider.setSearchQuery(q),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        noteProvider.setSearchQuery('');
                      },
                      child: Icon(Icons.close, size: 18, color: tokens.inkMuted),
                    ),
                ],
              ),
            ),
          ),

          // Tag Filter Chips (if any tags exist)
          if (allTags.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      l10n.filterAll,
                      style: TextStyle(
                        fontSize: 12,
                        color: noteProvider.selectedTag == null ? tokens.onAccent : tokens.ink,
                      ),
                    ),
                    selected: noteProvider.selectedTag == null,
                    selectedColor: tokens.accent,
                    backgroundColor: tokens.surface,
                    onSelected: (_) => noteProvider.setSelectedTag(null),
                  ),
                  const SizedBox(width: 6),
                  ...allTags.map((tag) {
                    final isSelected = noteProvider.selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? tokens.onAccent : tokens.ink,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: tokens.accent,
                        backgroundColor: tokens.surface,
                        onSelected: (_) {
                          noteProvider.setSelectedTag(isSelected ? null : tag);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // Main Notes List
          Expanded(
            child: noteProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: tokens.accent),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 48,
                              color: tokens.inkMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.emptyState,
                              style: TextStyle(
                                fontFamily: tokens.fontBody,
                                fontSize: 14,
                                color: tokens.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tokens.accent,
                                side: BorderSide(color: tokens.accent),
                              ),
                              onPressed: () => _createNewNote(context),
                              child: Text(l10n.newNote),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final note = filtered[index];
                          return NoteTile(note: note);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.accent,
        foregroundColor: tokens.onAccent,
        elevation: tokens.isPixel ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          side: tokens.isPixel
              ? BorderSide(color: tokens.line, width: tokens.borderWidth)
              : BorderSide.none,
        ),
        onPressed: () => _createNewNote(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
