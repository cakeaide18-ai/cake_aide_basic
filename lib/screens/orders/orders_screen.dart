import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/repositories/order_repository.dart';
import 'package:cake_aide_basic/screens/orders/add_order_screen.dart';
import 'package:cake_aide_basic/screens/orders/edit_order_screen.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/widgets/order_icon.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderRepository _repository = OrderRepository();
  final SettingsService _settingsService = SettingsService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
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
              child: Text('Error loading orders: ${snapshot.error}'),
            ),
          );
        }

        final orders = snapshot.data ?? [];
        return _buildScaffold(context, orders);
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Order Tracking'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: GradientDecorations.primaryGradient,
        ),
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildScaffold(BuildContext context, List<Order> orders) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Order Tracking'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Orders',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonFormField<OrderStatus>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? value) {
                    // Handle status filter change
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64, // Slightly taller/wider
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddOrderScreen()),
            );
            setState(() {}); // Refresh the screen
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
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
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Center(
              child: OrderIcon(size: 60, fallbackColor: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your customer orders',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddOrderScreen()),
              );
              setState(() {}); // Refresh the screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE69B4), // Hot pink
              foregroundColor: Colors.white,
              minimumSize: const Size(140, 48), // Slightly wider vertically
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.construction;
        break;
      case OrderStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editOrder(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: OrderIcon(size: 24, fallbackColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            order.status.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editOrder(order);
                    } else if (value == 'edit_status') {
                      _showEditStatusDialog(order);
                    } else if (value == 'delete') {
                      _showDeleteDialog(order);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit Order'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit_status',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Edit Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Customer and cake information
            const SizedBox(height: 12),
            if (order.customerName.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (order.cakeDetails.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.cakeDetails,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (order.price > 0) ...[
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_settingsService.getCurrencySymbol()}${order.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (order.notes.isNotEmpty) ...[
              Text(
                'Notes: ${order.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Delivery date and time
            if (order.deliveryDate != null) ...[
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (order.deliveryTime != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 2),
                    Text(
                      order.deliveryTime!.format(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  void _editOrder(Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditOrderScreen(order: order),
      ),
    );
    setState(() {}); // Refresh the screen
  }

  void _showEditStatusDialog(Order order) {
    OrderStatus selectedStatus = order.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: DropdownButtonFormField<OrderStatus>(
          decoration: const InputDecoration(
            labelText: 'Order Status',
            border: OutlineInputBorder(),
          ),
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (OrderStatus? value) {
            if (value != null) {
              selectedStatus = value;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedOrder = order.copyWith(
                status: selectedStatus,
                updatedAt: DateTime.now(),
              );
              _repository.update(order.id, updatedOrder);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete ${order.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _repository.delete(order.id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting order: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}