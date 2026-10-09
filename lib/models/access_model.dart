import 'dart:math';

/// true  - матрица из таблицы 1 отчёта (для скриншотов и проверки сценариев);
/// false - случайная матрица при каждом запуске, как в задании.
const bool useFixedMatrix = true;

/// Множество прав S = {Чтение, Запись, Передача прав}.
enum Right {
  read('read', 'Чтение'),
  write('write', 'Запись'),
  grant('grant', 'Передача прав');

  const Right(this.key, this.ru);
  final String key;
  final String ru;
}

/// Дискреционная модель: matrix[пользователь][номер объекта] = множество прав.
class AccessModel {
  static const ok = 'Операция выполнена успешно.';
  static const errRights = 'Ошибка: недостаточно прав.';

  final List<String> users;
  final int nObjects;
  final String admin;
  final Map<String, Map<int, Set<Right>>> _matrix = {};

  AccessModel({
    required this.users,
    required this.nObjects,
    required this.admin,
    required bool random,
  }) {
    final rnd = Random();
    for (final u in users) {
      final row = <int, Set<Right>>{};
      for (var o = 1; o <= nObjects; o++) {
        if (u == admin) {
          row[o] = Right.values.toSet();
        } else if (random) {
          row[o] = Right.values.where((_) => rnd.nextDouble() < 0.5).toSet();
        } else {
          row[o] = <Right>{};
        }
      }
      _matrix[u] = row;
    }
  }

  /// Вариант 2: 4 пользователя, 4 объекта.
  factory AccessModel.variant2({required bool fixed}) {
    final m = AccessModel(
      users: ['Ivan', 'Sergey', 'Boris', 'Anna'],
      nObjects: 4,
      admin: 'Ivan',
      random: !fixed,
    );
    if (fixed) {
      const r = Right.read, w = Right.write, g = Right.grant;
      m._set('Sergey', 1, {g});
      m._set('Sergey', 2, {r});
      m._set('Sergey', 3, {w});
      m._set('Sergey', 4, {g});

      m._set('Boris', 1, {r, w});
      m._set('Boris', 3, {r, w, g});
      m._set('Boris', 4, {r, w, g});

      m._set('Anna', 1, {r});
      m._set('Anna', 2, {w, g});
      m._set('Anna', 3, {r, w});
      m._set('Anna', 4, {g});
    }
    return m;
  }

  void _set(String user, int obj, Set<Right> rights) =>
      _matrix[user]![obj] = rights;

  Set<Right> _cell(String user, int obj) => _matrix[user]![obj]!;

  bool _validObject(int? obj) => obj != null && obj >= 1 && obj <= nObjects;

  String get _errObject => 'Ошибка: объекта с таким номером нет (1..$nObjects).';

  bool hasUser(String name) => _matrix.containsKey(name);

  String rightsText(Set<Right> rights) {
    if (rights.isEmpty) return 'Запрещено';
    if (rights.length == Right.values.length) return 'Полный доступ';
    return Right.values.where(rights.contains).map((r) => r.ru).join(', ');
  }

  String showRights(String user) {
    final sb = StringBuffer('Ваши права:\n');
    _matrix[user]!.forEach((obj, rights) {
      sb.writeln('Объект$obj: ${rightsText(rights)}');
    });
    return sb.toString().trimRight();
  }

  String showMatrix(String user) {
    if (user != admin) return errRights;
    final sb = StringBuffer('Матрица доступа:\n');
    _matrix.forEach((u, row) {
      sb.writeln(u);
      row.forEach((obj, rights) {
        sb.writeln('  Объект$obj: ${rightsText(rights)}');
      });
    });
    return sb.toString().trimRight();
  }

  /// read / write
  String access(String user, int? obj, Right right) {
    if (!_validObject(obj)) return _errObject;
    return _cell(user, obj!).contains(right) ? ok : errRights;
  }

  /// Передача права другому пользователю.
  String grant(String user, int? obj, Right right, String target) {
    if (!_validObject(obj)) return _errObject;
    final own = _cell(user, obj!);
    if (!own.contains(Right.grant)) return errRights;
    if (!own.contains(right)) {
      return 'Ошибка: нельзя передать право, которым вы не обладаете.';
    }
    final name = target.trim();
    if (!hasUser(name)) return 'Ошибка: пользователь не найден.';
    _cell(name, obj).add(right);
    return ok;
  }

  /// Собственная функция: отзыв права у другого пользователя.
  String revoke(String user, int? obj, Right right, String target) {
    if (!_validObject(obj)) return _errObject;
    if (!_cell(user, obj!).contains(Right.grant)) return errRights;
    final name = target.trim();
    if (!hasUser(name)) return 'Ошибка: пользователь не найден.';
    if (name == admin) return 'Ошибка: права администратора отозвать нельзя.';
    final targetRights = _cell(name, obj);
    if (!targetRights.contains(right)) {
      return 'У пользователя и так нет этого права.';
    }
    targetRights.remove(right);
    return ok;
  }
}