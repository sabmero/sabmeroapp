import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../domain/entities/vendor_sales_summary_entity.dart';

class SalesSummaryCard extends StatelessWidget {
  const SalesSummaryCard({super.key, required this.summary});

  final VendorSalesSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Earnings',
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FormatUtils.price(summary.netEarnings),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatColumn(
                label: 'Revenue',
                value: FormatUtils.priceCompact(summary.totalRevenue),
              ),
              _StatColumn(
                label: 'Commission',
                value: FormatUtils.priceCompact(summary.totalCommission),
              ),
              _StatColumn(
                label: 'Orders',
                value: '${summary.totalOrders}',
              ),
              _StatColumn(
                label: 'Pending',
                value: '${summary.pendingOrders}',
                valueColor: AppColors.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
