import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shop/data/models/category_model.dart';
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

/// Money handed over to SabMero; the admin verifies or rejects it.
class StaffRemittance {
  StaffRemittance.fromJson(Map<String, dynamic> j)
      : id = _i(j['id']),
        amount = _d(j['amount']),
        method = '${j['method'] ?? 'Cash'}',
        status = '${j['status'] ?? 'Pending'}',
        rejectReason = j['rejectReason'] as String?,
        createdAt = DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
            DateTime.now();
  final int id;
  final double amount;
  final String method, status;
  final String? rejectReason;
  final DateTime createdAt;
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
        cashHeld = _d(j['cashHeld']),
        myQrPath = j['myQrPath'] as String?,
        earned = _d(j['earned']),
        payable = _d(j['payable']),
        commissionPercent = _d(j['commissionPercent']),
        remitted = _d(j['remitted']),
        remittedPending = _d(j['remittedPending']),
        remittances = (j['remittances'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StaffRemittance.fromJson)
            .toList(),
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
  final double cashHeld, remitted, remittedPending;
  final String? myQrPath;
  final double earned, payable, commissionPercent;
  final List<StaffRemittance> remittances;
  final List<StaffPayment> payments;
  final List<StaffJob> recent;
  bool get isRider => role == 'Rider';
}

final staffSummaryProvider = FutureProvider.autoDispose<StaffSummary>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/technician-payments/mine');
  return StaffSummary.fromJson(api.unwrapObject(res.data));
});

/// The admin's payment QR (what staff scan to send money to SabMero).
final adminQrProvider = FutureProvider.autoDispose<String?>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get('/payments/qr');
  final path = api.unwrapObject(res.data)['qrImagePath'] as String?;
  return (path == null || path.isEmpty) ? null : resolveImageUrl(path);
});

String _money(double v) => '${AppConstants.currencySymbol} ${v.toStringAsFixed(0)}';

/// One place for a technician / rider: how many jobs or deliveries, how much
/// money was collected from customers, and what SabMero has paid them.
class StaffSummaryScreen extends ConsumerWidget {
  const StaffSummaryScreen({super.key});

  Future<void> _pickMyQr(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    try {
      final api = ref.read(apiClientProvider);
      final form = FormData.fromMap({'file': await MultipartFile.fromFile(picked.path)});
      final up = await api.dio.post(ApiConstants.uploadPayment, data: form);
      final path = api.unwrapObject(up.data)['path'] as String?;
      final res = await api.dio.put('/staff-remittances/my-qr', data: {'qrImagePath': path});
      api.unwrapObject(res.data);
      ref.invalidate(staffSummaryProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR saved')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not save the QR. Try again.')));
      }
    }
  }

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
                  title: 'Hand over to SabMero',
                  children: [
                    _Line('Cash you still hold', _money(s.cashHeld), bold: true),
                    _Line('Handed over & verified', _money(s.remitted)),
                    if (s.remittedPending > 0)
                      _Line('Sent, waiting for admin to verify', _money(s.remittedPending)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => _HandOverDialog(suggested: s.cashHeld),
                          );
                          if (ok == true) ref.invalidate(staffSummaryProvider);
                        },
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Hand over money'),
                      ),
                    ),
                    for (final r in s.remittances)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_money(r.amount)} • ${r.method}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(AppDateUtils.formatDateTime(r.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if (r.status == 'Rejected' && (r.rejectReason ?? '').isNotEmpty)
                                    Text(r.rejectReason!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              r.status == 'Verified'
                                  ? 'Verified ✓'
                                  : r.status == 'Rejected'
                                      ? 'Rejected ✕'
                                      : 'Pending…',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: r.status == 'Verified'
                                    ? AppColors.successColor
                                    : r.status == 'Rejected'
                                        ? Colors.red
                                        : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 28),
                    Text('My payout QR (SabMero pays you here)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (s.myQrPath != null && s.myQrPath!.isNotEmpty)
                      Center(
                        child: Image.network(
                          resolveImageUrl(s.myQrPath),
                          height: 180,
                          errorBuilder: (_, __, ___) => const Text('QR image could not be loaded.'),
                        ),
                      )
                    else
                      const Text('No QR added yet.'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickMyQr(context, ref),
                        icon: const Icon(Icons.qr_code_2),
                        label: Text(s.myQrPath == null ? 'Add my QR' : 'Change my QR'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  title: 'Received from SabMero',
                  children: [
                    _Line('Your earnings (${s.commissionPercent.toStringAsFixed(0)}% of ${s.isRider ? 'delivery fees' : 'service charges'})',
                        _money(s.earned)),
                    _Line('Total received', _money(s.received), bold: true),
                    _Line('Still to receive', _money(s.payable)),
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


/// "Hand over money" — cash (amount in words) or online (admin's QR + screenshot).
/// The controllers live in this State so they are disposed after the dialog closes.
class _HandOverDialog extends ConsumerStatefulWidget {
  const _HandOverDialog({required this.suggested});
  final double suggested;

  @override
  ConsumerState<_HandOverDialog> createState() => _HandOverDialogState();
}

class _HandOverDialogState extends ConsumerState<_HandOverDialog> {
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.suggested > 0 ? widget.suggested.toStringAsFixed(0) : '',
  );
  final TextEditingController _wordsCtrl = TextEditingController();
  String _method = 'Cash';
  String? _shotPath;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _wordsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickShot() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() {
        _shotPath = picked.path;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount.');
      return;
    }
    if (_method == 'Cash' && _wordsCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Write the amount in words.');
      return;
    }
    if (_method == 'Online' && _shotPath == null) {
      setState(() => _error = 'Attach the payment screenshot.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      String? serverShot;
      if (_method == 'Online') {
        final form = FormData.fromMap({'file': await MultipartFile.fromFile(_shotPath!)});
        final up = await api.dio.post(ApiConstants.uploadPayment, data: form);
        serverShot = api.unwrapObject(up.data)['path'] as String?;
      }
      final res = await api.dio.post('/staff-remittances', data: {
        'amount': amount,
        'method': _method,
        'amountInWords': _method == 'Cash' ? _wordsCtrl.text.trim() : null,
        'screenshotPath': serverShot,
      });
      api.unwrapObject(res.data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not send. Check your internet and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = ref.watch(adminQrProvider);
    return AlertDialog(
      title: const Text('Hand over money'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '${AppConstants.currencySymbol} ',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Cash', label: Text('Cash'), icon: Icon(Icons.payments_outlined)),
                ButtonSegment(value: 'Online', label: Text('Online'), icon: Icon(Icons.qr_code_2)),
              ],
              selected: {_method},
              onSelectionChanged: (v) => setState(() => _method = v.first),
            ),
            const SizedBox(height: 12),
            if (_method == 'Cash')
              TextField(
                controller: _wordsCtrl,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Amount in words',
                  hintText: 'e.g. Five thousand rupees only',
                ),
              )
            else ...[
              const Text('Scan SabMero QR and pay:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              qr.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Could not load the QR.'),
                data: (url) => url == null
                    ? const Text('SabMero has not set a QR yet. Please hand over cash.')
                    : Center(
                        child: Image.network(
                          url,
                          height: 220,
                          errorBuilder: (_, __, ___) => const Text('QR image could not be loaded.'),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickShot,
                icon: Icon(_shotPath != null ? Icons.check_circle : Icons.upload_file),
                label: Text(_shotPath != null ? 'Screenshot attached' : 'Attach payment screenshot'),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Send'),
        ),
      ],
    );
  }
}
