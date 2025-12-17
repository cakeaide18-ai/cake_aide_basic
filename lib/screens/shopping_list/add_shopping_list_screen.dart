import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/repositories/shopping_list_repository.dart';
import 'package:cake_aide_basic/repositories/recipe_repository.dart';
import 'package:cake_aide_basic/repositories/supply_repository.dart';
import 'package:cake_aide_basic/repositories/ingredient_repository.dart';
import 'package:cake_aide_basic/screens/shopping_list/shopping_list_details_screen.dart';
import 'package:cake_aide_basic/theme.dart';

class AddShoppingListScreen extends StatefulWidget {
  final ShoppingList? shoppingList;

  const AddShoppingListScreen({super.key, this.shoppingList});

  @override
  State<AddShoppingListScreen> createState() => _AddShoppingListScreenState();
}

class _AddShoppingListScreenState extends State<AddShoppingListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recipeQuantityController = TextEditingController();
  final _supplyQuantityController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  
  Recipe? _selectedRecipe;
  Supply? _selectedSupply;
  Ingredient? _selectedIngredient;
  final List<ShoppingListRecipe> _recipes = [];
  final List<ShoppingListSupply> _supplies = [];
  final List<ShoppingListIngredient> _ingredients = [];
  
  final ShoppingListRepository _repository = ShoppingListRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();
  final SupplyRepository _supplyRepository = SupplyRepository();
  final IngredientRepository _ingredientRepository = IngredientRepository();
  
  List<Recipe> _availableRecipes = [];
  List<Supply> _availableSupplies = [];
  List<Ingredient> _availableIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.shoppingList != null) {
      _nameController.text = widget.shoppingList!.name;
      _recipes.addAll(widget.shoppingList!.recipes);
      _supplies.addAll(widget.shoppingList!.supplies);
      _ingredients.addAll(widget.shoppingList!.ingredients);
    }
  }

  Future<void> _loadData() async {
    try {
      final recipes = await _recipeRepository.getAll();
      final supplies = await _supplyRepository.getAll();
      final ingredients = await _ingredientRepository.getAll();
      setState(() {
        _availableRecipes = recipes;
        _availableSupplies = supplies;
        _availableIngredients = ingredients;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipeQuantityController.dispose();
    _supplyQuantityController.dispose();
    _ingredientQuantityController.dispose();
    super.dispose();
  }

  void _addRecipe() {
    if (_selectedRecipe != null && _recipeQuantityController.text.isNotEmpty) {
      final quantity = double.tryParse(_recipeQuantityController.text);
      if (quantity != null && quantity > 0) {
        setState(() {
          _recipes.add(ShoppingListRecipe(
            recipe: _selectedRecipe!,
            quantity: quantity,
          ));
          _selectedRecipe = null;
          _recipeQuantityController.clear();
        });
      }
    }
  }

  void _addSupply() {
    if (_selectedSupply != null && _supplyQuantityController.text.isNotEmpty) {
      final quantity = double.tryParse(_supplyQuantityController.text);
      if (quantity != null && quantity > 0) {
        setState(() {
          _supplies.add(ShoppingListSupply(
            supply: _selectedSupply!,
            quantity: quantity,
          ));
          _selectedSupply = null;
          _supplyQuantityController.clear();
        });
      }
    }
  }

  void _addIngredient() {
    if (_selectedIngredient != null && _ingredientQuantityController.text.isNotEmpty) {
      final quantity = double.tryParse(_ingredientQuantityController.text);
      if (quantity != null && quantity > 0) {
        setState(() {
          _ingredients.add(ShoppingListIngredient(
            ingredient: _selectedIngredient!,
            quantity: quantity,
          ));
          _selectedIngredient = null;
          _ingredientQuantityController.clear();
        });
      }
    }
  }

  void _removeRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);
    });
  }

  void _removeSupply(int index) {
    setState(() {
      _supplies.removeAt(index);
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveShoppingList() async {
    if (_formKey.currentState!.validate()) {
      final shoppingList = ShoppingList(
        id: widget.shoppingList?.id ?? '',
        name: _nameController.text,
        recipes: _recipes,
        supplies: _supplies,
        ingredients: _ingredients,
      );
      try {
        if (widget.shoppingList != null) {
          await _repository.update(shoppingList.id, shoppingList);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shopping list updated successfully!')),
            );
            Navigator.of(context).pop();
          }
        } else {
          final docId = await _repository.add(shoppingList);
          final savedList = shoppingList.copyWith(id: docId);
          
          if (mounted) {
            // Navigate to shopping list details page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ShoppingListDetailsScreen(shoppingList: savedList),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving shopping list. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.shoppingList != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Shopping List' : 'Create Shopping List'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter list name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Recipes Section
              const Text(
                'Recipes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
              const SizedBox(height: 16),
              
              // Add Recipe Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: _recipeQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) {
                          // Trigger rebuild when quantity changes
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<Recipe>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        hint: const Text('Select Recipe...'),
                        value: _selectedRecipe,
                        items: _availableRecipes.map((recipe) {
                          return DropdownMenuItem(
                            value: recipe,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  recipe.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  recipe.cakeSizePortions,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (Recipe? value) {
                          setState(() {
                            _selectedRecipe = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add Recipe Button - always visible, disabled when conditions not met
                  Container(
                    decoration: BoxDecoration(
                      gradient: (_selectedRecipe != null && _recipeQuantityController.text.isNotEmpty)
                          ? GradientDecorations.primaryGradient
                          : null,
                      color: (_selectedRecipe == null || _recipeQuantityController.text.isEmpty)
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: (_selectedRecipe != null && _recipeQuantityController.text.isNotEmpty)
                          ? _addRecipe
                          : null,
                      icon: const Icon(Icons.add),
                      color: (_selectedRecipe != null && _recipeQuantityController.text.isNotEmpty)
                          ? Colors.white
                          : Colors.grey.shade500,
                      tooltip: 'Add Recipe',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Added Recipes List
              if (_recipes.isNotEmpty) ...[
                const Text(
                  'Added Recipes:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final item = _recipes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.cake, color: Colors.pink),
                        ),
                        title: Text(item.recipe.name),
                        subtitle: Text('Quantity: ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeRecipe(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Supplies Section
              const Text(
                'Supplies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
              const SizedBox(height: 16),
              
              // Add Supply Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: _supplyQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) {
                          // Trigger rebuild when quantity changes
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<Supply>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        hint: const Text('Select Supply...'),
                        value: _selectedSupply,
                        items: _availableSupplies.map((supply) {
                          return DropdownMenuItem(
                            value: supply,
                            child: Text(supply.name),
                          );
                        }).toList(),
                        onChanged: (Supply? value) {
                          setState(() {
                            _selectedSupply = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add Supply Button - always visible, disabled when conditions not met
                  Container(
                    decoration: BoxDecoration(
                      gradient: (_selectedSupply != null && _supplyQuantityController.text.isNotEmpty)
                          ? GradientDecorations.primaryGradient
                          : null,
                      color: (_selectedSupply == null || _supplyQuantityController.text.isEmpty)
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: (_selectedSupply != null && _supplyQuantityController.text.isNotEmpty)
                          ? _addSupply
                          : null,
                      icon: const Icon(Icons.add),
                      color: (_selectedSupply != null && _supplyQuantityController.text.isNotEmpty)
                          ? Colors.white
                          : Colors.grey.shade500,
                      tooltip: 'Add Supply',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Added Supplies List
              if (_supplies.isNotEmpty) ...[
                const Text(
                  'Added Supplies:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _supplies.length,
                  itemBuilder: (context, index) {
                    final item = _supplies[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.construction, color: Colors.blue),
                        ),
                        title: Text(item.supply.name),
                        subtitle: Text('${item.quantity} ${item.supply.unit}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSupply(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Ingredients Section
              const Text(
                'Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
              const SizedBox(height: 16),
              
              // Add Ingredient Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: _ingredientQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) {
                          // Trigger rebuild when quantity changes
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<Ingredient>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        hint: const Text('Select Ingredient...'),
                        value: _selectedIngredient,
                        items: _availableIngredients.map((ingredient) {
                          return DropdownMenuItem(
                            value: ingredient,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${ingredient.name} (${ingredient.brand})',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Unit: ${ingredient.unit}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (Ingredient? value) {
                          setState(() {
                            _selectedIngredient = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add Ingredient Button - always visible, disabled when conditions not met
                  Container(
                    decoration: BoxDecoration(
                      gradient: (_selectedIngredient != null && _ingredientQuantityController.text.isNotEmpty)
                          ? GradientDecorations.primaryGradient
                          : null,
                      color: (_selectedIngredient == null || _ingredientQuantityController.text.isEmpty)
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: (_selectedIngredient != null && _ingredientQuantityController.text.isNotEmpty)
                          ? _addIngredient
                          : null,
                      icon: const Icon(Icons.add),
                      color: (_selectedIngredient != null && _ingredientQuantityController.text.isNotEmpty)
                          ? Colors.white
                          : Colors.grey.shade500,
                      tooltip: 'Add Ingredient',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Added Ingredients List
              if (_ingredients.isNotEmpty) ...[
                const Text(
                  'Added Ingredients:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final item = _ingredients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.local_grocery_store, color: Colors.green),
                        ),
                        title: Text('${item.ingredient.name} (${item.ingredient.brand})'),
                        subtitle: Text('${item.quantity} ${item.ingredient.unit}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeIngredient(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Create/Update List Button
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: GradientDecorations.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveShoppingList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Shopping List' : 'Create Shopping List',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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