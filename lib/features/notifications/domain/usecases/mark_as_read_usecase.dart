import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAsReadUseCase implements UseCase<void, String> {
  final NotificationRepository repository;
  const MarkAsReadUseCase(this.repository);
  @override
  Future<void> call(String id) => repository.markAsRead(id);
}
