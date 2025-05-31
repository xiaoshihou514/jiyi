import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/map_setting.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:latlong2/latlong.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  final AppLocalizations loc;
  const MapView(this.loc, {super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // create the cache store as a field variable
  late final AppLocalizations l;
  late final Future<String> _cacheStoreFuture;
  late final Future<MapSetting> _setting;

  @override
  void initState() {
    super.initState();

    l = widget.loc;
    _cacheStoreFuture = getApplicationCacheDirectory().then((x) => x.path);
    _setting = ss.read(key: ss.MAP_SETTINGS).then((x) {
      if (x != null) {
        return MapSetting.fromJson(x);
      }
      throw l.settings_map_settings_dne;
    });
  }

  @override
  Widget build(BuildContext context) {
    // show a loading screen when _cacheStore hasn't been set yet
    return FutureBuilder<MapSetting>(
      future: _setting,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return data.isLocal ? _offlineMap(data) : _onlineMap(data);
        }
        if (snapshot.hasError) {
          return Center(
            child: Text.rich(
              TextSpan(
                text: snapshot.error.toString(),
                style: TextStyle(
                  fontSize: 15.em,
                  color: DefaultColors.fg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _offlineMap(MapSetting s) {
    final layers = <Widget>[
      TileLayer(
        urlTemplate: s.urlFmt,

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
        tileProvider: FileTileProvider(),
      ),
    ];
    if (s.isOSM) {
      layers.add(
        RichAttributionWidget(
          popupBackgroundColor: DefaultColors.shade_3,
          attributions: [
            // Suggested attribution for the OpenStreetMap public tile server
            TextSourceAttribution(
              'OpenStreetMap contributors',
              textStyle: TextStyle(color: DefaultColors.fg),
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(35, 110),
        initialZoom: 4,
        minZoom: 4,
        maxZoom: s.maxZoom.toDouble(),
      ),
      children: layers,
    );
  }

  Widget _onlineMap(MapSetting s) {
    return FutureBuilder<String>(
      future: _cacheStoreFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(35, 110),
              initialZoom: 4,
              minZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    // 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                    // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    '/home/xiaoshihou/Playground/github/jiyi/map/{z}/{x}-{y}.png',
                // subdomains: ["1", "2", "3", "4"],
                // userAgentPackageName: 'com.github.xiaoshihou.jiyi',
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
                  store: FileCacheStore(
                    path.join(snapshot.data!, "MapTiles", s.name),
                  ),
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
          return Center(
            child: Text.rich(
              TextSpan(
                text: snapshot.error.toString(),
                style: TextStyle(
                  fontSize: 15.em,
                  color: DefaultColors.fg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
