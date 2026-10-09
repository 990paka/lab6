
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/access_model.dart';

part 'access_event.dart';
part 'access_state.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final AccessModel model;

  AccessBloc({AccessModel? model})
      : model = model ?? AccessModel.variant2(fixed: useFixedMatrix),
        super(const AccessState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<AccessRequestEvent>(_onAccess);
    on<GrantEvent>(_onGrant);
    on<RevokeEvent>(_onRevoke);
    on<ShowRightsEvent>(_onShowRights);
    on<ShowMatrixEvent>(_onShowMatrix);
  }

  void _onLogin(LoginEvent event, Emitter<AccessState> emit) {
    final name = event.name.trim();
    final sb = StringBuffer('User: $name\n');
    if (!model.hasUser(name)) {
      sb.write('Идентификация не пройдена.\n\n');
      emit(state.copyWith(log: state.log + sb.toString()));
      return;
    }
    sb.write('Идентификация успешна, добро пожаловать в систему.\n\n');
    sb.write('${model.showRights(name)}\n\n');
    emit(state.copyWith(currentUser: name, log: state.log + sb.toString()));
  }

  void _onLogout(LogoutEvent event, Emitter<AccessState> emit) {
    emit(state.copyWith(
      logout: true,
      log: '${state.log}> quit\nВыход из системы.\n\n',
    ));
  }

  void _onAccess(AccessRequestEvent event, Emitter<AccessState> emit) {
    final user = state.currentUser;
    if (user == null) return;
    final obj = event.object?.toString() ?? '?';
    final result = model.access(user, event.object, event.right);
    emit(state.copyWith(
      log: '${state.log}> ${event.right.key} (объект $obj)\n$result\n\n',
    ));
  }

  void _onGrant(GrantEvent event, Emitter<AccessState> emit) {
    final user = state.currentUser;
    if (user == null) return;
    final obj = event.object?.toString() ?? '?';
    final result = model.grant(user, event.object, event.right, event.target);
    emit(state.copyWith(
      log: '${state.log}> grant (объект $obj, право ${event.right.key}, '
          'получатель ${event.target})\n$result\n\n',
    ));
  }

  void _onRevoke(RevokeEvent event, Emitter<AccessState> emit) {
    final user = state.currentUser;
    if (user == null) return;
    final obj = event.object?.toString() ?? '?';
    final result = model.revoke(user, event.object, event.right, event.target);
    emit(state.copyWith(
      log: '${state.log}> revoke (объект $obj, право ${event.right.key}, '
          'пользователь ${event.target})\n$result\n\n',
    ));
  }

  void _onShowRights(ShowRightsEvent event, Emitter<AccessState> emit) {
    final user = state.currentUser;
    if (user == null) return;
    emit(state.copyWith(
      log: '${state.log}> rights\n${model.showRights(user)}\n\n',
    ));
  }

  void _onShowMatrix(ShowMatrixEvent event, Emitter<AccessState> emit) {
    final user = state.currentUser;
    if (user == null) return;
    emit(state.copyWith(
      log: '${state.log}> matrix\n${model.showMatrix(user)}\n\n',
    ));
  }
}