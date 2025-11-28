import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> form = {};
  bool loading = false;
  String role = 'customer';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map && arg['role'] != null) role = arg['role'];
  }

  _submit() async {
    _formKey.currentState!.save();
    setState(() => loading = true);
    final res = await apiService.login({...form, 'role': role});
    setState(() => loading = false);
    final user = User.fromJson({...res['user'], 'token': res['token']});
    ref.read(authProvider.notifier).state = user;
    if (user.role == 'vendor') Navigator.pushReplacementNamed(context, '/vendor');
    else Navigator.pushReplacementNamed(context, '/customer');
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Text('Login as: ${role.toUpperCase()}'),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Email or Phone'), onSaved: (v) => form['identifier'] = v),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true, onSaved: (v) => form['password'] = v),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : const Text('Login'))
          ]),
        ),
      ),
    );
  }
}
