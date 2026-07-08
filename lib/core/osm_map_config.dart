import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import 'branding.dart';

/// OpenStreetMap Standard raster tiles — compliance:
/// - https://operations.osmfoundation.org/policies/tiles/
/// - https://docs.fleaflet.dev/tile-servers/using-openstreetmap-direct
///
/// For production traffic, consider a dedicated tile provider or self-hosting.
abstract final class OsmMapConfig {
  /// Keep in sync with [pubspec.yaml] `version` (major.minor.patch).
  static const appVersion = '1.0.0';

  /// Required tile URL — do not substitute subdomains or other hosts.
  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';

  /// Identifies this client in the `User-Agent` header as
  /// `flutter_map (<userAgentPackageName>)` on iOS/Android/desktop.
  ///
  /// Must be app-specific (not `com.example.*`). Update when the bundle /
  /// application id is finalized for release.
  static const userAgentPackageName =
      'com.hmccapital.bridge/$appVersion (+$osmCopyrightUrl)';

  static final BuiltInMapCachingProvider _cachingProvider =
      BuiltInMapCachingProvider.getOrCreateInstance();

  /// Tile layer with compliant URL, client id, and HTTP header–aware caching.
  static TileLayer tileLayer() => TileLayer(
        urlTemplate: tileUrlTemplate,
        userAgentPackageName: userAgentPackageName,
        maxNativeZoom: 19,
        tileProvider: NetworkTileProvider(
          cachingProvider: _cachingProvider,
        ),
      );

  /// Always-visible © OpenStreetMap attribution (required; not behind a toggle).
  static Widget attributionBadge() => GestureDetector(
        onTap: kIsWeb ? null : () => _openUrl(osmCopyrightUrl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xD90A0A0C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '© OpenStreetMap contributors',
              style: bodyStyle(size: 11, color: kText),
            ),
          ),
        ),
      );

  /// Attribution anchored inside a map or stack region.
  static Widget attributionLayer({
    Alignment alignment = Alignment.topRight,
    bool useSafeArea = true,
  }) =>
      useSafeArea
          ? SafeArea(
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: attributionBadge(),
                ),
              ),
            )
          : Align(
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: attributionBadge(),
              ),
            );

  /// Layers to pass to [FlutterMap.children] for a compliant OSM basemap.
  static List<Widget> mapLayers({
    Alignment attributionAlignment = Alignment.topRight,
  }) =>
      [
        tileLayer(),
        attributionLayer(alignment: attributionAlignment),
      ];

  /// Tile layer only — use when attribution is placed outside [FlutterMap].
  static List<Widget> tileLayersOnly() => [tileLayer()];

  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('OsmMapConfig: could not open $url');
    }
  }
}
