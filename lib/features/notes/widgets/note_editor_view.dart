import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';

class NoteEditorView extends StatefulWidget {
  final NoteModel note;

  const NoteEditorView({super.key, required this.note});

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late NoteModel _currentNote;
  late TextEditingController _titleController;
  late TextEditingController _tagsController;
  late List<NoteBlock> _blocks;
  final List<TextEditingController> _blockControllers = [];

  Timer? _debounceTimer;
  int _activeBlockIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _tagsController = TextEditingController(text: _currentNote.tags);

    _blocks = NoteModel.parseBlocks(_currentNote.bodyJson);
    if (_blocks.isEmpty) {
      _blocks = [NoteBlock()];
    }

    for (var i = 0; i < _blocks.length; i++) {
      final controller = TextEditingController(text: _blocks[i].text);
      controller.addListener(() => _onContentChanged(i));
      _blockControllers.add(controller);
    }

    _titleController.addListener(_triggerDebouncedSave);
    _tagsController.addListener(_triggerDebouncedSave);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _tagsController.dispose();
    for (final c in _blockControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onContentChanged(int index) {
    _blocks[index].text = _blockControllers[index].text;
    _triggerDebouncedSave();
  }

  void _triggerDebouncedSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _performSave);
  }

  void _performSave() {
    final title = _titleController.text;
    final tags = _tagsController.text;
    final bodyJson = NoteModel.encodeBlocks(_blocks);
    final plainText = NoteModel.extractPlainText(_blocks);

    _currentNote = _currentNote.copyWith(
      title: title,
      bodyJson: bodyJson,
      plainText: plainText,
      tags: tags,
    );

    final provider = Provider.of<NoteProvider>(context, listen: false);
    provider.saveNote(_currentNote);
  }

  void _addBlock(String type) {
    setState(() {
      final newBlock = NoteBlock(type: type);
      final insertIndex = _activeBlockIndex + 1;
      _blocks.insert(insertIndex, newBlock);

      final controller = TextEditingController();
      controller.addListener(() => _onContentChanged(insertIndex));
      _blockControllers.insert(insertIndex, controller);

      _activeBlockIndex = insertIndex;
    });
    _triggerDebouncedSave();
  }

  void _toggleBlockStyle(String type) {
    setState(() {
      if (_blocks[_activeBlockIndex].type == type) {
        _blocks[_activeBlockIndex].type = 'paragraph';
      } else {
        _blocks[_activeBlockIndex].type = type;
      }
    });
    _triggerDebouncedSave();
  }

  void _toggleInlineStyle({bool? bold, bool? italic, bool? underline}) {
    setState(() {
      final block = _blocks[_activeBlockIndex];
      if (bold != null) block.bold = !block.bold;
      if (italic != null) block.italic = !block.italic;
      if (underline != null) block.underline = !block.underline;
    });
    _triggerDebouncedSave();
  }

  void _showLinkDialog() {
    final currentLink = _blocks[_activeBlockIndex].link ?? '';
    final linkController = TextEditingController(text: currentLink);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah / Ubah Tautan'),
          content: TextField(
            controller: linkController,
            decoration: const InputDecoration(
              hintText: 'https://example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _blocks[_activeBlockIndex].link =
                      linkController.text.trim().isEmpty
                          ? null
                          : linkController.text.trim();
                });
                _triggerDebouncedSave();
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final provider = Provider.of<NoteProvider>(context);

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        actions: [
          IconButton(
            icon: Icon(
              _currentNote.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _currentNote.pinned ? tokens.accent : tokens.ink,
            ),
            tooltip: l10n.pin,
            onPressed: () {
              setState(() {
                _currentNote = _currentNote.copyWith(pinned: !_currentNote.pinned);
              });
              provider.togglePin(_currentNote);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: tokens.priorityHigh),
            onPressed: () async {
              await provider.deleteNote(_currentNote);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 5),
                    content: Text(l10n.deleted),
                    action: SnackBarAction(
                      label: l10n.undo,
                      textColor: tokens.accent,
                      onPressed: () => provider.undoDelete(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Note Body Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              children: [
                // Title Field
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.noteTitle,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: tokens.inkMuted,
                      fontFamily: tokens.fontTitle,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Tag Field (comma separated)
                Row(
                  children: [
                    Icon(Icons.sell_outlined, size: 16, color: tokens.inkMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _tagsController,
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          fontSize: 12,
                          color: tokens.inkMuted,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tag (dipisah koma, maks 5)',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Editor Blocks
                ...List.generate(_blocks.length, (index) {
                  return _buildBlockRow(index, tokens);
                }),
              ],
            ),
          ),

          // Rich Text Toolbar (Single row above keyboard / bottom bar)
          _buildToolbar(tokens),
        ],
      ),
    );
  }

  Widget _buildBlockRow(int index, ThemeTokens tokens) {
    final block = _blocks[index];
    final controller = _blockControllers[index];

    Widget prefixWidget;
    TextStyle blockTextStyle = TextStyle(
      fontFamily: tokens.fontBody, // Always readable font per design system
      fontSize: 16,
      height: 1.5,
      color: tokens.ink,
      fontWeight: block.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
      decoration: block.underline ? TextDecoration.underline : TextDecoration.none,
    );

    switch (block.type) {
      case 'heading':
        prefixWidget = Text(
          'H3 ',
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontWeight: FontWeight.bold,
            color: tokens.accent,
            fontSize: 14,
          ),
        );
        blockTextStyle = blockTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: tokens.fontTitle,
        );
        break;

      case 'bullet':
        prefixWidget = Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
          child: Icon(Icons.fiber_manual_record, size: 8, color: tokens.accent),
        );
        break;

      case 'number':
        prefixWidget = Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            '${index + 1}. ',
            style: TextStyle(
              fontFamily: tokens.fontBody,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
            ),
          ),
        );
        break;

      case 'alpha':
        final letter = String.fromCharCode(97 + (index % 26)); // a, b, c...
        prefixWidget = Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            '$letter. ',
            style: TextStyle(
              fontFamily: tokens.fontBody,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
            ),
          ),
        );
        break;

      case 'paragraph':
      default:
        prefixWidget = const SizedBox.shrink();
        break;
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          setState(() {
            _activeBlockIndex = index;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            prefixWidget,
            Expanded(
              child: TextField(
                controller: controller,
                style: blockTextStyle,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) {
                  _addBlock('paragraph');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(ThemeTokens tokens) {
    final currentBlock = _blocks.isNotEmpty ? _blocks[_activeBlockIndex] : NoteBlock();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(
          top: BorderSide(color: tokens.line, width: tokens.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Heading H3
              _buildToolButton(
                label: 'H',
                active: currentBlock.type == 'heading',
                tokens: tokens,
                onTap: () => _toggleBlockStyle('heading'),
              ),
              // Bold
              _buildToolButton(
                label: 'B',
                isBold: true,
                active: currentBlock.bold,
                tokens: tokens,
                onTap: () => _toggleInlineStyle(bold: true),
              ),
              // Italic
              _buildToolButton(
                label: 'I',
                isItalic: true,
                active: currentBlock.italic,
                tokens: tokens,
                onTap: () => _toggleInlineStyle(italic: true),
              ),
              // Underline
              _buildToolButton(
                label: 'U',
                isUnderline: true,
                active: currentBlock.underline,
                tokens: tokens,
                onTap: () => _toggleInlineStyle(underline: true),
              ),
              // Link
              _buildToolButton(
                icon: Icons.link_rounded,
                active: currentBlock.link != null,
                tokens: tokens,
                onTap: _showLinkDialog,
              ),
              const VerticalDivider(indent: 8, endIndent: 8),
              // Bullet List
              _buildToolButton(
                icon: Icons.format_list_bulleted_rounded,
                active: currentBlock.type == 'bullet',
                tokens: tokens,
                onTap: () => _toggleBlockStyle('bullet'),
              ),
              // Number List (1,2,3)
              _buildToolButton(
                icon: Icons.format_list_numbered_rounded,
                active: currentBlock.type == 'number',
                tokens: tokens,
                onTap: () => _toggleBlockStyle('number'),
              ),
              // Alphabetical List (a,b,c - lower-alpha)
              _buildToolButton(
                label: 'a-b',
                active: currentBlock.type == 'alpha',
                tokens: tokens,
                onTap: () => _toggleBlockStyle('alpha'),
              ),
              const VerticalDivider(indent: 8, endIndent: 8),
              // Add Paragraph Line
              _buildToolButton(
                icon: Icons.add,
                active: false,
                tokens: tokens,
                onTap: () => _addBlock('paragraph'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    String? label,
    IconData? icon,
    bool isBold = false,
    bool isItalic = false,
    bool isUnderline = false,
    required bool active,
    required ThemeTokens tokens,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: active ? tokens.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radius > 6 ? 6 : tokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius > 6 ? 6 : tokens.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: active ? tokens.onAccent : tokens.ink,
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontFamily: tokens.fontTitle,
                      fontSize: 14,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                      color: active ? tokens.onAccent : tokens.ink,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
