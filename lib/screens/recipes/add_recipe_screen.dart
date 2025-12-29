import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/repositories/recipe_repository.dart';
import 'package:cake_aide_basic/repositories/ingredient_repository.dart';
import 'package:cake_aide_basic/theme.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // null for adding, non-null for editing
  
  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cakeSizeController = TextEditingController();
  final _scrollController = ScrollController();
  final RecipeRepository _repository = RecipeRepository();
  final IngredientRepository _ingredientRepository = IngredientRepository();
  
  List<RecipeIngredient> _recipeIngredients = [];
  List<TextEditingController> _quantityControllers = [];
  List<Ingredient> _availableIngredients = [];
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.recipe!.name;
      _cakeSizeController.text = widget.recipe!.cakeSizePortions;
      // Store the original recipe ingredients temporarily
      _recipeIngredients = List.from(widget.recipe!.ingredients);
      _quantityControllers = _recipeIngredients.map((ingredient) => 
        TextEditingController(text: ingredient.quantity.toString())).toList();
    }
    _loadIngredients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cakeSizeController.dispose();
    _scrollController.dispose();
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _ingredientRepository.getAll();
      setState(() {
        _availableIngredients = ingredients;
        
        // If editing, match the recipe ingredients with freshly loaded ones by ID
        if (_isEditing && _recipeIngredients.isNotEmpty) {
          // Create a map of ingredient IDs to fresh ingredient objects
          final ingredientMap = {for (var ing in ingredients) ing.id: ing};
          
          // Update recipe ingredients to use fresh ingredient objects
          _recipeIngredients = _recipeIngredients.map((recipeIng) {
            final freshIngredient = ingredientMap[recipeIng.ingredient.id];
            if (freshIngredient != null) {
              return recipeIng.copyWith(ingredient: freshIngredient);
            }
            return recipeIng;
          }).toList();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ingredients: $e')),
        );
      }
    }
  }

  void _addIngredient() {
    if (_availableIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add ingredients first from the Ingredients page'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final firstIngredient = _availableIngredients.first;
    setState(() {
      _recipeIngredients.add(
        RecipeIngredient(
          ingredient: firstIngredient,
          quantity: 1.0,
          unit: firstIngredient.unit, // Use ingredient's default unit
        ),
      );
      _quantityControllers.add(TextEditingController(text: '1.0'));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _recipeIngredients.removeAt(index);
      _quantityControllers[index].dispose();
      _quantityControllers.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipeIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final recipe = Recipe(
      id: _isEditing ? widget.recipe!.id : '',
      name: _nameController.text.trim(),
      cakeSizePortions: _cakeSizeController.text.trim(),
      ingredients: _recipeIngredients,
      imagePath: _isEditing ? widget.recipe!.imagePath : null,
    );

    try {
      if (_isEditing) {
        await _repository.update(recipe.id, recipe);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        await _repository.add(recipe);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe added successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Add Recipe'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: GradientDecorations.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Recipe Details' : 'Create New Recipe',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditing ? 'Update your recipe information' : 'Add ingredients and quantities for your recipe',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                ),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 24),
                    _buildCakeSizeField(),
                    const SizedBox(height: 24),
                    _buildIngredientsSection(),
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _saveRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Update Recipe' : 'Save Recipe',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Recipe Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a recipe name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (_recipeIngredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ingredients added yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap "Add Ingredient" below to include ingredients in your recipe',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...List.generate(_recipeIngredients.length, (index) {
            return _buildIngredientRow(index);
          }),
        const SizedBox(height: 16),
        // Add Ingredient Button moved to bottom
        Center(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, color: Colors.green),
              label: const Text(
                'Add Ingredient',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.green, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIngredientRow(int index) {
    final recipeIngredient = _recipeIngredients[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredient ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () => _removeIngredient(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ingredient Dropdown
          DropdownButtonFormField<Ingredient>(
            value: recipeIngredient.ingredient, // Pre-select the current ingredient
            decoration: InputDecoration(
              labelText: 'Select Ingredient',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _availableIngredients.isEmpty ? null : _availableIngredients.map((ingredient) {
              return DropdownMenuItem(
                value: ingredient,
                child: Text('${ingredient.name} (${ingredient.brand})'),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select an ingredient';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _recipeIngredients[index] = RecipeIngredient(
                    ingredient: value,
                    quantity: recipeIngredient.quantity,
                    unit: value.unit, // Use the selected ingredient's default unit
                  );
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Quantity and Unit Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      // Scroll to make this field visible when focused
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          _scrollController.animateTo(
                            _scrollController.position.pixels + 100,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    }
                  },
                  child: TextFormField(
                    controller: _quantityControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter quantity';
                      }
                      final quantity = double.tryParse(value.trim());
                      if (quantity == null || quantity <= 0) {
                        return 'Enter valid quantity';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final quantity = double.tryParse(value.trim()) ?? recipeIngredient.quantity;
                      setState(() {
                        _recipeIngredients[index] = RecipeIngredient(
                          ingredient: recipeIngredient.ingredient,
                          quantity: quantity,
                          unit: recipeIngredient.unit,
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: [
                    'pieces',
                    'grams',
                    'kilograms',
                    'milliliters',
                    'liters',
                    'cups',
                    'tablespoons',
                    'teaspoons',
                    'dozen',
                    'packs',
                    'bottles',
                  ].contains(recipeIngredient.unit) 
                    ? recipeIngredient.unit 
                    : 'pieces',
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    'pieces',
                    'grams',
                    'kilograms',
                    'milliliters',
                    'liters',
                    'cups',
                    'tablespoons',
                    'teaspoons',
                    'dozen',
                    'packs',
                    'bottles',
                  ].map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _recipeIngredients[index] = RecipeIngredient(
                          ingredient: recipeIngredient.ingredient,
                          quantity: recipeIngredient.quantity,
                          unit: value,
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCakeSizeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cake Size / Portions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cakeSizeController,
          decoration: const InputDecoration(labelText: 'Cake Size/Portions'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter cake size or portions';
            }
            return null;
          },
        ),
      ],
    );
  }
}