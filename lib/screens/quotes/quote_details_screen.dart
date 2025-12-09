import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/services/data_service.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/screens/quotes/add_quote_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cake_aide_basic/theme.dart';

class QuoteDetailsScreen extends StatefulWidget {
  final Quote quote;

  const QuoteDetailsScreen({super.key, required this.quote});

  @override
  State<QuoteDetailsScreen> createState() => _QuoteDetailsScreenState();
}

class _QuoteDetailsScreenState extends State<QuoteDetailsScreen> {
  final DataService _dataService = DataService();
  final SettingsService _settingsService = SettingsService();
  late Quote _quote;

  @override
  void initState() {
    super.initState();
    _quote = widget.quote;
  }

  void _shareQuote() {
    final quoteText = _buildQuoteText();
    // ignore: deprecated_member_use
    Share.share(
      quoteText,
      subject: 'Cake Quote - ${_quote.name}',
    );
  }

  String _buildQuoteText() {
    final recipesText = _quote.recipes.isEmpty ? 'No recipes selected' : 
        _quote.recipes.map((qr) => '• ${qr.recipe.name} (x${qr.quantity})').join('\n');
    
    final suppliesText = _quote.supplies.isEmpty ? 'No supplies selected' :
        _quote.supplies.map((qs) => '• ${qs.supply.name} (${qs.quantity} ${qs.supply.unit})').join('\n');
    
    return '''
🎂 CAKE QUOTE 🎂

Order: ${_quote.name}
Description: ${_quote.description}

📋 RECIPES:
$recipesText

🛠️ SUPPLIES:
$suppliesText

📊 COST BREAKDOWN:
• Ingredients: ${_settingsService.getCurrencySymbol()}${_quote.totalIngredientCost.toStringAsFixed(2)}
• Supplies: ${_settingsService.getCurrencySymbol()}${_quote.totalSupplyCost.toStringAsFixed(2)}
• Labor (${_quote.timeRequired} hours): ${_settingsService.getCurrencySymbol()}${_quote.laborCost.toStringAsFixed(2)}

Subtotal: ${_settingsService.getCurrencySymbol()}${_quote.baseCost.toStringAsFixed(2)}
Margin (${_quote.marginPercentage}%): ${_settingsService.getCurrencySymbol()}${_quote.marginAmount.toStringAsFixed(2)}
Delivery: ${_settingsService.getCurrencySymbol()}${_quote.deliveryCost.toStringAsFixed(2)}

💰 TOTAL: ${_settingsService.getCurrencySymbol()}${_quote.totalCost.toStringAsFixed(2)}

Generated with CakeAide Pro 🧁
    ''';
  }

