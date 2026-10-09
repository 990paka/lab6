part of 'access_bloc.dart';

sealed class AccessEvent extends Equatable {
  const AccessEvent();

  @override
  List<Object?> get props => [];
}

/// Идентификация пользователя.
final class LoginEvent extends AccessEvent {
  final String name;
  const LoginEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// Выход из системы (quit).
final class LogoutEvent extends AccessEvent {
  const LogoutEvent();
}

/// Команды read / write.
final class AccessRequestEvent extends AccessEvent {
  final int? object;
  final Right right;
  const AccessRequestEvent(this.object, this.right);

  @override
  List<Object?> get props => [object, right];
}

/// Передача права другому пользователю.
final class GrantEvent extends AccessEvent {
  final int? object;
  final Right right;
  final String target;
  const GrantEvent(this.object, this.right, this.target);

  @override
  List<Object?> get props => [object, right, target];
}

/// Отзыв права у другого пользователя.
final class RevokeEvent extends AccessEvent {
  final int? object;
  final Right right;
  final String target;
  const RevokeEvent(this.object, this.right, this.target);

  @override
  List<Object?> get props => [object, right, target];
}

final class ShowRightsEvent extends AccessEvent {
  const ShowRightsEvent();
}

final class ShowMatrixEvent extends AccessEvent {
  const ShowMatrixEvent();
}