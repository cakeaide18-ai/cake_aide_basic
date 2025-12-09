import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/services/data_service.dart';
import 'package:cake_aide_basic/screens/supplies/add_supply_screen.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/supply_icon.dart';

class SuppliesScreen extends StatefulWidget {
  const SuppliesScreen({super.key});

  @override
  State<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends State<SuppliesScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final supplies = _dataService.supplies;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Supplies'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSupplyScreen()),
              );
              if (result == true) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: supplies.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: supplies.length,
              itemBuilder: (context, index) {
                final supply = supplies[index];
                return _buildSupplyCard(supply);
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: GradientDecorations.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSupplyScreen()),
            );
            if (result == true) {
              setState(() {});
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(60),
            ),
            alignment: Alignment.center,
            child: SupplyIcon(
              size: 60,
              fallbackColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Supplies Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first baking supply to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSupplyScreen()),
              );
              if (result == true) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Supply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyCard(Supply supply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: SupplyIcon(
                size: 24,
                fallbackColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supply.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supply.brand,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${supply.quantity} ${supply.unit} • ${supply.currency}${supply.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editSupply(supply);
                } else if (value == 'delete') {
                  _showDeleteDialog(supply);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editSupply(Supply supply) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSupplyScreen(supply: supply),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _showDeleteDialog(Supply supply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supply'),
        content: Text('Are you sure you want to delete ${supply.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _dataService.deleteSupply(supply.id);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}