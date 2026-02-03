import 'dart:convert';
import 'dart:io';
import 'package:jiyi/utils/anno.dart';
import 'package:turf/turf.dart';

@Claude()
class Geo {
  static final Geo _instance = Geo._internal();
  factory Geo() => _instance;
  Geo._internal();

  static const String _geoJsonPath = '/home/xiaoshihou/Playground/github/geojson';
  
  FeatureCollection? _cnAdm1;
  FeatureCollection? _cnAdm2;
  FeatureCollection? _cnAdm3;
  FeatureCollection? _worldAdm0;
  FeatureCollection? _worldAdm1;
  FeatureCollection? _worldAdm2;

  Future<FeatureCollection?> _loadGeoJSON(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return null;
      }
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return FeatureCollection.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getLocationDescription(double latitude, double longitude) async {
    try {
      final point = Point(coordinates: Position(longitude, latitude));
      
      // 先检查是否在中国境内
      _cnAdm1 ??= await _loadGeoJSON('$_geoJsonPath/cn_adm1.geojson');
      final province = _findContainingFeature(_cnAdm1, point);
      
      if (province != null) {
        // 在中国境内，查找市和县
        _cnAdm2 ??= await _loadGeoJSON('$_geoJsonPath/cn_adm2.geojson');
        _cnAdm3 ??= await _loadGeoJSON('$_geoJsonPath/cn_adm3.geojson');
        
        final city = _findContainingFeature(_cnAdm2, point);
        final county = _findContainingFeature(_cnAdm3, point);

        final resultParts = <String>[];
        if (province.isNotEmpty) resultParts.add(province);
        if (city != null && city.isNotEmpty) resultParts.add(city);
        if (county != null && county.isNotEmpty) resultParts.add(county);

        return resultParts.isNotEmpty ? resultParts.join(', ') : null;
      } else {
        // 不在中国境内，检查世界数据
        _worldAdm0 ??= await _loadGeoJSON('$_geoJsonPath/world_adm0.geojson');
        _worldAdm1 ??= await _loadGeoJSON('$_geoJsonPath/world_adm1.geojson');
        _worldAdm2 ??= await _loadGeoJSON('$_geoJsonPath/world_adm2.geojson');
        
        final country = _findContainingFeature(_worldAdm0, point, nameKey: 'shapeName');
        final state = _findContainingFeature(_worldAdm1, point, nameKey: 'shapeName');
        final district = _findContainingFeature(_worldAdm2, point, nameKey: 'shapeName');

        final resultParts = <String>[];
        if (country != null && country.isNotEmpty) resultParts.add(country);
        if (state != null && state.isNotEmpty) resultParts.add(state);
        if (district != null && district.isNotEmpty) resultParts.add(district);

        return resultParts.isNotEmpty ? resultParts.join(', ') : null;
      }
    } catch (e) {
      return null;
    }
  }

  String? _findContainingFeature(
    FeatureCollection? collection,
    Point point,
    {String nameKey = 'name'}
  ) {
    if (collection == null) return null;

    for (final feature in collection.features) {
      if (feature.geometry == null) continue;
      
      // Only check Polygon and MultiPolygon geometries
      final geomType = feature.geometry!.type;
      if (geomType != GeoJSONObjectType.polygon && geomType != GeoJSONObjectType.multiPolygon) {
        continue;
      }
      
      try {
        if (booleanPointInPolygon(point.coordinates, feature.geometry!)) {
          final properties = feature.properties;
          if (properties != null && properties.containsKey(nameKey)) {
            return properties[nameKey] as String?;
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}
