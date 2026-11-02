import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/api_client.dart';
import '../theme/app_colors.dart';
import '../utils/app_date_utils.dart';

/// One line of the activity timeline: what happened, when, and who did it.
class TimelineEvent {
  TimelineEvent({
    required this.status,
    required this.createdAt,
    this.note,
    this.actorName,
    this.actorRole,
  });

  final String status;
  final String? note;
  final String? actorName;
  final String? actorRole;
  final DateTime createdAt;

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        status: '${j['status'] ?? ''}',
        note: j['note'] as String?,
        actorName: j['actorName'] as String?,
        actorRole: j['actorRole'] as String?,
        createdAt:
            DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
                DateTime.now(),
      );
}

class TimelineStaff {
  TimelineStaff({required this.name, required this.phone, required this.role});
  final String name;
  final String phone;
  final String role;
}

class TimelineData {
  TimelineData(this.events, this.staff);
  final List<TimelineEvent> events;
  final TimelineStaff? staff;
}

/// kind: 'booking' | 'order'
final activityTimelineProvider = FutureProvider.autoDispose
    .family<TimelineData, ({String kind, String id})>((ref, key) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/timeline/${key.kind}/${key.id}');
  final data = api.unwrapObject(res.data);
  final events = (data['events'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(TimelineEvent.fromJson)
      .toList();
  final s = data['staff'];
  final staff = s is Map<String, dynamic>
      ? TimelineStaff(
          name: '${s['name'] ?? ''}',
          phone: '${s['phone'] ?? ''}',
          role: '${s['role'] ?? ''}',
        )
      : null;
  return TimelineData(events, staff);
});

String _label(String status) => switch (status) {
      'Placed' => 'Placed',
      'Pending' => 'Pending',
      'Approved' => 'Approved',
      'Assigned' => 'Technician assigned',
      'Processing' => 'Processing',
      'OnTheWay' => 'On the way',
      'Completed' => 'Completed',
      'Dispatched' => 'Out for delivery',
      'Delivered' => 'Delivered',
      'Cancelled' => 'Cancelled',
      _ => status,
    };

IconData _icon(String status) => switch (status) {
      'Placed' => Icons.receipt_long_outlined,
      'Approved' || 'Processing' => Icons.thumb_up_alt_outlined,
      'Assigned' => Icons.person_outline,
      'OnTheWay' => Icons.directions_run_rounded,
      'Dispatched' => Icons.local_shipping_outlined,
      'Completed' || 'Delivered' => Icons.check_circle_outline_rounded,
      'Cancelled' => Icons.cancel_outlined,
      _ => Icons.circle_outlined,
    };

/// "Activity" card: shows the technician / rider (name + call button) and the
/// time of every step, newest at the bottom. Hides itself on errors.
class ActivityTimelineCard extends ConsumerWidget {
  const ActivityTimelineCard({
    super.key,
    required this.kind,
    required this.id,
    this.title = 'Activity',
    this.showStaff = true,
  });

  final String kind;
  final String id;
  final String title;
  final bool showStaff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityTimelineProvider((kind: kind, id: id)));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (t) {
        if (t.events.isEmpty && t.staff == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (showStaff && t.staff != null) ...[
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${t.staff!.role}: ${t.staff!.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (t.staff!.phone.isNotEmpty)
                      IconButton.filledTonal(
                        onPressed: () => launchUrl(
                          Uri(scheme: 'tel', path: t.staff!.phone),
                        ),
                        icon: const Icon(Icons.call_rounded),
                        tooltip: 'Call',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              for (var i = 0; i < t.events.length; i++)
                _Row(
                  event: t.events[i],
                  last: i == t.events.length - 1,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.event, required this.last});
  final TimelineEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = last ? AppColors.primaryLight : AppColors.textSecondaryLight;
    final who = [
      if ((event.actorName ?? '').isNotEmpty) event.actorName!,
    ].join();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(_icon(event.status), size: 20, color: color),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: color.withAlpha(70)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label(event.status),
                    style: TextStyle(
                      fontWeight: last ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    AppDateUtils.formatDateTime(event.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if ((event.note ?? '').isNotEmpty)
                    Text(
                      event.note!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (who.isNotEmpty && event.actorRole != 'Customer')
                    Text(
                      'by $who',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
