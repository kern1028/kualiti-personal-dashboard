import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../models/link_model.dart';
import '../providers/link_provider.dart';

class LinkFormSheet extends StatefulWidget {
  final LinkModel? linkToEdit;

  const LinkFormSheet({super.key, this.linkToEdit});

  @override
  State<LinkFormSheet> createState() => _LinkFormSheetState();
}

class _LinkFormSheetState extends State<LinkFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late bool _showOnHome;

  @override
  void initState() {
    super.initState();
    final link = widget.linkToEdit;
    _nameController = TextEditingController(text: link?.name ?? '');
    _urlController = TextEditingController(text: link?.url ?? '');
    _showOnHome = link?.showOnHome ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveLink() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    final provider = Provider.of<LinkProvider>(context, listen: false);

    if (widget.linkToEdit != null) {
      final updated = widget.linkToEdit!.copyWith(
        name: name,
        url: url,
        showOnHome: _showOnHome,
      );
      provider.updateLink(updated);
    } else {
      provider.addLink(
        name: name,
        url: url,
        showOnHome: _showOnHome,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius),
        ),
        border: Border.all(color: tokens.line, width: tokens.borderWidth),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.linkToEdit == null ? l10n.add + ' ' + l10n.navLinks : 'Ubah ' + l10n.navLinks,
              style: TextStyle(
                fontFamily: tokens.fontTitle,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tokens.ink,
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: _nameController,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 15,
                color: tokens.ink,
              ),
              decoration: InputDecoration(
                labelText: l10n.linkName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                ),
              ),
              autofocus: widget.linkToEdit == null,
            ),
            const SizedBox(height: 14),

            // URL field
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 15,
                color: tokens.ink,
              ),
              decoration: InputDecoration(
                labelText: l10n.linkUrl,
                hintText: 'example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Show on home toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Tampilkan di Beranda (maks 4)',
                style: TextStyle(
                  fontFamily: tokens.fontBody,
                  fontSize: 14,
                  color: tokens.ink,
                ),
              ),
              activeColor: tokens.accent,
              value: _showOnHome,
              onChanged: (val) {
                setState(() {
                  _showOnHome = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Save / Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: tokens.inkMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radius),
                    ),
                  ),
                  onPressed: _saveLink,
                  child: Text(
                    l10n.save,
                    style: TextStyle(
                      fontFamily: tokens.fontTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
