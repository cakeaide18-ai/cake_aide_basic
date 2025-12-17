import 'package:flutter/material.dart';
import 'package:cake_aide_basic/widgets/ingredient_icon.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/repositories/ingredient_repository.dart';
import 'package:cake_aide_basic/services/settings_service.dart';

class AddIngredientScreen extends StatefulWidget {
  final Ingredient? ingredient; // Optional ingredient for editing
  
  const AddIngredientScreen({super.key, this.ingredient});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  String _selectedUnit = 'grams';

  final List<String> _units = [
    'grams',
    'kilograms',
    'liters',
    'milliliters',
    'pieces',
    'dozen',
    'bottles',
    'cups',
    'tablespoons',
    'teaspoons',
  ];

  final IngredientRepository _repository = IngredientRepository();
  final SettingsService _settingsService = SettingsService();
  bool get isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final ingredient = widget.ingredient!;
      _nameController.text = ingredient.name;
      _brandController.text = ingredient.brand;
      _priceController.text = ingredient.price.toString();
      _quantityController.text = ingredient.quantity.toString();
      
      // Ensure the unit exists in our dropdown list
      if (_units.contains(ingredient.unit)) {
        _selectedUnit = ingredient.unit;
      } else {
        _selectedUnit = _units.first; // Default to first unit if not found
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveIngredient() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ingredient = Ingredient(
          id: isEditing ? widget.ingredient!.id : '', // Repository will generate ID
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          unit: _selectedUnit,
          currency: _settingsService.getCurrencySymbol(),
          quantity: double.parse(_quantityController.text.trim()),
        );

        if (isEditing) {
          await _repository.update(ingredient.id, ingredient);
        } else {
          await _repository.add(ingredient);
        }
        
        if (context.mounted) {
          Navigator.pop(context, true);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Ingredient updated successfully!' : 'Ingredient added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saving ingredient: $e');
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving ingredient: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Ingredient' : 'Add Ingredient'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const IngredientIcon(size: 48),
                    const SizedBox(height: 12),
                    Text(
                      isEditing ? 'Edit Ingredient' : 'Add New Ingredient',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing ? 'Update the details below' : 'Fill in the details below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Ingredient Name
              Text(
                'Ingredient Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'E.g. flour, eggs, sugar',
                  prefixIcon: Icon(Icons.local_grocery_store),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter ingredient name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Brand
              Text(
                'Brand',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  hintText: 'Enter brand name',
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Price
              Text(
                'Price',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  prefixIcon: const Icon(Icons.payments),
                  prefixText: '${_settingsService.getCurrencySymbol()} ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Quantity/Size
              Text(
                'Quantity/Size',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Quantity Field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Enter quantity',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Unit Selector
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveIngredient,
                  child: Text(
                    isEditing ? 'Update Ingredient' : 'Add Ingredient',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}