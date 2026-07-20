import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/format_utils.dart';
import '../../domain/entities/vendor_sales_summary_entity.dart';

class CommissionBreakdownCard extends StatelessWidget {
  const CommissionBreakdownCard({super.key, required this.summary});

  final VendorSalesSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final commissionPercent = (AppConstants.commissionRate * 100).toStringAsFixed(0);

    return Container(
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
          Row(
            children: [
              Text(
                'Commission Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$commissionPercent% platform fee',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Row(
            label: 'Gross Revenue',
            value: FormatUtils.price(summary.totalRevenue),
          ),
          const SizedBox(height: 10),
          _Row(
            label: 'Platform Commission',
            value: '- ${FormatUtils.price(summary.totalCommission)}',
            valueColor: Theme.of(context).colorScheme.error,
          ),
          const Divider(height: 24),
          _Row(
            label: 'Your Net Earnings',
            value: FormatUtils.price(summary.netEarnings),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
            color: valueColor ??
                (isBold ? Theme.of(context).colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}
