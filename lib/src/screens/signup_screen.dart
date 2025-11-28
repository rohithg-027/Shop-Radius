import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> form = {};
  String role = 'customer';
  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map && arg['role'] != null) role = arg['role'];
  }

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    final res = await apiService.signup({...form, 'role': role});
    setState(() => loading = false);
    final user = User.fromJson({...res['user'], 'token': res['token']});
    ref.read(authProvider.notifier).state = user;
    if (user.role == 'vendor') Navigator.pushReplacementNamed(context, '/vendor');
    else Navigator.pushReplacementNamed(context, '/customer');
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Text('Signing up as: ${role.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null, onSaved: (v) => form['name'] = v),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone, onSaved: (v) => form['phone'] = v),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, onSaved: (v) => form['email'] = v),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true, onSaved: (v) => form['password'] = v),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : const Text('Continue'))
          ]),
        ),
      ),
    );
  }
}
