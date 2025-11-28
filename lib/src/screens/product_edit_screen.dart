import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categories = ["Grocery", "Bakery", "Diary", "Stationaries", "Gift Shop", "Fresh Meat", "Clothing", "Medicines/Pharma", "Others"];
  String? _selectedCategory;

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _customCategoryController = TextEditingController();

  File? _imageFile;
  String? _networkImageUrl;
  bool _isLoading = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    // This is a bit of a hack to get arguments after the first frame.
    // A better approach would be to use a provider to pass arguments.
    Future.delayed(Duration.zero, () {
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      if (product != null) {
        _loadProductData(product);
      }
    });
  }

  void _loadProductData(Product product) {
    setState(() {
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2);
      _stockController.text = product.stock.toString();
      _networkImageUrl = product.imageUrl;
      _isAvailable = product.isAvailable;
      _brandController.text = product.brand ?? '';
      _sizeController.text = product.size ?? '';
      _descriptionController.text = product.description ?? '';
      _discountController.text = product.discount?.toString() ?? '';
      _selectedCategory = _categories.contains(product.category) ? product.category : 'Others';
      if (_selectedCategory == 'Others') _customCategoryController.text = product.category ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_imageFile == null && _networkImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an image.")));
      return;
    }

    setState(() => _isLoading = true);

    final authState = ref.read(authProvider);
    final user = authState.user;
    final token = authState.token;

    if (user == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Authentication error. Please log in again.")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      String imageUrl = _networkImageUrl ?? '';
      if (_imageFile != null) {
        // Corrected line
        imageUrl = await apiService.uploadImage(_imageFile!, 'products/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      final form = {
        'id': (ModalRoute.of(context)?.settings.arguments as Product?)?.id, // Pass ID for updates
        'name': _nameController.text,
        'brand': _brandController.text,
        'category': _selectedCategory == 'Others' ? _customCategoryController.text : _selectedCategory,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text),
        'size': _sizeController.text,
        'description': _descriptionController.text,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'image_url': imageUrl,
        'is_available': _isAvailable,
      };

      form.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

      // Corrected line
      await apiService.createProduct(form, token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product saved successfully!")));
        ref.invalidate(productListProvider); // This will refresh the product list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save product: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as Product?;

    return Scaffold(
      appBar: AppBar(title: Text(product == null ? "Add Product" : "Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // --- Image Picker ---
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
                        : (_networkImageUrl != null
                            ? Image.network(_networkImageUrl!, fit: BoxFit.cover)
                            : const Center(child: Icon(Iconsax.gallery_add, size: 40, color: Colors.grey))),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Category Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null ? "Please select a category" : null,
              ),
              if (_selectedCategory == "Others") ...[
                const SizedBox(height: 16),
                CustomTextField(controller: _customCategoryController, labelText: "Custom Category Name", validator: (v) => v!.isEmpty ? "Required" : null),
              ],
              const SizedBox(height: 16),
              CustomTextField(controller: _nameController, labelText: "Product Name", validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _brandController, labelText: "Brand (Optional)"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: _priceController, labelText: "Price", keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Required" : null)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(controller: _discountController, labelText: "Discount % (Optional)", keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(controller: _sizeController, labelText: "Size / Weight (e.g., 1kg, 250g)"),
              const SizedBox(height: 16),
              CustomTextField(controller: _descriptionController, labelText: "Description", maxLines: 3),
              const SizedBox(height: 16),
              CustomTextField(controller: _stockController, labelText: "Stock Count", keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Available for purchase"),
                value: _isAvailable,
                onChanged: (val) => setState(() => _isAvailable = val),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
              ),
              const SizedBox(height: 24),
              CustomButton(text: "SAVE PRODUCT", onPressed: _saveProduct, isLoading: _isLoading),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}