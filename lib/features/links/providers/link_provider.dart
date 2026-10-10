import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/db/link_dao.dart';
import '../../../core/utils/favicon_fetcher.dart';
import '../models/link_model.dart';

class LinkProvider extends ChangeNotifier {
  List<LinkModel> _links = [];
  bool _isLoading = true;

  List<LinkModel> get links => _links;
  bool get isLoading => _isLoading;

  List<LinkModel> get homeLinks {
    return _links.where((l) => l.showOnHome).take(4).toList();
  }

  LinkProvider() {
    loadLinks();
  }

  Future<void> loadLinks() async {
    _isLoading = true;
    notifyListeners();
    _links = await LinkDao.instance.getAllLinks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLink({
    required String name,
    required String url,
    bool showOnHome = true,
  }) async {
    final tempModel = LinkModel(name: name, url: url, showOnHome: showOnHome);
    final normalizedUrl = tempModel.normalizedUrl;

    // Fetch icon in background
    final iconBlob = await FaviconFetcher.fetchFavicon(normalizedUrl);

    final linkToInsert = LinkModel(
      name: name,
      url: normalizedUrl,
      iconBlob: iconBlob,
      showOnHome: showOnHome,
      sortOrder: _links.length,
    );

    final id = await LinkDao.instance.insertLink(linkToInsert);
    final inserted = linkToInsert.copyWith(id: id);

    _links.add(inserted);
    notifyListeners();
  }

  Future<void> updateLink(LinkModel link) async {
    await LinkDao.instance.updateLink(link);
    final index = _links.indexWhere((l) => l.id == link.id);
    if (index != -1) {
      _links[index] = link;
      notifyListeners();
    }
  }

  Future<void> refreshIcon(LinkModel link) async {
    if (link.id == null) return;
    final iconBlob = await FaviconFetcher.fetchFavicon(link.normalizedUrl);
    final updated = link.copyWith(iconBlob: iconBlob);
    await updateLink(updated);
  }

  Future<void> deleteLink(LinkModel link) async {
    if (link.id == null) return;
    await LinkDao.instance.deleteLink(link.id!);
    _links.removeWhere((l) => l.id == link.id);
    notifyListeners();
  }

  Future<bool> launchLink(String url) async {
    final trimmed = url.trim();
    String normalized = trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      normalized = 'https://$trimmed';
    }

    final uri = Uri.parse(normalized);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      return false;
    }
  }
}