  void _editQuote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuoteScreen(quote: _quote),
      ),
    ).then((_) {
      // Refresh the quote data
      final updatedQuote = _dataService.quotes.firstWhere((q) => q.id == _quote.id);
      setState(() {
        _quote = updatedQuote;
      });
    });
  }

  void _deleteQuote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Quote'),
        content: const Text('Are you sure you want to delete this quote? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.deleteQuote(_quote.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to quotes list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quote deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Quote Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareQuote,
            icon: const Icon(Icons.share),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editQuote();
                  break;
                case 'delete':
                  _deleteQuote();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Quote'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Quote', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _quote.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _quote.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total: ${_settingsService.getCurrencySymbol()}${_quote.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cost Breakdown Section
            _buildSection(
              'Cost Breakdown',
              Icons.calculate,
              [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildCostRow('Recipe Ingredients', _quote.totalIngredientCost, 
                          icon: Icons.cake, isMain: true),
                      _buildCostRow('Supplies & Equipment', _quote.totalSupplyCost, 
                          icon: Icons.inventory, isMain: true),
                      _buildCostRow('Labor (${_quote.timeRequired} hours)', _quote.laborCost, 
                          icon: Icons.access_time),
                      const Divider(height: 24),
                      _buildCostRow('Subtotal', _quote.baseCost, isBold: true),
                      _buildCostRow('Profit Margin (${_quote.marginPercentage}%)', _quote.marginAmount),
                      _buildCostRow('Delivery', _quote.deliveryCost),
                      const Divider(height: 24, thickness: 2),
                      _buildCostRow('TOTAL QUOTE', _quote.totalCost, isTotal: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recipes Section
            if (_quote.recipes.isNotEmpty)
              _buildSection(
                'Recipes (${_quote.recipes.length})',
                Icons.book,
                [
                  ..._quote.recipes.map((quoteRecipe) {
                    final ingredientCost = quoteRecipe.recipe.ingredients.fold(0.0, (sum, ingredient) {
                      return sum + (ingredient.ingredient.price * ingredient.quantity * quoteRecipe.quantity / ingredient.ingredient.quantity);
                    });

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: quoteRecipe.recipe.imagePath != null 
                            ? NetworkImage(quoteRecipe.recipe.imagePath!) 
                            : null,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          child: quoteRecipe.recipe.imagePath == null
                            ? Icon(Icons.cake, color: Theme.of(context).colorScheme.primary)
                            : null,
                        ),
                        title: Text(
                          quoteRecipe.recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantity: x${quoteRecipe.quantity} • Cost: ${_settingsService.getCurrencySymbol()}${ingredientCost.toStringAsFixed(2)} • Serves: ${quoteRecipe.recipe.cakeSizePortions}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ingredients (${quoteRecipe.recipe.ingredients.length}):',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...quoteRecipe.recipe.ingredients.map((ingredient) {
                                  final totalQuantity = ingredient.quantity * quoteRecipe.quantity;
                                  final totalCost = ingredient.ingredient.price * totalQuantity / ingredient.ingredient.quantity;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '• ${ingredient.ingredient.name} (${ingredient.ingredient.brand})',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Text(
                                          '$totalQuantity ${ingredient.unit}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_settingsService.getCurrencySymbol()}${totalCost.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),

            if (_quote.recipes.isNotEmpty) const SizedBox(height: 24),

            // Supplies Section
            if (_quote.supplies.isNotEmpty)
              _buildSection(
                'Supplies & Equipment (${_quote.supplies.length})',
                Icons.inventory,
                [
                  ..._quote.supplies.map((quoteSupply) {
                    final cost = quoteSupply.supply.price * quoteSupply.quantity;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.inventory,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quoteSupply.supply.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${quoteSupply.supply.brand} • ${quoteSupply.quantity} ${quoteSupply.supply.unit}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_settingsService.getCurrencySymbol()}${cost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),

            if (_quote.supplies.isNotEmpty) const SizedBox(height: 24),

            // Additional Details Section
            _buildSection(
              'Quote Details',
              Icons.info_outline,
              [
                _buildDetailRow('Total Recipes', '${_quote.recipes.length} recipe${_quote.recipes.length != 1 ? 's' : ''}'),
                _buildDetailRow('Total Supplies', '${_quote.supplies.length} item${_quote.supplies.length != 1 ? 's' : ''}'),
                _buildDetailRow('Labor Time', '${_quote.timeRequired} hours'),
                _buildDetailRow('Profit Margin', '${_quote.marginPercentage}%'),
                _buildDetailRow('Delivery Cost', '${_settingsService.getCurrencySymbol()}${_quote.deliveryCost.toStringAsFixed(2)}'),
                _buildDetailRow('Created', _formatDate(_quote.createdAt)),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editQuote,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Quote'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Quote'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {
    bool isSubItem = false, 
    bool isTotal = false, 
    bool isBold = false,
    bool isMain = false,
    IconData? icon
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSubItem ? 16.0 : 0.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: 16, 
              color: isMain ? Theme.of(context).colorScheme.primary : Colors.grey[600]
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Theme.of(context).colorScheme.primary : 
                       isMain ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          Text(
            '${_settingsService.getCurrencySymbol()}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : 
                     isMain ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}