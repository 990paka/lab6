import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/access_bloc.dart';
import '../models/access_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userCtrl = TextEditingController();
  final _objectCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _scroll = ScrollController();

  Right _right = Right.read;

  @override
  void dispose() {
    _userCtrl.dispose();
    _objectCtrl.dispose();
    _targetCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  AccessBloc get _bloc => context.read<AccessBloc>();

  int? get _objectInput => int.tryParse(_objectCtrl.text.trim());

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Widget _loginPanel() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: 'User'),
            onSubmitted: (_) => _bloc.add(LoginEvent(_userCtrl.text)),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () => _bloc.add(LoginEvent(_userCtrl.text)),
          child: const Text('Войти'),
        ),
      ],
    );
  }

  Widget _commandPanel(String user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Текущий пользователь: $user',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _objectCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Номер объекта'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Право'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Right>(
                    value: _right,
                    isDense: true,
                    isExpanded: true,
                    items: [
                      for (final r in Right.values)
                        DropdownMenuItem(value: r, child: Text(r.key)),
                    ],
                    onChanged: (r) => setState(() => _right = r ?? _right),
                  ),
                ),
              ),
            ),
          ],
        ),
        TextField(
          controller: _targetCtrl,
          decoration: const InputDecoration(
            labelText: 'Пользователь (для grant / revoke)',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () =>
                  _bloc.add(AccessRequestEvent(_objectInput, Right.read)),
              child: const Text('read'),
            ),
            FilledButton(
              onPressed: () =>
                  _bloc.add(AccessRequestEvent(_objectInput, Right.write)),
              child: const Text('write'),
            ),
            FilledButton(
              onPressed: () =>
                  _bloc.add(GrantEvent(_objectInput, _right, _targetCtrl.text)),
              child: const Text('grant'),
            ),
            FilledButton(
              onPressed: () =>
                  _bloc.add(RevokeEvent(_objectInput, _right, _targetCtrl.text)),
              child: const Text('revoke'),
            ),
            FilledButton(
              onPressed: () => _bloc.add(const ShowRightsEvent()),
              child: const Text('rights'),
            ),
            FilledButton(
              onPressed: () => _bloc.add(const ShowMatrixEvent()),
              child: const Text('matrix'),
            ),
            OutlinedButton(
              onPressed: () {
                _bloc.add(const LogoutEvent());
                _userCtrl.clear();
              },
              child: const Text('quit'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = _bloc.model;
    return Scaffold(
      appBar: AppBar(title: const Text('Дискреционная модель')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocConsumer<AccessBloc, AccessState>(
            listenWhen: (prev, curr) => prev.log != curr.log,
            listener: (context, state) => _scrollDown(),
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вариант 2: пользователей - ${model.users.length}, '
                    'объектов - ${model.nObjects}\n'
                    'Пользователи: ${model.users.join(', ')} '
                    '(администратор: ${model.admin})',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  state.currentUser == null
                      ? _loginPanel()
                      : _commandPanel(state.currentUser!),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: const Color(0xFFEEEEEE),
                      child: SingleChildScrollView(
                        controller: _scroll,
                        child: SelectableText(
                          state.log,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}