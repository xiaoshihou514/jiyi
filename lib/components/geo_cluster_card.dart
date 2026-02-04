import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/player.dart';
import 'package:jiyi/pages/playlist.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/geo_cluster.dart';
import 'package:jiyi/utils/smooth_router.dart';

Widget buildClusterCard(
  BuildContext context,
  AppLocalizations l,
  GeoCluster cluster,
) {
  final dateFormat = DateFormat('yyyy-MM-dd');
  final notable = cluster.getNotableRecordings(limit: 3);

  return Container(
    margin: EdgeInsets.only(bottom: 3.em),
    child: InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(SmoothRouter.builder(Playlist(cluster.recordings)));
      },
      child: Padding(
        padding: EdgeInsets.all(4.em),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary location and count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cluster.primaryGeoDesc,
                    style: TextStyle(
                      fontSize: 7.em,
                      fontWeight: FontWeight.bold,
                      color: DefaultColors.keyword,
                      fontFamily: "朱雀仿宋",
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.em,
                    vertical: 1.em,
                  ),
                  decoration: BoxDecoration(
                    color: DefaultColors.keyword.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.em),
                  ),
                  child: Text(
                    l.geo_timeline_recording_count(cluster.count),
                    style: TextStyle(
                      fontSize: 5.em,
                      color: DefaultColors.keyword,
                      fontWeight: FontWeight.bold,
                      fontFamily: "朱雀仿宋",
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.em),

            // Date range
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 4.em,
                  color: DefaultColors.shade_5,
                ),
                SizedBox(width: 1.em),
                Text(
                  cluster.startDate == cluster.endDate
                      ? dateFormat.format(cluster.startDate)
                      : '${dateFormat.format(cluster.startDate)} - ${dateFormat.format(cluster.endDate)}',
                  style: TextStyle(
                    fontSize: 5.em,
                    color: DefaultColors.shade_5,
                    fontFamily: "朱雀仿宋",
                  ),
                ),
              ],
            ),

            // Nearby locations
            if (cluster.allGeoDescs.length > 1) ...[
              SizedBox(height: 2.em),
              Wrap(
                spacing: 1.em,
                runSpacing: 1.em,
                children: cluster.allGeoDescs
                    .where((desc) => desc != cluster.primaryGeoDesc)
                    .take(5)
                    .map(
                      (desc) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.em,
                          vertical: 0.5.em,
                        ),
                        decoration: BoxDecoration(
                          color: DefaultColors.shade_2,
                          borderRadius: BorderRadius.circular(1.em),
                        ),
                        child: Text(
                          desc,
                          style: TextStyle(
                            fontSize: 4.em,
                            color: DefaultColors.shade_6,
                            fontFamily: "朱雀仿宋",
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Notable recordings
            if (notable.isNotEmpty) ...[
              SizedBox(height: 3.em),
              Text(
                l.geo_timeline_notable,
                style: TextStyle(
                  fontSize: 5.em,
                  color: DefaultColors.shade_5,
                  fontWeight: FontWeight.bold,
                  fontFamily: "朱雀仿宋",
                ),
              ),
              SizedBox(height: 1.em),
              ...notable.map(
                (recording) => buildNotableRecording(context, recording),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget buildNotableRecording(BuildContext context, Metadata recording) {
  final duration = _formatDuration(recording.length);

  return InkWell(
    onTap: () {
      Navigator.of(context).push(SmoothRouter.builder(Player(recording)));
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 1.em),
      padding: EdgeInsets.all(2.em),
      child: Row(
        children: [
          Text(
            recording.cover,
            style: TextStyle(fontSize: 6.em, fontFamily: "朱雀仿宋"),
          ),
          SizedBox(width: 2.em),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recording.title,
                style: TextStyle(
                  fontSize: 5.em,
                  color: DefaultColors.fg,
                  fontFamily: "朱雀仿宋",
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 4.em,
                  color: DefaultColors.shade_5,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
