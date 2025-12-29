import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/repositories/supply_repository.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/supply_icon.dart';

class AddSupplyScreen extends StatefulWidget {
  final Supply? supply;
  
  const AddSupplyScreen({super.key, this.supply});

  @override
  State<AddSupplyScreen> createState() => _AddSupplyScreenState();
}

class _AddSupplyScreenState extends State<AddSupplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  String _selectedUnit = 'pieces';

  final List<String> _units = ['pieces', 'boxes', 'packs', 'sets', 'grams', 'kilograms', 'ounces', 'pounds'];

  final SupplyRepository _repository = SupplyRepository();
  final SettingsService _settingsService = SettingsService();
  
  bool get _isEditing => widget.supply != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }
  
  void _populateFields() {
    final supply = widget.supply!;
    _nameController.text = supply.name;
    _brandController.text = supply.brand;
    _priceController.text = supply.price.toString();
    _quantityController.text = supply.quantity.toString();
    _selectedUnit = supply.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveSupply() async {
    if (_formKey.currentState!.validate()) {
      try {
        final supply = Supply(
          id: _isEditing ? widget.supply!.id : '',
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          quantity: double.parse(_quantityController.text.trim()),
          unit: _selectedUnit,
          currency: _settingsService.getCurrencySymbol(),
        );

        if (_isEditing) {
          await _repository.update(widget.supply!.id, supply);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Supply updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await _repository.add(supply);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Supply added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving supply: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
        title: Text(_isEditing ? 'Edit Supply' : 'Add Supply'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const SupplyIcon(
                      size: 48,
                      fallbackColor: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isEditing ? 'Edit Supply' : 'Add New Supply',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEditing ? 'Update the supply details' : 'Fill in the supply details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Supply Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'E.g. cake boxes, frosting bags',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter supply name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

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

              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: GradientDecorations.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _saveSupply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Supply' : 'Add Supply',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      ),
    );
  }
}