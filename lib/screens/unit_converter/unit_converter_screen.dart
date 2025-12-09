import 'package:flutter/material.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/unit_converter_icon.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _inputController = TextEditingController();
  String _fromUnit = 'grams';
  String _toUnit = 'cups';
  String _selectedIngredient = 'All-purpose flour';
  double _result = 0.0;

  // Ingredient-specific conversions (grams per cup)
  final Map<String, double> _ingredientCupConversions = {
    'All-purpose flour': 120.0,
    'Bread flour': 127.0,
    'Cake flour': 114.0,
    'White sugar': 200.0,
    'Brown sugar (packed)': 213.0,
    'Powdered/Icing sugar': 120.0,
    'Butter': 227.0,
    'Milk': 240.0,
    'Heavy cream': 240.0,
    'Coconut flakes': 80.0,
    'Cocoa powder': 85.0,
    'Baking soda': 220.0,
    'Baking powder': 192.0,
    'Salt': 300.0,
    'Vanilla extract': 240.0,
  };

  final Map<String, double> _baseConversions = {
    'grams': 1.0,
    'kilograms': 1000.0,
    'ounces': 28.3495,
    'pounds': 453.592,
    'tablespoons': 15.0,
    'teaspoons': 5.0,
  };

  final List<String> _units = [
    'grams',
    'kilograms',
    'ounces',
    'pounds',
    'cups',
    'tablespoons',
    'teaspoons',
  ];

  List<String> get _ingredients => _ingredientCupConversions.keys.toList();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input != null) {
      double grams;
      
      // Convert input to grams first
      if (_fromUnit == 'cups') {
        grams = input * _ingredientCupConversions[_selectedIngredient]!;
      } else {
        grams = input * _baseConversions[_fromUnit]!;
      }
      
      // Convert grams to target unit
      double converted;
      if (_toUnit == 'cups') {
        converted = grams / _ingredientCupConversions[_selectedIngredient]!;
      } else {
        converted = grams / _baseConversions[_toUnit]!;
      }
      
      setState(() {
        _result = converted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Unit Converter'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  UnitConverterIcon(size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Unit Converter',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Convert between different baking units with ingredient-specific accuracy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Ingredient Selection (only show if converting to/from cups)
            if (_fromUnit == 'cups' || _toUnit == 'cups') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Ingredient',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                      Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedIngredient,
                        isExpanded: true,
                        items: _ingredients.map((ingredient) {
                          return DropdownMenuItem(
                            value: ingredient,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.grain,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedIngredient = value;
                              _result = 0.0; // Reset result when ingredient changes
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            TextFormField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount to convert',
                prefixIcon: Icon(Icons.numbers),
              ),
              onChanged: (value) {
                // Auto-convert as user types
                if (value.isNotEmpty) {
                  _convert();
                } else {
                  setState(() {
                    _result = 0.0;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fromUnit,
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
                                  _fromUnit = value;
                                  _result = 0.0; // Reset result when unit changes
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _toUnit,
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
                                  _toUnit = value;
                                  _result = 0.0; // Reset result when unit changes
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: GradientDecorations.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Convert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            if (_result > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UnitConverterIcon(size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Result',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_result.toStringAsFixed(2)} $_toUnit',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((_fromUnit == 'cups' || _toUnit == 'cups') && _selectedIngredient.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'for $_selectedIngredient',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Conversion info card
              const SizedBox(height: 16),
              if ((_fromUnit == 'cups' || _toUnit == 'cups') && _selectedIngredient.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Conversion Info',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1 cup of $_selectedIngredient = ${_ingredientCupConversions[_selectedIngredient]} grams',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}