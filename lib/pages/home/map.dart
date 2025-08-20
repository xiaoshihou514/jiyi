import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/player.dart';
import 'package:jiyi/pages/playlist.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/map_setting.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/smooth_router.dart';

class RichMarker extends Marker {
  final Metadata md;
  final double lat;
  final double lng;
  RichMarker(
    this.md, {
    required this.lat,
    required this.lng,
    required super.child,
  }) : super(point: LatLng(lat, lng));
}

bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;

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
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(
                fontSize: 15.em,
                color: DefaultColors.fg,
                fontFamily: "朱雀仿宋",
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
        tileBuilder: s.useInversionFilter ? _inversionFilter : null,
        tileProvider: FileTileProvider(),
      ),
      _markerLayer(),
    ];
    if (s.isOSM) {
      layers.add(_osmAttribution());
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

  Widget _onlineMap(MapSetting s) => FutureBuilder<String>(
    future: _cacheStoreFuture,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        var layers = <Widget>[
          TileLayer(
            urlTemplate: s.urlFmt,
            subdomains: s.subdomains ?? [],
            userAgentPackageName: 'com.github.xiaoshihou.jiyi',
            tileBuilder: s.useInversionFilter ? _inversionFilter : null,
            tileProvider: CachedTileProvider(
              dio: Dio(BaseOptions(headers: jsonDecode(s.header ?? "{}"))),
              store: FileCacheStore(
                path.join(snapshot.data!, "MapTiles", s.name),
              ),
            ),
          ),
          _markerLayer(),
        ];
        if (s.isOSM) {
          layers.add(_osmAttribution());
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
      if (snapshot.hasError) {
        return Center(
          child: Text(
            snapshot.error.toString(),
            style: TextStyle(
              fontSize: 15.em,
              color: DefaultColors.fg,
              fontFamily: "朱雀仿宋",
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    },
  );

  Widget _markerLayer() => Consumer<Notifier>(
    builder: (context, counter, child) => FutureBuilder<List<Metadata>>(
      future: IO.indexFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Spinner(Icons.sync, DefaultColors.keyword, 40.em),
          );
        }
        return _markers(snapshot.data ?? []);
      },
    ),
  );

  Widget _osmAttribution() => RichAttributionWidget(
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
  );

  Widget _markers(List<Metadata> markers) => MarkerClusterLayerWidget(
    options: MarkerClusterLayerOptions(
      maxClusterRadius: 45,
      size: isMobile ? Size(18.em, 18.em) : Size(8.em, 8.em),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(50),
      maxZoom: double.infinity,
      markers: markers.where((md) => md.hasGeo).map((md) {
        return RichMarker(
          md,
          lat: md.latitude!,
          lng: md.longitude!,
          child: Transform.translate(
            offset: isMobile ? Offset(-9.em, -9.em) : Offset(-4.em, -4.em),
            child: IconButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(context, SmoothRouter.builder(Player(md)));
                }
              },
              icon: Icon(
                Icons.pin_drop,
                color: DefaultColors.keyword,
                size: isMobile ? 18.em : 8.em,
              ),
            ),
          ),
        );
      }).toList(),
      builder: (context, markers) {
        return IconButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.push(
                context,
                SmoothRouter.builder(
                  Playlist(
                    markers.cast<RichMarker>().map((m) => m.md).toList(),
                  ),
                ),
              );
            }
          },
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: DefaultColors.keyword,
            ),
            child: Center(
              child: Text(
                markers.length.toString(),
                style: TextStyle(color: DefaultColors.bg),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget Function(BuildContext, Widget, TileImage) get _inversionFilter =>
      (BuildContext ctx, Widget target, TileImage tile) => ColorFiltered(
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
}
