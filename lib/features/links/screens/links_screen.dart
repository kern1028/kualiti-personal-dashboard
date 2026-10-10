import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/link_provider.dart';
import '../widgets/link_form_sheet.dart';
import '../widgets/link_tile.dart';

class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});

  void _openAddLinkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LinkFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final linkProvider = Provider.of<LinkProvider>(context);

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(l10n.navLinks),
        backgroundColor: tokens.bg,
      ),
      body: linkProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(color: tokens.accent),
            )
          : linkProvider.links.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link_rounded,
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
                        onPressed: () => _openAddLinkSheet(context),
                        child: Text(l10n.add),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: linkProvider.links.length,
                  itemBuilder: (context, index) {
                    final link = linkProvider.links[index];
                    return LinkTile(link: link);
                  },
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
        onPressed: () => _openAddLinkSheet(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
