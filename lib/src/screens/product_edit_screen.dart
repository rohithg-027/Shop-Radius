import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key});
  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> form = {};
  bool loading = false;

  _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    await apiService.createProduct(form, 'mock-token');
    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => form['name'] = v),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, onSaved: (v) => form['price'] = double.tryParse(v ?? '0') ?? 0),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, onSaved: (v) => form['stock'] = int.tryParse(v ?? '0') ?? 0),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Image URL'), onSaved: (v) => form['image_url'] = v),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loading ? null : _save, child: loading ? const CircularProgressIndicator() : const Text('Save'))
          ]),
        ),
      ),
    );
  }
}
