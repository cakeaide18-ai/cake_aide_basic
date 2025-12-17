import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/repositories/shopping_list_repository.dart';
import 'package:cake_aide_basic/screens/shopping_list/add_shopping_list_screen.dart';
import 'package:cake_aide_basic/screens/shopping_list/shopping_list_details_screen.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/shopping_list_icon.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListRepository _repository = ShoppingListRepository();

  void _deleteShoppingList(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shopping List'),
        content: const Text('Are you sure you want to delete this shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _repository.delete(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shopping list deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting list: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  int _getTotalItemCount(ShoppingList shoppingList) {
    return shoppingList.recipes.length + 
           shoppingList.supplies.length + 
           shoppingList.ingredients.length;
  }

  int _getCheckedItemCount(ShoppingList shoppingList) {
    return shoppingList.recipes.where((r) => r.isChecked).length +
           shoppingList.supplies.where((s) => s.isChecked).length +
           shoppingList.ingredients.where((i) => i.isChecked).length;
  }

  List<String> _getPreviewItems(ShoppingList shoppingList) {
    final items = <String>[];
    
    // Add recipes
    for (final recipe in shoppingList.recipes.take(3)) {
      items.add('${recipe.recipe.name} (${recipe.quantity}x)');
    }
    
    // Add supplies if we have space
    final remainingSpace = 3 - items.length;
    if (remainingSpace > 0) {
      for (final supply in shoppingList.supplies.take(remainingSpace)) {
        items.add('${supply.supply.name} (${supply.quantity.toStringAsFixed(1)} ${supply.supply.unit})');
      }
    }
    
    // Add ingredients if we have space
    final finalSpace = 3 - items.length;
    if (finalSpace > 0) {
      for (final ingredient in shoppingList.ingredients.take(finalSpace)) {
        items.add('${ingredient.ingredient.name} (${ingredient.quantity.toStringAsFixed(1)} ${ingredient.ingredient.unit})');
      }
    }
    
    return items;
  }

  bool _isItemChecked(ShoppingList shoppingList, int index) {
    final previewItems = _getPreviewItems(shoppingList);
    if (index >= previewItems.length) return false;
    
    int currentIndex = 0;
    
    // Check recipes
    if (index < shoppingList.recipes.length) {
      return shoppingList.recipes[index].isChecked;
    }
    currentIndex += shoppingList.recipes.length;
    
    // Check supplies
    if (index < currentIndex + shoppingList.supplies.length) {
      return shoppingList.supplies[index - currentIndex].isChecked;
    }
    currentIndex += shoppingList.supplies.length;
    
    // Check ingredients
    if (index < currentIndex + shoppingList.ingredients.length) {
      return shoppingList.ingredients[index - currentIndex].isChecked;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return StreamBuilder<List<ShoppingList>>(
      stream: _repository.getStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context),
            body: Center(
              child: Text('Error loading shopping lists: ${snapshot.error}'),
            ),
          );
        }

        final shoppingLists = snapshot.data ?? [];
        return _buildScaffold(context, theme, shoppingLists);
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Shopping Lists'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: GradientDecorations.primaryGradient,
        ),
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildScaffold(BuildContext context, ThemeData theme, List<ShoppingList> shoppingLists) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Shopping Lists'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: shoppingLists.isEmpty
            ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: ShoppingListIcon(
                        size: 60,
                        fallbackColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                    Text(
                    'No Shopping Lists',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                    Text(
                    'Create your first shopping list with\nrecipes, supplies, and ingredients',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddShoppingListScreen(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Create New Shopping List',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Shopping Lists
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shoppingLists.length + 1, // +1 for the create button
                      itemBuilder: (context, index) {
                        // Show create button at the end
                        if (index == shoppingLists.length) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddShoppingListScreen(),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text(
                                'Create New Shopping List',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                        
                        final shoppingList = shoppingLists[index];
                        final checkedCount = _getCheckedItemCount(shoppingList);
                        final totalCount = _getTotalItemCount(shoppingList);
                        final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;
                        final previewItems = _getPreviewItems(shoppingList);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with title and menu
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        shoppingList.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _deleteShoppingList(shoppingList.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Progress section
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$checkedCount / $totalCount items',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.primary,
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Items preview
                                if (previewItems.isNotEmpty) ...[
                                  ...previewItems.asMap().entries.map((entry) {
                                    final itemIndex = entry.key;
                                    final item = entry.value;
                                    final isChecked = _isItemChecked(shoppingList, itemIndex);
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                        children: [
                                          Icon(
                                            isChecked
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            size: 20,
                                            color: isChecked
                                                ? theme.colorScheme.primary
                                                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                                  child: Text(
                                              item,
                                              style: TextStyle(
                                                      color: isChecked
                                                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                                                          : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                                decoration: isChecked
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (totalCount > 3)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, left: 32),
                                      child: Text(
                                        '+${totalCount - 3} more items',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                                
                                const SizedBox(height: 20),
                                
                                // View Details button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShoppingListDetailsScreen(
                                            shoppingList: shoppingList,
                                          ),
                                        ),
                                      ).then((_) => setState(() {}));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'View Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}