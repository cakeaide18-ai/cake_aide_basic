import 'package:flutter/material.dart';
 import 'dart:convert';
 import 'package:file_picker/file_picker.dart';
 import 'package:share_plus/share_plus.dart';
 import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
 import 'package:image_picker/image_picker.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/repositories/order_repository.dart';
import 'package:cake_aide_basic/services/settings_service.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  
  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderRepository _repository = OrderRepository();
  final SettingsService _settingsService = SettingsService();
  
  // Form controllers
  late TextEditingController _orderNameController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _customerEmailController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _servingsController;
  late TextEditingController _customDesignController;
  late TextEditingController _cakeDetailsController;

  // Form state
  late OrderStatus _selectedStatus;
  DateTime? _orderDate;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  late bool _isCustomDesign;

  // Cake photos (not yet persisted; stored in-memory for this session)
  // Note: Using nullable + lazy init to be resilient to hot-reload of new fields
  List<PlatformFile>? _cakeImages;
  // Existing persisted images (urls or base64 strings) loaded from the order
  late List<String> _existingImageRefs;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing order data
    _orderNameController = TextEditingController(text: widget.order.name);
    _customerNameController = TextEditingController(text: widget.order.customerName);
    _customerPhoneController = TextEditingController(text: widget.order.customerPhone);
    _customerEmailController = TextEditingController(text: widget.order.customerEmail);
    _notesController = TextEditingController(text: widget.order.notes);
    _priceController = TextEditingController(
      text: widget.order.price > 0 ? widget.order.price.toString() : ''
    );
    _servingsController = TextEditingController(
      text: widget.order.servings > 0 ? widget.order.servings.toString() : ''
    );
    _customDesignController = TextEditingController(text: widget.order.customDesignNotes);
    _cakeDetailsController = TextEditingController(text: widget.order.cakeDetails);

    // Initialize form state
    _selectedStatus = widget.order.status;
    _orderDate = widget.order.orderDate;
    _deliveryDate = widget.order.deliveryDate;
    _deliveryTime = widget.order.deliveryTime;
    _isCustomDesign = widget.order.isCustomDesign;
    _existingImageRefs = List<String>.from(widget.order.imageUrls);
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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Order'),
        // Use themed AppBar colors from theme.dart (pink scheme)
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share),
            onPressed: _shareOrder,
          ),
          TextButton(
            onPressed: _saveOrder,
            child: const Text(
              'SAVE',
              style: TextStyle(
                // Keep legible contrast on AppBar
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
            labelText: 'Order Name',
            hintText: 'e.g., Birthday Cake - Sarah',
            prefixIcon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an order name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Status Selection
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
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Price
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price (${_settingsService.getCurrencySymbol()})',
            hintText: '0.00',
            prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
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
            labelText: 'Customer Name',
            hintText: 'Enter customer name',
            prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
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
        ),
      ],
    );
  }

  Widget _buildCakeDetailsSection() {
    return Column(
      children: [
        TextFormField(
          controller: _cakeDetailsController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Cake Details',
            hintText: 'Enter cake specifications (size, flavor, design, etc.)',
            prefixIcon: Icon(Icons.cake, color: Theme.of(context).colorScheme.primary),
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _servingsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Servings',
            hintText: 'e.g., 20',
            prefixIcon: Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Custom Design Toggle
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
                _isCustomDesign = value!;
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
        // Order Date
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
                : 'Select order date'
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectOrderDate(),
        ),
        const SizedBox(height: 8),
        
        // Delivery Date
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
                : 'Select delivery date'
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectDeliveryDate(),
        ),
        const SizedBox(height: 8),
        
        // Delivery Time
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
            _deliveryTime != null 
                ? _deliveryTime!.format(context)
                : 'Select delivery time'
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectDeliveryTime(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Additional Notes',
            hintText: 'Any special instructions or notes',
            prefixIcon: Icon(Icons.note_add, color: Theme.of(context).colorScheme.primary),
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectOrderDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _orderDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _orderDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _deliveryTime = picked;
      });
    }
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      // Convert newly picked images to base64 strings; existing refs are preserved
      final newImageRefs = <String>[];
      final files = _cakeImages ?? const <PlatformFile>[];
      for (final f in files) {
        if (f.bytes != null) {
          newImageRefs.add(base64Encode(f.bytes!));
        }
      }

      final combinedImages = <String>[..._existingImageRefs, ...newImageRefs];

      final updatedOrder = Order(
        id: widget.order.id, // Keep the same ID
        name: _orderNameController.text,
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        customerEmail: _customerEmailController.text,
        cakeDetails: _cakeDetailsController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        servings: int.tryParse(_servingsController.text) ?? 0,
        status: _selectedStatus,
        orderDate: _orderDate ?? DateTime.now(),
        deliveryDate: _deliveryDate,
        deliveryTime: _deliveryTime,
        isCustomDesign: _isCustomDesign,
        customDesignNotes: _customDesignController.text,
        notes: _notesController.text,
        imageUrls: combinedImages,
        createdAt: widget.order.createdAt, // Keep original creation time
        updatedAt: DateTime.now(), // Update the modification time
      );

      await _repository.update(updatedOrder.id, updatedOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        if ((_cakeImages ?? const []).isEmpty && _existingImageRefs.isEmpty)
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
              itemCount: _existingImageRefs.length + (_cakeImages?.length ?? 0),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                // First show existing refs, then newly picked files
                if (index < _existingImageRefs.length) {
                  final ref = _existingImageRefs[index];
                  Widget imageWidget;
                  if (ref.startsWith('http')) {
                    imageWidget = Image.network(ref, fit: BoxFit.cover);
                  } else {
                    // Treat as base64 string
                    try {
                      final bytes = base64Decode(ref);
                      imageWidget = Image.memory(bytes, fit: BoxFit.cover);
                    } catch (_) {
                      imageWidget = const Center(child: Icon(Icons.image_not_supported));
                    }
                  }
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
                        child: imageWidget,
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
                          onPressed: () {
                            setState(() {
                              _existingImageRefs.removeAt(index);
                            });
                          },
                          tooltip: 'Remove',
                        ),
                      ),
                    ],
                  );
                }

                // Newly picked image
                final localIndex = index - _existingImageRefs.length;
                final file = (_cakeImages ?? const [])[localIndex];
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
                        onPressed: () => _removeCakeImage(localIndex),
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
      debugPrint('[EditOrder] _pickCakeImages: Opening ImagePicker (web=$kIsWeb)');
      // Use ImagePicker for all platforms (web + mobile) to avoid FilePicker web plugin init issues
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      debugPrint('[EditOrder] _pickCakeImages: picked from ImagePicker = ${images.length}');
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
      debugPrint('[EditOrder] _pickCakeImages: ERROR: $e\n$st');
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

  Future<void> _shareOrder() async {
    final buffer = StringBuffer();
    buffer.writeln('Order: ${_orderNameController.text}');
    buffer.writeln('Status: ${_selectedStatus.displayName}');
    buffer.writeln('Customer: ${_customerNameController.text}');
    if (_customerPhoneController.text.isNotEmpty) buffer.writeln('Phone: ${_customerPhoneController.text}');
    if (_customerEmailController.text.isNotEmpty) buffer.writeln('Email: ${_customerEmailController.text}');
    if (_servingsController.text.isNotEmpty) buffer.writeln('Servings: ${_servingsController.text}');
    if (_priceController.text.isNotEmpty) buffer.writeln('Price: ${_settingsService.getCurrencySymbol()}${_priceController.text}');
    if (_orderDate != null) buffer.writeln('Order Date: ${_orderDate!.day}/${_orderDate!.month}/${_orderDate!.year}');
    if (_deliveryDate != null) buffer.writeln('Delivery Date: ${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}');
    if (_deliveryTime != null) buffer.writeln('Delivery Time: ${_deliveryTime!.format(context)}');
    if (_cakeDetailsController.text.isNotEmpty) {
      buffer.writeln('\nCake Details:\n${_cakeDetailsController.text}');
    }
    if (_isCustomDesign && _customDesignController.text.isNotEmpty) {
      buffer.writeln('\nCustom Design Notes:\n${_customDesignController.text}');
    }
    if (_notesController.text.isNotEmpty) {
      buffer.writeln('\nAdditional Notes:\n${_notesController.text}');
    }

    final text = buffer.toString();
    debugPrint('[EditOrder] _shareOrder: Attempting share (web=$kIsWeb)');
    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: 'Order: ${_orderNameController.text}');
    } catch (e, st) {
      debugPrint('[EditOrder] _shareOrder: ERROR using Share.share: $e\n$st');
      await _showShareFallback(text, error: e.toString());
    }
  }

  Future<void> _showShareFallback(String text, {String? error}) async {
    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share not available on this device. Showing copy option. ($error)')),
      );
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Order',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 240),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(text),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, color: Colors.red),
                    label: const Text('Copy', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}