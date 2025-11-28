import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ServiceEditScreen extends ConsumerStatefulWidget {
  const ServiceEditScreen({super.key});

  @override
  ConsumerState<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends ConsumerState<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categories = ["Salon", "Mechanic", "Pet Care", "Cyber Cafe", "Gaming Zone", "Others"];
  String? _selectedCategory;

  final _nameController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customCategoryController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveService() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Authentication error.")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await apiService.uploadImage(_imageFile!, 'services/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      final formData = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory == 'Others' ? _customCategoryController.text.trim() : _selectedCategory,
        'price_range': _priceRangeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': imageUrl,
      };

      await apiService.createService(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service saved successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save service: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : const Center(child: Icon(Iconsax.gallery_add, size: 40, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                decoration: InputDecoration(labelText: "Service Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null ? "Please select a category" : null,
              ),
              if (_selectedCategory == "Others") ...[
                const SizedBox(height: 16),
                CustomTextField(controller: _customCategoryController, labelText: "Custom Category Name", validator: (v) => v!.isEmpty ? "Required" : null),
              ],
              const SizedBox(height: 16),
              CustomTextField(controller: _nameController, labelText: "Service Name", validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _priceRangeController, labelText: "Price Range (e.g., ₹200-₹500)", validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _descriptionController, labelText: "Description", maxLines: 3),
              const SizedBox(height: 24),
              CustomButton(text: "SAVE SERVICE", onPressed: _isLoading ? null : _saveService, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}