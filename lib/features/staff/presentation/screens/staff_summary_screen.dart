import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class StaffPayment {
  StaffPayment.fromJson(Map<String, dynamic> j)
      : id = _i(j['id']),
        amount = _d(j['amount']),
        method = '${j['method'] ?? 'Cash'}',
        note = j['note'] as String?,
        status = '${j['status'] ?? 'Paid'}',
        createdAt = DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
            DateTime.now();
  final int id;
  final double amount;
  final String method, status;
  final String? note;
  final DateTime createdAt;
  bool get confirmed => status == 'Acknowledged';
}

class StaffJob {
  StaffJob.fromJson(Map<String, dynamic> j)
      : kind = '${j['kind'] ?? 'Booking'}',
        id = _i(j['bookingId']),
        title = '${j['serviceType'] ?? ''}',
        customer = '${j['customerName'] ?? ''}',
        amount = _d(j['amount']),
        method = '${j['method'] ?? ''}',
        at = DateTime.tryParse('${j['completedAt'] ?? ''}')?.toLocal();
  final String kind, title, customer, method;
  final int id;
  final double amount;
  final DateTime? at;
}

class StaffSummary {
  StaffSummary.fromJson(Map<String, dynamic> j)
      : role = '${j['role'] ?? 'Technician'}',
        jobs = _i(j['jobs']),
        jobsToday = _i(j['jobsToday']),
        jobsThisMonth = _i(j['jobsThisMonth']),
        cash = _d(j['collectedCash']),
        online = _d(j['collectedOnline']),
        collected = _d(j['collectedTotal']),
        collectedToday = _d(j['collectedToday']),
        deliveryFees = _d(j['deliveryFees']),
        received = _d(j['totalReceived']),
        pending = _i(j['pendingConfirmations']),
        payments = (j['payments'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StaffPayment.fromJson)
            .toList(),
        recent = (j['recentJobs'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StaffJob.fromJson)
            .toList();
  final String role;
  final int jobs, jobsToday, jobsThisMonth, pending;
  final double cash, online, collected, collectedToday, deliveryFees, received;
  final List<StaffPayment> payments;
  final List<StaffJob> recent;
  bool get isRider => role == 'Rider';
}

final staffSummaryProvider = FutureProvider.autoDispose<StaffSummary>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/technician-payments/mine');
  return StaffSummary.fromJson(api.unwrapObject(res.data));
});

String _money(double v) => '${AppConstants.currencySymbol} ${v.toStringAsFixed(0)}';

/// One place for a technician / rider: how many jobs or deliveries, how much
/// money was collected from customers, and what SabMero has paid them.
class StaffSummaryScreen extends ConsumerWidget {
  const StaffSummaryScreen({super.key});

  Future<void> _confirm(BuildContext context, WidgetRef ref, StaffPayment p) async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post('/technician-payments/${p.id}/acknowledge');
      api.unwrapMessage(res.data);
      ref.invalidate(staffSummaryProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Marked as received')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not confirm. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(staffSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Summary')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your summary'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(staffSummaryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (s) {
          final unit = s.isRider ? 'Deliveries' : 'Jobs';
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(staffSummaryProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _Stat(label: 'Today', value: '${s.jobsToday}', sub: '$unit • ${_money(s.collectedToday)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'This month', value: '${s.jobsThisMonth}', sub: unit)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'Total', value: '${s.jobs}', sub: unit)),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Collected from customers',
                  children: [
                    _Line('Total collected', _money(s.collected), bold: true),
                    _Line('Cash', _money(s.cash)),
                    _Line('Online', _money(s.online)),
                    if (s.isRider) _Line('Delivery fees (delivered orders)', _money(s.deliveryFees)),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Received from SabMero',
                  children: [
                    _Line('Total received', _money(s.received), bold: true),
                    if (s.pending > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          '${s.pending} payment(s) waiting for your confirmation',
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (s.payments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('No payments yet'),
                      ),
                    for (final p in s.payments)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_money(p.amount)} • ${p.method}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(AppDateUtils.formatDateTime(p.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if ((p.note ?? '').isNotEmpty)
                                    Text(p.note!, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            p.confirmed
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, size: 18, color: AppColors.successColor),
                                      SizedBox(width: 4),
                                      Text('Received'),
                                    ],
                                  )
                                : FilledButton(
                                    onPressed: () => _confirm(context, ref, p),
                                    child: const Text('Confirm'),
                                  ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: s.isRider ? 'Recent deliveries' : 'Recent jobs',
                  children: [
                    if (s.recent.isEmpty)
                      const Padding(padding: EdgeInsets.only(top: 4), child: Text('Nothing completed yet')),
                    for (final j in s.recent)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    j.kind == 'Order' ? 'Order #${j.id}' : '${j.title} • #${j.id}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${j.customer}${j.at != null ? ' • ${AppDateUtils.formatDateTime(j.at!)}' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_money(j.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(j.method, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.sub});
  final String label, value, sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(sub, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});
  final String label, value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
