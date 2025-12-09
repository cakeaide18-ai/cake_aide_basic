import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/services/data_service.dart';
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
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    if (widget.shoppingList != null) {
      _nameController.text = widget.shoppingList!.name;
      _recipes.addAll(widget.shoppingList!.recipes);
      _supplies.addAll(widget.shoppingList!.supplies);
      _ingredients.addAll(widget.shoppingList!.ingredients);
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

  void _saveShoppingList() {
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
          _dataService.updateShoppingList(shoppingList.id, shoppingList);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shopping list updated successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          _dataService.addShoppingList(shoppingList);
          
          // Navigate to shopping list details page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ShoppingListDetailsScreen(shoppingList: shoppingList),
            ),
          );
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
                        items: _dataService.recipes.map((recipe) {
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
                ],
              ),

              const SizedBox(height: 12),

              // Add Recipe Button
              if (_selectedRecipe != null && _recipeQuantityController.text.isNotEmpty)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: GradientDecorations.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _addRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Recipe'),
                    ),
                  ),
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
                        items: _dataService.supplies.map((supply) {
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
                ],
              ),

              const SizedBox(height: 12),

              // Add Supply Button
              if (_selectedSupply != null && _supplyQuantityController.text.isNotEmpty)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: GradientDecorations.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _addSupply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Supply'),
                    ),
                  ),
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
                        items: _dataService.ingredients.map((ingredient) {
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
                ],
              ),

              const SizedBox(height: 12),

              // Add Ingredient Button
              if (_selectedIngredient != null && _ingredientQuantityController.text.isNotEmpty)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: GradientDecorations.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Ingredient'),
                    ),
                  ),
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