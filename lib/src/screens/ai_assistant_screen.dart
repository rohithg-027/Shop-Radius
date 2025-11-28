import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final tc = TextEditingController();
  String reply = '';
  bool loading = false;

  _ask() async {
    if (tc.text.trim().isEmpty) return;
    setState(() => loading = true);
    final auth = ref.read(authProvider);
    final res = await apiService.askAI(tc.text.trim(), auth?.token ?? '');
    setState(() {
      reply = res['reply'] ?? res.toString();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('Ask the assistant for inventory, offers or sales tips'))),
          const SizedBox(height: 12),
          TextField(controller: tc, decoration: const InputDecoration(labelText: 'Ask something...')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: loading ? null : _ask, child: loading ? const CircularProgressIndicator() : const Text('Ask')),
          const SizedBox(height: 20),
          if (reply.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(reply))),
        ]),
      ),
    );
  }
}
