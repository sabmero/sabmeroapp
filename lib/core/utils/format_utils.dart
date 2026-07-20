import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class FormatUtils {
  static String price(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');
    return '${AppConstants.currencySymbol} ${formatter.format(amount)}';
  }

  static String priceCompact(double amount) {
    if (amount >= 100000) {
      return '${AppConstants.currencySymbol} ${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '${AppConstants.currencySymbol} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return price(amount);
  }

  static String weight(double kg) {
    if (kg < 1) return '${(kg * 1000).toStringAsFixed(0)}g';
    return '${kg.toStringAsFixed(kg.truncateToDouble() == kg ? 0 : 1)}kg';
  }

  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '+977 ${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  static String orderStatus(String status) {
    return switch (status) {
      'pending' => 'Pending',
      'confirmed' => 'Confirmed',
      'processing' => 'Processing',
      'shipped' => 'Shipped',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      _ => status,
    };
  }

  static String repairStatus(String status) {
    return switch (status) {
      'pending' => 'Pending',
      'processing' => 'Processing',
      'on_the_way' => 'On the Way',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => status,
    };
  }
}
