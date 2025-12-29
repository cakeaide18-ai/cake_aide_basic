import 'package:flutter/material.dart';
// services.dart not required here; removed to clean analyzer infos
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/services/data_service.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/repositories/recipe_repository.dart';
import 'package:cake_aide_basic/repositories/supply_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cake_aide_basic/theme.dart';

class AddQuoteScreen extends StatefulWidget {
  final Quote? quote;

  const AddQuoteScreen({super.key, this.quote});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();
  final SettingsService _settingsService = SettingsService();
  final RecipeRepository _recipeRepository = RecipeRepository();
  final SupplyRepository _supplyRepository = SupplyRepository();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeRequiredController = TextEditingController();
  final _marginController = TextEditingController(text: '20');
  final _deliveryController = TextEditingController(text: '0');
  
  // Selected values
  List<QuoteRecipe> _selectedRecipes = [];
  List<QuoteSupply> _selectedSupplies = [];
  
  bool _isCalculating = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.quote != null) {
      _populateFormWithQuote(widget.quote!);
    }
    
    // Add listeners for real-time calculation updates
    _timeRequiredController.addListener(_updateCalculations);
    _marginController.addListener(_updateCalculations);
    _deliveryController.addListener(_updateCalculations);
  }
  
  void _populateFormWithQuote(Quote quote) {
    _nameController.text = quote.name;
    _descriptionController.text = quote.description;
    _timeRequiredController.text = quote.timeRequired.toString();
    _marginController.text = quote.marginPercentage.toString();
    _deliveryController.text = quote.deliveryCost.toString();
    _selectedRecipes = List.from(quote.recipes);
    _selectedSupplies = List.from(quote.supplies);
  }
  
  void _updateCalculations() {
    setState(() {
      // Calculations will automatically update due to the computed getters
    });
  }

  @override
  void dispose() {
    _timeRequiredController.removeListener(_updateCalculations);
    _marginController.removeListener(_updateCalculations);
    _deliveryController.removeListener(_updateCalculations);
    _nameController.dispose();
    _descriptionController.dispose();
    _timeRequiredController.dispose();
    _marginController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }
  
  double get _totalIngredientCost {
    return _selectedRecipes.fold(0.0, (sum, quoteRecipe) {
      // Get the current version of the recipe to ensure we have the latest ingredient quantities
      final currentRecipe = _dataService.recipes.firstWhere(
        (r) => r.id == quoteRecipe.recipe.id,
        orElse: () => quoteRecipe.recipe, // fallback to stored recipe if not found
      );
      
      return sum + currentRecipe.ingredients.fold(0.0, (recipeSum, recipeIngredient) {
        return recipeSum + ((recipeIngredient.ingredient.price / recipeIngredient.ingredient.quantity) * recipeIngredient.quantity * quoteRecipe.quantity);
      });
    });
  }
  
  double get _totalSupplyCost {
    return _selectedSupplies.fold(0.0, (sum, quoteSupply) {
      return sum + (quoteSupply.supply.price * quoteSupply.quantity);
    });
  }
  
  double get _laborCost {
    final timeHours = double.tryParse(_timeRequiredController.text) ?? 0.0;
    return timeHours * _settingsService.pricePerHour;
  }
  
  double get _baseCost => _totalIngredientCost + _totalSupplyCost + _laborCost;
  double get _marginAmount => _baseCost * ((double.tryParse(_marginController.text) ?? 0.0) / 100);
  double get _deliveryCost => double.tryParse(_deliveryController.text) ?? 0.0;
  double get _totalCost => _baseCost + _marginAmount + _deliveryCost;
  
  void _addRecipe() async {
    // Load recipes from Firestore
    final recipes = await _recipeRepository.getAll();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _RecipeSelectionDialog(
        recipes: recipes,
        onRecipeSelected: (recipe, quantity) {
          setState(() {
            _selectedRecipes.add(QuoteRecipe(recipe: recipe, quantity: quantity));
          });
          _updateCalculations(); // Update calculations when recipe is added
        },
      ),
    );
  }
  
  void _removeRecipe(int index) {
    setState(() {
      _selectedRecipes.removeAt(index);
    });
    _updateCalculations(); // Update calculations when recipe is removed
  }
  
  void _addSupply() async {
    // Load supplies from Firestore
    final supplies = await _supplyRepository.getAll();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _SupplySelectionDialog(
        supplies: supplies,
        onSupplySelected: (supply, quantity) {
          setState(() {
            _selectedSupplies.add(QuoteSupply(supply: supply, quantity: quantity));
          });
          _updateCalculations(); // Update calculations when supply is added
        },
      ),
    );
  }
  
  void _removeSupply(int index) {
    setState(() {
      _selectedSupplies.removeAt(index);
    });
    _updateCalculations(); // Update calculations when supply is removed
  }
  
  void _calculateQuote() {
    setState(() {
      _isCalculating = true;
    });
    
    // Simulate calculation delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isCalculating = false;
      });
      
      // Show calculation results
      _showCalculationResults();
    });
  }
  
  void _showCalculationResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quote Calculation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cost Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCostRow('Ingredients', _totalIngredientCost),
              _buildCostRow('Supplies', _totalSupplyCost),
              _buildCostRow('Labor', _laborCost),
              const Divider(),
              _buildCostRow('Subtotal', _baseCost, isSubtotal: true),
              _buildCostRow('Margin (${_marginController.text}%)', _marginAmount),
              _buildCostRow('Delivery', _deliveryCost),
              const Divider(thickness: 2),
              _buildCostRow('Total', _totalCost, isTotal: true),
              const SizedBox(height: 16),
              if (_selectedRecipes.isNotEmpty) ...[
                Text(
                  'Selected Recipes (${_selectedRecipes.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedRecipes.map((quoteRecipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${quoteRecipe.recipe.name} (x${quoteRecipe.quantity})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (_selectedSupplies.isNotEmpty) ...[
                Text(
                  'Selected Supplies (${_selectedSupplies.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedSupplies.map((quoteSupply) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${quoteSupply.supply.name} (${quoteSupply.quantity} ${quoteSupply.supply.unit})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareQuote();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Share Quote'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCostRow(String label, double amount, {bool isSubtotal = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal || isSubtotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${_settingsService.getCurrencySymbol()}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal || isSubtotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
  
  void _shareQuote() {
    final quote = _buildQuoteText();
    // ignore: deprecated_member_use
    Share.share(
      quote,
      subject: 'Cake Quote - ${_nameController.text}',
    );
  }
  
  String _buildQuoteText() {
    final recipesText = _selectedRecipes.isEmpty ? 'No recipes selected' : 
        _selectedRecipes.map((qr) => '• ${qr.recipe.name} (x${qr.quantity})').join('\n');
    
    final suppliesText = _selectedSupplies.isEmpty ? 'No supplies selected' :
        _selectedSupplies.map((qs) => '• ${qs.supply.name} (${qs.quantity} ${qs.supply.unit})').join('\n');
    
    return '''
🎂 CAKE QUOTE 🎂

Order: ${_nameController.text}
Description: ${_descriptionController.text}

📋 RECIPES:
$recipesText

🛠️ SUPPLIES:
$suppliesText

📊 COST BREAKDOWN:
• Ingredients: ${_settingsService.getCurrencySymbol()}${_totalIngredientCost.toStringAsFixed(2)}
• Supplies: ${_settingsService.getCurrencySymbol()}${_totalSupplyCost.toStringAsFixed(2)}
• Labor (${_timeRequiredController.text} hours): ${_settingsService.getCurrencySymbol()}${_laborCost.toStringAsFixed(2)}

Subtotal: ${_settingsService.getCurrencySymbol()}${_baseCost.toStringAsFixed(2)}
Margin (${_marginController.text}%): ${_settingsService.getCurrencySymbol()}${_marginAmount.toStringAsFixed(2)}
Delivery: ${_settingsService.getCurrencySymbol()}${_deliveryCost.toStringAsFixed(2)}

💰 TOTAL: ${_settingsService.getCurrencySymbol()}${_totalCost.toStringAsFixed(2)}
  
  Generated with CakeAide Pro 🧁
    ''';
  }
  
  void _saveQuote() {
    if (!_formKey.currentState!.validate()) return;
    
    final quote = Quote(
      id: widget.quote?.id ?? _dataService.generateId(),
      name: _nameController.text,
      description: _descriptionController.text,
      recipes: _selectedRecipes,
      supplies: _selectedSupplies,
      timeRequired: double.tryParse(_timeRequiredController.text) ?? 0.0,
      marginPercentage: double.tryParse(_marginController.text) ?? 0.0,
      deliveryCost: double.tryParse(_deliveryController.text) ?? 0.0,
      createdAt: widget.quote?.createdAt ?? DateTime.now(),
    );
    
    if (widget.quote != null) {
      _dataService.updateQuote(widget.quote!.id, quote);
    } else {
      _dataService.addQuote(quote);
    }
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quote ${widget.quote != null ? 'updated' : 'created'} successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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
        title: Text(widget.quote != null ? 'Edit Quote' : 'Create Quote'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _calculateQuote,
            icon: _isCalculating 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.calculate),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionCard(
                'Basic Information',
                Icons.info_outline,
                [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Quote Name',
                      hintText: 'e.g., Birthday Cake - Sarah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Please enter a quote name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the cake order requirements...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Please enter a description' : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recipe Selection Section
              _buildSectionCard(
                'Recipe Selection',
                Icons.book,
                [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Selected Recipes (${_selectedRecipes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Recipe'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRecipes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text(
                          'No recipes selected\nTap "Add Recipe" to select recipes for cost calculation',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _selectedRecipes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final quoteRecipe = entry.value;
                        final ingredientCost = quoteRecipe.recipe.ingredients.fold(0.0, (sum, ingredient) {
                          return sum + (ingredient.ingredient.price * ingredient.quantity * quoteRecipe.quantity / ingredient.ingredient.quantity);
                        });
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.cake,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(quoteRecipe.recipe.name),
                            subtitle: Text(
                              'Quantity: ${quoteRecipe.quantity} • Cost: ${_settingsService.getCurrencySymbol()}${ingredientCost.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              onPressed: () => _removeRecipe(index),
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '• ${ingredient.ingredient.name} - $totalQuantity ${ingredient.unit}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ),
                                            Text(
                                              '${_settingsService.getCurrencySymbol()}${totalCost.toStringAsFixed(2)}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
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
                      }).toList(),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Supplies Section
              _buildSectionCard(
                'Supplies & Equipment',
                Icons.inventory,
                [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Selected Supplies (${_selectedSupplies.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addSupply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Supply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedSupplies.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text(
                          'No supplies selected\nTap "Add Supply" to include equipment and supplies',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _selectedSupplies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final quoteSupply = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.inventory,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(quoteSupply.supply.name),
                            subtitle: Text(
                              '${quoteSupply.quantity} ${quoteSupply.supply.unit} • ${_settingsService.getCurrencySymbol()}${(quoteSupply.supply.price * quoteSupply.quantity).toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              onPressed: () => _removeSupply(index),
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Pricing Parameters Section
              _buildSectionCard(
                'Pricing Parameters',
                Icons.settings,
                [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _timeRequiredController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Labor Time (hours)',
                            hintText: '2.5',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (double.tryParse(value!) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _marginController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Profit Margin %',
                            hintText: '20',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (double.tryParse(value!) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deliveryController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Delivery Cost',
                      hintText: '0',
                      border: const OutlineInputBorder(),
                      prefixText: '${_settingsService.getCurrencySymbol()} ',
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current hourly rate: ${_settingsService.getCurrencySymbol()}${_settingsService.pricePerHour.toStringAsFixed(2)}/hour\n(Change in Settings)',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Cost Summary Section
              _buildSectionCard(
                'Cost Summary',
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
                        _buildCostSummaryRow('Recipe Ingredients', _totalIngredientCost, 
                            icon: Icons.cake, isMain: true),
                        _buildCostSummaryRow('Supplies & Equipment', _totalSupplyCost, 
                            icon: Icons.inventory, isMain: true),
                        _buildCostSummaryRow('Labor Cost', _laborCost, icon: Icons.access_time),
                        const Divider(height: 24),
                        _buildCostSummaryRow('Subtotal', _baseCost, isBold: true),
                        _buildCostSummaryRow('Profit Margin (${_marginController.text}%)', _marginAmount),
                        _buildCostSummaryRow('Delivery', _deliveryCost),
                        const Divider(height: 24, thickness: 2),
                        _buildCostSummaryRow('TOTAL QUOTE', _totalCost, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _calculateQuote,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Preview & Share'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.save),
                      label: Text(widget.quote != null ? 'Update Quote' : 'Save Quote'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }
  
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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
  
  Widget _buildCostSummaryRow(String label, double amount, {
    bool isBold = false, 
    bool isTotal = false, 
    bool isMain = false,
    IconData? icon
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}

class _RecipeSelectionDialog extends StatefulWidget {
  final List<Recipe> recipes;
  final Function(Recipe, double) onRecipeSelected;
  
  const _RecipeSelectionDialog({
    required this.recipes,
    required this.onRecipeSelected,
  });
  
  @override
  State<_RecipeSelectionDialog> createState() => _RecipeSelectionDialogState();
}

class _RecipeSelectionDialogState extends State<_RecipeSelectionDialog> {
  Recipe? _selectedRecipe;
  final _quantityController = TextEditingController(text: '1');
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  double get _totalIngredientCost {
    if (_selectedRecipe == null) return 0.0;
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    return _selectedRecipe!.ingredients.fold(0.0, (sum, ingredient) {
      return sum + (ingredient.ingredient.price * ingredient.quantity * quantity / ingredient.ingredient.quantity);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Recipe>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Recipe',
                border: OutlineInputBorder(),
              ),
              items: widget.recipes.map((recipe) {
                return DropdownMenuItem<Recipe>(
                  value: recipe,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Serves ${recipe.cakeSizePortions} • ${recipe.ingredients.length} ingredients',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (recipe) {
                setState(() {
                  _selectedRecipe = recipe;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'How many of this recipe?',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}), // Refresh cost calculation
            ),
            if (_selectedRecipe != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe Cost Preview:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Serves: ${_selectedRecipe!.cakeSizePortions} portions per recipe',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Total Ingredient Cost: ${SettingsService().getCurrencySymbol()}${_totalIngredientCost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingredients (${_selectedRecipe!.ingredients.length}):',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ..._selectedRecipe!.ingredients.take(3).map((ingredient) => Text(
                      '• ${ingredient.ingredient.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    )),
                    if (_selectedRecipe!.ingredients.length > 3)
                      Text(
                        '... and ${_selectedRecipe!.ingredients.length - 3} more',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedRecipe != null && _quantityController.text.isNotEmpty
            ? () {
                final quantity = double.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  widget.onRecipeSelected(_selectedRecipe!, quantity);
                  Navigator.pop(context);
                }
              }
            : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Recipe'),
        ),
      ],
    );
  }
}

class _SupplySelectionDialog extends StatefulWidget {
  final List<Supply> supplies;
  final Function(Supply, double) onSupplySelected;
  
  const _SupplySelectionDialog({
    required this.supplies,
    required this.onSupplySelected,
  });
  
  @override
  State<_SupplySelectionDialog> createState() => _SupplySelectionDialogState();
}

class _SupplySelectionDialogState extends State<_SupplySelectionDialog> {
  Supply? _selectedSupply;
  final _quantityController = TextEditingController(text: '1');
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Supply'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Supply>(
            initialValue: _selectedSupply,
            decoration: const InputDecoration(
              labelText: 'Select Supply',
              border: OutlineInputBorder(),
            ),
            items: widget.supplies.map((supply) {
              return DropdownMenuItem<Supply>(
                value: supply,
                child: Text('${supply.name} - ${supply.brand}'),
              );
            }).toList(),
            onChanged: (supply) {
              setState(() {
                _selectedSupply = supply;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}), // Update cost calculation in real-time
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: const OutlineInputBorder(),
              suffixText: _selectedSupply?.unit,
            ),
          ),
          if (_selectedSupply != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cost Calculation:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unit Price: ${SettingsService().getCurrencySymbol()}${_selectedSupply!.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total: ${SettingsService().getCurrencySymbol()}${((double.tryParse(_quantityController.text) ?? 0) * _selectedSupply!.price).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedSupply != null && _quantityController.text.isNotEmpty
            ? () {
                final quantity = double.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  widget.onSupplySelected(_selectedSupply!, quantity);
                  Navigator.pop(context);
                }
              }
            : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Supply'),
        ),
      ],
    );
  }
}