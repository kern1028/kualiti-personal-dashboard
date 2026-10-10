import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../models/link_model.dart';
import '../providers/link_provider.dart';
import 'link_form_sheet.dart';

class LinkTile extends StatelessWidget {
  final LinkModel link;

  const LinkTile({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final linkProvider = Provider.of<LinkProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
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
          linkProvider.launchLink(link.url);
        },
        onLongPress: () {
          _showOptionsSheet(context, link, linkProvider, tokens, l10n);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // Icon or initial circle
              _buildIcon(link, tokens),
              const SizedBox(width: 14),

              // Name & URL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.name,
                      style: TextStyle(
                        fontFamily: tokens.fontTitle,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tokens.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.url,
                      style: TextStyle(
                        fontFamily: tokens.fontBody,
                        fontSize: 12,
                        color: tokens.inkMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // External link icon indicator
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: tokens.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildIconWidget(LinkModel link, ThemeTokens tokens, {double size = 38}) {
    if (link.iconBlob != null && link.iconBlob!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
          border: Border.all(color: tokens.line, width: tokens.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          link.iconBlob!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialCircle(link, tokens, size: size),
        ),
      );
    }
    return _buildInitialCircle(link, tokens, size: size);
  }

  Widget _buildIcon(LinkModel link, ThemeTokens tokens) {
    return buildIconWidget(link, tokens);
  }

  static Widget _buildInitialCircle(LinkModel link, ThemeTokens tokens, {double size = 38}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.accent,
        shape: tokens.isPixel ? BoxShape.rectangle : BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        link.initialLetter,
        style: TextStyle(
          fontFamily: tokens.fontTitle,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          color: tokens.onAccent,
        ),
      ),
    );
  }

  void _showOptionsSheet(
    BuildContext context,
    LinkModel link,
    LinkProvider provider,
    ThemeTokens tokens,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radius)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: tokens.ink),
                title: Text(
                  'Ubah',
                  style: TextStyle(color: tokens.ink, fontFamily: tokens.fontBody),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => LinkFormSheet(linkToEdit: link),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh_rounded, color: tokens.ink),
                title: Text(
                  'Segarkan ikon',
                  style: TextStyle(color: tokens.ink, fontFamily: tokens.fontBody),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.refreshIcon(link);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: tokens.priorityHigh),
                title: Text(
                  'Hapus',
                  style: TextStyle(color: tokens.priorityHigh, fontFamily: tokens.fontBody),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.deleteLink(link);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
