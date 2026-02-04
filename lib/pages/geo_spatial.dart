import 'package:flutter/material.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/geo_cluster.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/components/geo_cluster_card.dart';
import 'package:provider/provider.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:jiyi/utils/em.dart';

@Claude()
class GeoSpatial extends StatefulWidget {
  const GeoSpatial({super.key});

  @override
  State<GeoSpatial> createState() => _GeoSpatialState();
}

class _GeoSpatialState extends State<GeoSpatial> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        foregroundColor: DefaultColors.fg,
        title: Text(l.geo_spatial_title, style: TextStyle(fontFamily: "朱雀仿宋")),
      ),
      body: Consumer<Notifier>(
        builder: (context, notifier, child) {
          return FutureBuilder<List<Metadata>>(
            future: IO.indexFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Icon(
                    Icons.sync,
                    color: DefaultColors.keyword,
                    size: 20.em,
                  ),
                );
              }

              final recordings = snapshot.data!;
              final clusters = GeoClustering.clusterByCount(recordings);

              if (clusters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 20.em,
                        color: DefaultColors.shade_4,
                      ),
                      SizedBox(height: 2.em),
                      Text(
                        l.geo_spatial_empty,
                        style: TextStyle(
                          fontSize: 6.em,
                          color: DefaultColors.shade_4,
                          fontFamily: "朱雀仿宋",
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(3.em),
                itemCount: clusters.length,
                itemBuilder: (context, index) {
                  return buildClusterCard(context, l, clusters[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
