import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';

/// What the staff member entered when handing over collected money.
class CollectionResult {
  const CollectionResult({
    required this.amount,
    required this.method,
    this.amountInWords,
    this.screenshotLocalPath,
  });

  final double amount;
  final String method; // 'Cash' | 'Online'
  final String? amountInWords;
  final String? screenshotLocalPath;
}

/// Shows the "Payment collected" dialog. Pass [fixedAmount] when the amount is
/// already known (a COD order); otherwise the person types it.
Future<CollectionResult?> showCollectionDialog(
  BuildContext context, {
  double? initialAmount,
  double? fixedAmount,
  String confirmLabel = 'Confirm',
}) {
  return showDialog<CollectionResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CollectionDialog(
      initialAmount: initialAmount,
      fixedAmount: fixedAmount,
      confirmLabel: confirmLabel,
    ),
  );
}

// The controllers live in this State and are disposed with it, AFTER the
// dialog has finished closing. (Disposing them right after showDialog returns
// crashes the app with "_dependents.isEmpty is not true".)
class _CollectionDialog extends StatefulWidget {
  const _CollectionDialog({
    this.initialAmount,
    this.fixedAmount,
    required this.confirmLabel,
  });

  final double? initialAmount;
  final double? fixedAmount;
  final String confirmLabel;

  @override
  State<_CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<_CollectionDialog> {
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.initialAmount != null
        ? widget.initialAmount!.toStringAsFixed(0)
        : '',
  );
  final TextEditingController _wordsCtrl = TextEditingController();
  String _method = 'Cash';
  String? _shotPath;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _wordsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickShot() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() {
        _shotPath = picked.path;
        _error = null;
      });
    }
  }

  void _submit() {
    final amount = widget.fixedAmount ?? double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount collected.');
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
    Navigator.of(context).pop(
      CollectionResult(
        amount: amount,
        method: _method,
        amountInWords: _method == 'Cash' ? _wordsCtrl.text.trim() : null,
        screenshotLocalPath: _method == 'Online' ? _shotPath : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment collected'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.fixedAmount != null)
              Text(
                'Collect ${AppConstants.currencySymbol} ${widget.fixedAmount!.toStringAsFixed(0)} from the customer.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            else
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount collected',
                  prefixText: '${AppConstants.currencySymbol} ',
                ),
              ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Cash',
                  label: Text('Cash'),
                  icon: Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: 'Online',
                  label: Text('Online'),
                  icon: Icon(Icons.qr_code_2_rounded),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (v) => setState(() {
                _method = v.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            if (_method == 'Cash')
              TextField(
                controller: _wordsCtrl,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Amount in words',
                  hintText: 'e.g. Five hundred rupees only',
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickShot,
                icon: Icon(
                  _shotPath == null
                      ? Icons.upload_file_rounded
                      : Icons.check_circle_rounded,
                ),
                label: Text(
                  _shotPath == null
                      ? 'Attach payment screenshot'
                      : 'Screenshot attached',
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
