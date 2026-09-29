// Flutter packages
import 'package:material_ui/material_ui.dart';

// Models
import '/core/models/best_time.dart';
// Styles
import '/styles/style_config.dart';
// Utils
import '/utils/date_time_utils/my_date_format.dart';
import '/utils/extensions/context_extensions.dart';
import '/utils/extensions/duration_extensions.dart';

/// Ranked times, the one whose id is [highlightId] filled in the accent.
class MyTimesList extends StatelessWidget {
  const MyTimesList({required this.times, this.highlightId, super.key});

  final List<BestTime> times;
  final int? highlightId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      spacing: 4,
      children: [
        for (final (index, time) in times.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: time.id == highlightId ? colors.primary : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    "${index + 1}.",
                    style: TextStyle(
                      color: time.id == highlightId ? colors.onPrimary : context.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    MyDateFormat.ONLY_DAY_MONTH_YEAR.format(time.date),
                    style: TextStyle(color: time.id == highlightId ? colors.onPrimary : null),
                  ),
                ),
                Text(
                  time.duration.clock,
                  style: TextStyle(
                    fontWeight: .w600,
                    fontFeatures: tabularFigures,
                    color: time.id == highlightId ? colors.onPrimary : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
