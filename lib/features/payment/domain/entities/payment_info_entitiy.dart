// Payment info the app shows the user: the QR image to scan and instructions.
class PaymentInfoEntity {
  final String? qrImagePath; // server path to the QR image (may be null if unset)
  final String instructions;

  const PaymentInfoEntity({
    required this.qrImagePath,
    required this.instructions,
  });
}
