import 'dart:math';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/anno.dart';

@Claude()
class GeoCluster {
  final String primaryGeoDesc;
  final List<Metadata> recordings;
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> allGeoDescs;

  GeoCluster({
    required this.primaryGeoDesc,
    required this.recordings,
    required this.startDate,
    required this.endDate,
    required this.allGeoDescs,
  });

  int get count => recordings.length;

  /// Get center coordinates of the cluster
  (double lat, double lng) get center {
    if (recordings.isEmpty) return (0.0, 0.0);

    double sumLat = 0;
    double sumLng = 0;

    for (final r in recordings) {
      if (r.latitude != null && r.longitude != null) {
        sumLat += r.latitude!;
        sumLng += r.longitude!;
      }
    }

    return (sumLat / recordings.length, sumLng / recordings.length);
  }

  /// Get notable recordings sorted by duration (longest first)
  List<Metadata> getNotableRecordings({int limit = 5}) {
    final sorted = List<Metadata>.from(recordings);
    sorted.sort((a, b) => b.length.compareTo(a.length));
    return sorted.take(limit).toList();
  }
}

@Claude()
class GeoClustering {
  /// Earth's radius in meters
  static const double earthRadiusMeters = 6371000.0;

  /// Distance threshold for clustering (20km)
  static const double clusterThresholdMeters = 20000.0;

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in meters
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Temporal clustering: Process recordings chronologically
  /// Start new cluster when distance > threshold from cluster centroid AND geodesc differs
  static List<GeoCluster> clusterTemporal(List<Metadata> recordings) {
    // Filter recordings with geolocation and sort by time
    final geoRecordings = recordings.where((r) => r.hasGeo).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    if (geoRecordings.isEmpty) return [];

    final clusters = <GeoCluster>[];
    List<Metadata> currentCluster = [geoRecordings.first];

    for (int i = 1; i < geoRecordings.length; i++) {
      final current = geoRecordings[i];
      final centroid = _calculateCentroid(currentCluster);

      final distance = haversineDistance(
        centroid.$1,
        centroid.$2,
        current.latitude!,
        current.longitude!,
      );

      // Check if geodesc matches any in current cluster
      final currentGeodescs = currentCluster
          .where((r) => r.geodesc != null && r.geodesc!.isNotEmpty)
          .map((r) => r.geodesc!)
          .toSet();
      final hasMatchingGeoDesc =
          current.geodesc != null &&
          current.geodesc!.isNotEmpty &&
          currentGeodescs.contains(current.geodesc);

      if (distance <= clusterThresholdMeters || hasMatchingGeoDesc) {
        // Add to current cluster if distance is close OR geodesc matches
        currentCluster.add(current);
      } else {
        // Start new cluster
        clusters.add(_createCluster(currentCluster));
        currentCluster = [current];
      }
    }

    // Add final cluster
    if (currentCluster.isNotEmpty) {
      clusters.add(_createCluster(currentCluster));
    }

    return clusters;
  }

  /// Count-based clustering: Group all recordings by location similarity
  /// Merge clusters within threshold of each other OR with same geodesc (time-invariant)
  static List<GeoCluster> clusterByCount(List<Metadata> recordings) {
    // Filter recordings with geolocation
    final geoRecordings = recordings.where((r) => r.hasGeo).toList();

    if (geoRecordings.isEmpty) return [];

    // Start with each recording as its own cluster
    final clusters = <List<Metadata>>[];
    for (final recording in geoRecordings) {
      clusters.add([recording]);
    }

    // Merge clusters that are within threshold OR have same geodesc
    bool merged = true;
    while (merged) {
      merged = false;

      for (int i = 0; i < clusters.length; i++) {
        for (int j = i + 1; j < clusters.length; j++) {
          final centroid1 = _calculateCentroid(clusters[i]);
          final centroid2 = _calculateCentroid(clusters[j]);

          final distance = haversineDistance(
            centroid1.$1,
            centroid1.$2,
            centroid2.$1,
            centroid2.$2,
          );

          // Check if clusters have matching geodescs
          final geodescs1 = clusters[i]
              .where((r) => r.geodesc != null && r.geodesc!.isNotEmpty)
              .map((r) => r.geodesc!)
              .toSet();
          final geodescs2 = clusters[j]
              .where((r) => r.geodesc != null && r.geodesc!.isNotEmpty)
              .map((r) => r.geodesc!)
              .toSet();
          final hasMatchingGeoDesc = geodescs1
              .intersection(geodescs2)
              .isNotEmpty;

          if (distance <= clusterThresholdMeters || hasMatchingGeoDesc) {
            // Merge j into i if distance is close OR geodescs match
            clusters[i].addAll(clusters[j]);
            clusters.removeAt(j);
            merged = true;
            break;
          }
        }
        if (merged) break;
      }
    }

    // Sort clusters by count (descending)
    clusters.sort((a, b) => b.length.compareTo(a.length));

    return clusters.map(_createCluster).toList();
  }

  /// Calculate centroid of a cluster
  static (double lat, double lng) _calculateCentroid(
    List<Metadata> recordings,
  ) {
    if (recordings.isEmpty) return (0.0, 0.0);

    double sumLat = 0;
    double sumLng = 0;

    for (final r in recordings) {
      if (r.latitude != null && r.longitude != null) {
        sumLat += r.latitude!;
        sumLng += r.longitude!;
      }
    }

    return (sumLat / recordings.length, sumLng / recordings.length);
  }

  /// Create GeoCluster from recordings list
  static GeoCluster _createCluster(List<Metadata> recordings) {
    recordings.sort((a, b) => a.time.compareTo(b.time));

    // Collect all unique geodescs
    final geoDescs = recordings
        .where((r) => r.geodesc != null && r.geodesc!.isNotEmpty)
        .map((r) => r.geodesc!)
        .toSet();

    // Use most common geodesc as primary
    String primaryGeoDesc = '未知位置';
    if (geoDescs.isNotEmpty) {
      final geoDescCounts = <String, int>{};
      for (final desc in geoDescs) {
        geoDescCounts[desc] = (geoDescCounts[desc] ?? 0) + 1;
      }
      primaryGeoDesc = geoDescCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return GeoCluster(
      primaryGeoDesc: primaryGeoDesc,
      recordings: recordings,
      startDate: recordings.first.time,
      endDate: recordings.last.time,
      allGeoDescs: geoDescs,
    );
  }
}
