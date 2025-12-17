import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/screens/shopping_list/add_shopping_list_screen.dart';
import 'package:cake_aide_basic/repositories/shopping_list_repository.dart';
import 'package:cake_aide_basic/theme.dart';

// Helper class for calculated ingredients
class CalculatedIngredient {
  final Ingredient ingredient;
  final double totalQuantity;
  final String unit;
  bool isChecked;
  
  CalculatedIngredient({
    required this.ingredient,
    required this.totalQuantity,
    required this.unit,
    this.isChecked = false,
  });
}

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList shoppingList;
  
  const ShoppingListDetailsScreen({
    super.key,
    required this.shoppingList,
  });

  @override
  State<ShoppingListDetailsScreen> createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  final ShoppingListRepository _repository = ShoppingListRepository();
  late ShoppingList _currentShoppingList;

  @override
  void initState() {
    super.initState();
    _currentShoppingList = widget.shoppingList;
  }



  void _toggleSupplyCheck(int index) {
    final updatedSupplies = List<ShoppingListSupply>.from(_currentShoppingList.supplies);
    updatedSupplies[index] = updatedSupplies[index].copyWith(
      isChecked: !updatedSupplies[index].isChecked,
    );
    _updateShoppingList(supplies: updatedSupplies);
  }

  void _toggleIngredientCheck(int index) {
    final updatedIngredients = List<ShoppingListIngredient>.from(_currentShoppingList.ingredients);
    updatedIngredients[index] = updatedIngredients[index].copyWith(
      isChecked: !updatedIngredients[index].isChecked,
    );
    _updateShoppingList(ingredients: updatedIngredients);
  }

  void _toggleCalculatedIngredientCheck(int index) {
    final calculatedIngredients = _calculatedIngredients;
    final item = calculatedIngredients[index];
    final key = '${item.ingredient.id}_${item.unit}';
    
    final updatedChecks = Map<String, bool>.from(_currentShoppingList.calculatedIngredientChecks);
    updatedChecks[key] = !(updatedChecks[key] ?? false);
    
    _updateShoppingList(calculatedIngredientChecks: updatedChecks);
  }

  void _updateShoppingList({
    List<ShoppingListSupply>? supplies,
    List<ShoppingListIngredient>? ingredients,
    Map<String, bool>? calculatedIngredientChecks,
  }) {
    final updatedShoppingList = _currentShoppingList.copyWith(
      supplies: supplies,
      ingredients: ingredients,
      calculatedIngredientChecks: calculatedIngredientChecks,
    );
    _repository.update(updatedShoppingList.id, updatedShoppingList);
    setState(() {
      _currentShoppingList = updatedShoppingList;
    });
  }

  List<CalculatedIngredient> get _calculatedIngredients {
    final Map<String, CalculatedIngredient> ingredientMap = {};
    
    // Calculate ingredients from all recipes
    for (final shoppingListRecipe in _currentShoppingList.recipes) {
      for (final recipeIngredient in shoppingListRecipe.recipe.ingredients) {
        final key = '${recipeIngredient.ingredient.id}_${recipeIngredient.unit}';
        final calculatedQuantity = recipeIngredient.quantity * shoppingListRecipe.quantity;
        
        if (ingredientMap.containsKey(key)) {
          // Add to existing quantity
          ingredientMap[key] = CalculatedIngredient(
            ingredient: recipeIngredient.ingredient,
            totalQuantity: ingredientMap[key]!.totalQuantity + calculatedQuantity,
            unit: recipeIngredient.unit,
            isChecked: ingredientMap[key]!.isChecked,
          );
        } else {
          // Create new entry with persisted checkbox state
          ingredientMap[key] = CalculatedIngredient(
            ingredient: recipeIngredient.ingredient,
            totalQuantity: calculatedQuantity,
            unit: recipeIngredient.unit,
            isChecked: _currentShoppingList.calculatedIngredientChecks[key] ?? false,
          );
        }
      }
    }
    
    return ingredientMap.values.toList();
  }

  int get _totalItems => _currentShoppingList.supplies.length + 
                         _currentShoppingList.ingredients.length +
                         _calculatedIngredients.length;

  int get _checkedItems => _currentShoppingList.supplies.where((s) => s.isChecked).length +
                          _currentShoppingList.ingredients.where((i) => i.isChecked).length +
                          _calculatedIngredients.where((i) => i.isChecked).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_currentShoppingList.name),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddShoppingListScreen(
                    shoppingList: _currentShoppingList,
                  ),
                ),
              );
              // Refresh the shopping list from repository
              final updatedList = await _repository.getById(_currentShoppingList.id);
              if (updatedList != null) {
                setState(() {
                  _currentShoppingList = updatedList;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$_checkedItems of $_totalItems items completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_calculatedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_calculatedIngredients.length} ingredients auto-calculated from recipes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: LinearProgressIndicator(
                    value: _totalItems > 0 ? _checkedItems / _totalItems : 0,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          // Shopping List Items
          Expanded(
            child: _totalItems == 0
                ? const Center(
                    child: Text(
                      'No items in this shopping list',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Recipe Ingredients Section (Auto-calculated)
                      if (_calculatedIngredients.isNotEmpty) ...[
                        // Header with summary
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calculate,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Shopping List (Auto-calculated)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'These ingredients are automatically calculated based on your selected recipes and their quantities. Total: ${_calculatedIngredients.length} ${_calculatedIngredients.length == 1 ? 'ingredient' : 'ingredients'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._calculatedIngredients.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isChecked = item.isChecked;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: GestureDetector(
                                onTap: () {
                                  _toggleCalculatedIngredientCheck(index);
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isChecked ? theme.colorScheme.primary : theme.colorScheme.surface,
                                    border: Border.all(
                                      color: isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                '${item.ingredient.name} (${item.ingredient.brand})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                  color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.totalQuantity.toStringAsFixed(1)} ${item.unit}',
                                    style: TextStyle(
                                      color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Calculated from recipes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : Colors.orange[700],
                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: item.ingredient.price > 0
                                  ? Text(
                                      '${item.ingredient.currency}${(item.ingredient.price * item.totalQuantity / item.ingredient.quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : Colors.orange,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.calculate,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Supplies Section
                      if (_currentShoppingList.supplies.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.construction,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Supplies',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._currentShoppingList.supplies.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isChecked = item.isChecked;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: GestureDetector(
                                onTap: () => _toggleSupplyCheck(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isChecked ? theme.colorScheme.primary : theme.colorScheme.surface,
                                    border: Border.all(
                                      color: isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                item.supply.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                  color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity.toStringAsFixed(1)} ${item.supply.unit}',
                                    style: TextStyle(
                                      color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (item.supply.brand != 'Generic')
                                    Text(
                                      item.supply.brand,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: item.supply.price > 0
                                  ? Text(
                                      '\$${(item.supply.price * item.quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.primary,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.construction,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Additional Ingredients Section (manually added)
                      if (_currentShoppingList.ingredients.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Additional Ingredients',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._currentShoppingList.ingredients.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isChecked = item.isChecked;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: GestureDetector(
                                onTap: () => _toggleIngredientCheck(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isChecked ? theme.colorScheme.primary : theme.colorScheme.surface,
                                    border: Border.all(
                                      color: isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                '${item.ingredient.name} (${item.ingredient.brand})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                  color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                '${item.quantity.toStringAsFixed(1)} ${item.ingredient.unit}',
                                style: TextStyle(
                                  color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              trailing: item.ingredient.price > 0
                                  ? Text(
                                      '\$${(item.ingredient.price * item.quantity / item.ingredient.quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.primary,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.local_grocery_store,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}