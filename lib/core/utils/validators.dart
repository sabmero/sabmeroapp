class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = normalizePhone(value);
    if (!RegExp(r'^9[6-9]\d{8}$').hasMatch(cleaned)) {
      return 'Enter a valid 10-digit Nepali phone number';
    }
    return null;
  }

  /// Strips spaces, dashes and any +977 / 977 country code, returning the
  /// bare 10-digit local number that the API expects.
  static String normalizePhone(String value) {
    var cleaned = value.replaceAll(RegExp(r'\s|-'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\+?977'), '');
    return cleaned;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'Enter the 6-digit OTP';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final num = double.tryParse(value);
    if (num == null || num <= 0) return 'Enter a valid price';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.isEmpty) return 'Quantity is required';
    final num = int.tryParse(value);
    if (num == null || num < 0) return 'Enter a valid quantity';
    return null;
  }
}
