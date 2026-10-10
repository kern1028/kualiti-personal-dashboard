import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class FaviconFetcher {
  FaviconFetcher._();

  static Future<Uint8List?> fetchFavicon(String normalizedUrl) async {
    try {
      final uri = Uri.parse(normalizedUrl);
      final host = uri.host;
      if (host.isEmpty) return null;

      // 1. Try Google Favicon Service first (fast 64px icon service)
      final googleFaviconUri = Uri.parse('https://www.google.com/s2/favicons?domain=$host&sz=64');
      final res = await http.get(googleFaviconUri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty && res.bodyBytes.length > 100) {
        return res.bodyBytes;
      }

      // 2. Try direct /favicon.ico fallback
      final directFaviconUri = Uri.parse('${uri.scheme}://$host/favicon.ico');
      final resDirect = await http.get(directFaviconUri).timeout(const Duration(seconds: 3));
      if (resDirect.statusCode == 200 && resDirect.bodyBytes.isNotEmpty) {
        return resDirect.bodyBytes;
      }
    } catch (_) {
      // Offline or network error: return null so UI renders fallback initial circle
    }
    return null;
  }
}
