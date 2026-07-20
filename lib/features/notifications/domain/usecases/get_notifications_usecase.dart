import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  const GetNotificationsUseCase(this.repository);
  @override
  Future<List<NotificationEntity>> call(NoParams params) =>
      repository.getNotifications();
}
