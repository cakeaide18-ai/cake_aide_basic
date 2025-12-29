import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/repositories/order_repository.dart';
import 'package:cake_aide_basic/services/settings_service.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderRepository _repository = OrderRepository();
  final SettingsService _settingsService = SettingsService();
  
  // Prevent multiple saves
  bool _isSaving = false;

  // Form controllers
  final _orderNameController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();
  final _servingsController = TextEditingController();
  final _customDesignController = TextEditingController();
  final _cakeDetailsController = TextEditingController();

  // Form state
  OrderStatus _selectedStatus = OrderStatus.pending;
  DateTime? _orderDate;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  bool _isCustomDesign = false;

  // Cake photos (in-memory only for now)
  List<PlatformFile>? _cakeImages;

  @override
  void initState() {
    super.initState();
    // Default the order date to today for convenience; still editable by the user
    _orderDate = DateTime.now();
  }

  @override
  void dispose() {
    _orderNameController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _servingsController.dispose();
    _customDesignController.dispose();
    _cakeDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Add New Order'),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveOrder,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              _buildSectionTitle('Order Details'),
              const SizedBox(height: 16),
              _buildOrderDetailsSection(),

              const SizedBox(height: 24),
              _buildSectionTitle('Customer Information'),
              const SizedBox(height: 16),
              _buildCustomerInfoSection(),

              const SizedBox(height: 24),
              _buildSectionTitle('Cake Details'),
              const SizedBox(height: 16),
              _buildCakeDetailsSection(),

              const SizedBox(height: 24),
              _buildSectionTitle('Dates & Time'),
              const SizedBox(height: 16),
              _buildDatesSection(),

              const SizedBox(height: 24),
              _buildSectionTitle('Additional Information'),
              const SizedBox(height: 16),
              _buildAdditionalInfoSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return Column(
      children: [
        TextFormField(
          controller: _orderNameController,
          decoration: InputDecoration(
            labelText: 'Order Name *',
            hintText: 'e.g., Birthday Cake - John Smith',
            prefixIcon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Order name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<OrderStatus>(
          decoration: InputDecoration(
            labelText: 'Order Status',
            prefixIcon: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (OrderStatus? value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomerInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _customerNameController,
          decoration: InputDecoration(
            labelText: 'Customer Name *',
            hintText: 'Enter customer full name',
            prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Customer name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _customerPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
            prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _customerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCakeDetailsSection() {
    return Column(
      children: [
        TextFormField(
          controller: _cakeDetailsController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Cake Details *',
            hintText: 'Describe the cake details...\n\nExamples:\n• Chocolate fudge cake, 3-tier\n• Vanilla sponge, 8 inch round\n• Red velvet cupcakes (2 dozen)\n• Custom birthday cake with fondant decorations',
            prefixIcon: Icon(Icons.cake, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter cake details';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _servingsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Servings',
            hintText: 'Enter estimated servings',
            prefixIcon: Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price (${_settingsService.getCurrencySymbol()})',
            hintText: 'Enter order price',
            prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            title: const Text('Custom Design'),
            subtitle: const Text('Special design requirements'),
            value: _isCustomDesign,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _isCustomDesign = value ?? false;
              });
            },
          ),
        ),
        if (_isCustomDesign) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _customDesignController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Custom Design Notes',
              hintText: 'Describe the custom design requirements',
              prefixIcon: Icon(Icons.brush, color: Theme.of(context).colorScheme.primary),
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildCakePhotosSection(),
      ],
    );
  }

  Widget _buildDatesSection() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: const Text('Order Date'),
          subtitle: Text(
            _orderDate != null
                ? '${_orderDate!.day}/${_orderDate!.month}/${_orderDate!.year}'
                : 'Select order date',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectOrderDate(),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: const Text('Delivery Date'),
          subtitle: Text(
            _deliveryDate != null
                ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}'
                : 'Select delivery date',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectDeliveryDate(),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: const Text('Delivery Time'),
          subtitle: Text(
            _deliveryTime != null ? _deliveryTime!.format(context) : 'Select delivery time',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectDeliveryTime(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Order Notes',
        hintText: 'Add any special instructions or notes...',
        prefixIcon: Icon(Icons.note_add, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Future<void> _selectOrderDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _orderDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _orderDate) {
      setState(() {
        _orderDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _deliveryTime) {
      setState(() {
        _deliveryTime = picked;
      });
    }
  }

  void _saveOrder() async {
    // Prevent multiple saves
    if (_isSaving) return;
    
    if (_formKey.currentState!.validate()) {
      if (_deliveryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a delivery date'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        // Convert picked images to base64 strings for persistence in the order model
        final List<String> imageRefs = [];
        final files = _cakeImages ?? const <PlatformFile>[];
        for (final f in files) {
          if (f.bytes != null) {
            final b64 = base64Encode(f.bytes!);
            imageRefs.add(b64);
          }
        }

        final order = Order(
          id: '',
          name: _orderNameController.text.trim(),
          customerName: _customerNameController.text.trim(),
          customerPhone: _customerPhoneController.text.trim(),
          customerEmail: _customerEmailController.text.trim(),
          status: _selectedStatus,
          orderDate: _orderDate ?? DateTime.now(),
          deliveryDate: _deliveryDate,
          deliveryTime: _deliveryTime,
          notes: _notesController.text.trim(),
          cakeDetails: _cakeDetailsController.text.trim(),
          servings: int.tryParse(_servingsController.text) ?? 0,
          price: double.tryParse(_priceController.text) ?? 0.0,
          isCustomDesign: _isCustomDesign,
          customDesignNotes: _customDesignController.text.trim(),
          imageUrls: imageRefs,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Add detailed logging for debugging
        debugPrint('AddOrderScreen: About to save order: ${order.name}');
        debugPrint('AddOrderScreen: Order status: ${order.status}');
        debugPrint('AddOrderScreen: Customer: ${order.customerName}');
        debugPrint('AddOrderScreen: Delivery date: ${order.deliveryDate}');
        
        final orderId = await _repository.add(order);
        debugPrint('AddOrderScreen: Order saved successfully with ID: $orderId');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e, stackTrace) {
        debugPrint('AddOrderScreen: ❌ Error saving order: $e');
        debugPrint('AddOrderScreen: Stack trace: $stackTrace');
        
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          
          // More detailed error message
          String errorMessage = 'Error saving order: ';
          if (e.toString().contains('PERMISSION_DENIED')) {
            errorMessage += 'Permission denied. Please check your login status.';
          } else if (e.toString().contains('User not authenticated')) {
            errorMessage += 'You must be logged in to create orders.';
          } else if (e.toString().contains('index')) {
            errorMessage += 'Database index error. Please contact support.';
          } else {
            errorMessage += e.toString();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // --- Cake photos UI ---
  Widget _buildCakePhotosSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cake Photos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            TextButton.icon(
              onPressed: _pickCakeImages,
              icon: Icon(Icons.add_a_photo, color: theme.colorScheme.primary),
              label: Text('Add photos', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if ((_cakeImages ?? const []).isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No photos added yet. Tap "Add photos" to upload cake images.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (_cakeImages ?? const []).length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final file = (_cakeImages ?? const [])[index];
                final Uint8List? bytes = file.bytes;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: theme.colorScheme.surface,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: bytes != null
                          ? Image.memory(bytes, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.image_not_supported)),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        color: theme.colorScheme.primary,
                        onPressed: () => _removeCakeImage(index),
                        tooltip: 'Remove',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _pickCakeImages() async {
    try {
      debugPrint('[AddOrder] _pickCakeImages: Opening ImagePicker (web=$kIsWeb)');
      // Use ImagePicker for all platforms (web + mobile) to avoid FilePicker web plugin init issues
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      debugPrint('[AddOrder] _pickCakeImages: picked from ImagePicker = ${images.length}');
      if (images.isNotEmpty) {
        final newFiles = <PlatformFile>[];
        for (final x in images) {
          final bytes = await x.readAsBytes();
          newFiles.add(PlatformFile(
            name: x.name,
            bytes: bytes,
            size: bytes.length,
          ));
        }
        setState(() {
          (_cakeImages ??= []).addAll(newFiles);
        });
      }
    } catch (e, st) {
      debugPrint('[AddOrder] _pickCakeImages: ERROR: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  void _removeCakeImage(int index) {
    if (_cakeImages == null) return;
    if (index < 0 || index >= _cakeImages!.length) return;
    setState(() {
      _cakeImages!.removeAt(index);
    });
  }
}
