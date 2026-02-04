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
class GeoTimeline extends StatefulWidget {
  const GeoTimeline({super.key});

  @override
  State<GeoTimeline> createState() => _GeoTimelineState();
}

class _GeoTimelineState extends State<GeoTimeline> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        foregroundColor: DefaultColors.fg,
        title: Text(l.geo_timeline_title, style: TextStyle(fontFamily: "朱雀仿宋")),
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
              final clusters = GeoClustering.clusterTemporal(recordings);

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
                        l.geo_timeline_empty,
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
                padding: EdgeInsets.symmetric(horizontal: 3.em, vertical: 5.em),
                itemCount: clusters.length,
                itemBuilder: (context, index) {
                  return _buildTimelineItem(
                    context,
                    l,
                    clusters[index],
                    index == clusters.length - 1,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    AppLocalizations l,
    GeoCluster cluster,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line with dot
          SizedBox(
            width: 8.em,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 3.em,
                  height: 3.em,
                  decoration: BoxDecoration(
                    color: DefaultColors.keyword,
                    shape: BoxShape.circle,
                  ),
                ),
                // Vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 0.5.em,
                      color: DefaultColors.shade_3,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 3.em),

          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 5.em),
              child: buildClusterCard(context, l, cluster),
            ),
          ),
        ],
      ),
    );
  }
}
