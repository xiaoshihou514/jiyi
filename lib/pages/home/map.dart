import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // create the cache store as a field variable
  final Future<CacheStore> _cacheStoreFuture = _getCacheStore();

  /// Get the CacheStore as a Future. This method needs to be static so that it
  /// can be used to initialize a field variable.
  static Future<CacheStore> _getCacheStore() async {
    final dir = await getTemporaryDirectory();
    // Note, that Platform.pathSeparator from dart:io does not work on web,
    // import it from dart:html instead.
    return FileCacheStore('${dir.path}${Platform.pathSeparator}MapTiles');
  }

  @override
  Widget build(BuildContext context) {
    // show a loading screen when _cacheStore hasn't been set yet
    return FutureBuilder<CacheStore>(
      future: _cacheStoreFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cacheStore = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(35, 110),
              initialZoom: 4,
              minZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // '/home/xiaoshihou/Playground/github/jiyi/map/{z}/{x}-{y}.png',
                userAgentPackageName: 'com.github.xiaoshihou.jiyi',
                tileBuilder: (BuildContext ctx, Widget target, TileImage tile) {
                  return ColorFiltered(
                    // https://github.com/mlaily/NegativeScreen/blob/4608df1669b2fcfede8f25a0c6d5407521d54f09/NegativeScreen/Configuration.cs#L103
                    colorFilter: const ColorFilter.matrix([
                      // dart-format: off
                      1 / 3, -2 / 3, -2 / 3, 0, 255,
                      -2 / 3, 1 / 3, -2 / 3, 0, 255,
                      -2 / 3, -2 / 3, 1 / 3, 0, 255,
                      0, 0, 0, 1, 0,
                      // dart-format: on
                    ]),
                    child: target,
                  );
                },
                tileProvider: CachedTileProvider(
                  // use the store for your CachedTileProvider instance
                  store: cacheStore,
                ),
              ),
              RichAttributionWidget(
                popupBackgroundColor: DefaultColors.shade_3,
                attributions: [
                  // Suggested attribution for the OpenStreetMap public tile server
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    textStyle: TextStyle(color: DefaultColors.fg),
                    onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
