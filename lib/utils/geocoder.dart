import 'package:geocoder_offline/geocoder_offline.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/metadata.dart';

abstract class Geocoder {
  @DeepSeek()
  static final _chineseRegex = RegExp(r'^[\u4e00-\u9fff\u3400-\u4dbf]+$');

  static String? placeOf(GeocodeData gc, Metadata md, String locale) {
    if (md.latitude == null && md.longitude == null) {
      return null;
    }

    final query = gc.search(md.latitude!, md.longitude!).firstOrNull;
    if (query == null) {
      return null;
    }

    if (query.location.featureName?.isEmpty ?? true) {
      return query.location.state;
    }

    final names = query.location.featureName!.split(",");
    return locale.contains("zh")
        ? names.firstWhere(
            _chineseRegex.hasMatch,
            orElse: () => query.location.state!,
          )
        : names.first;
  }
}
