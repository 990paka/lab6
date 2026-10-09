part of 'access_bloc.dart';

final class AccessState extends Equatable {
  /// null - пользователь ещё не прошёл идентификацию.
  final String? currentUser;

  /// Текст "консоли".
  final String log;

  const AccessState({this.currentUser, this.log = ''});

  AccessState copyWith({String? currentUser, bool logout = false, String? log}) {
    return AccessState(
      currentUser: logout ? null : (currentUser ?? this.currentUser),
      log: log ?? this.log,
    );
  }

  @override
  List<Object?> get props => [currentUser, log];
}