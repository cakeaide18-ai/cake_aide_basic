import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cake_aide_basic/repositories/user_profile_repository.dart';
import 'package:cake_aide_basic/screens/ingredients/ingredients_screen.dart';
import 'package:cake_aide_basic/screens/supplies/supplies_screen.dart';
import 'package:cake_aide_basic/screens/recipes/recipes_screen.dart';
import 'package:cake_aide_basic/screens/quotes/quotes_screen.dart';
import 'package:cake_aide_basic/screens/shopping_list/shopping_list_screen.dart';
import 'package:cake_aide_basic/screens/unit_converter/unit_converter_screen.dart';
import 'package:cake_aide_basic/screens/orders/orders_screen.dart';
import 'package:cake_aide_basic/screens/timer/timer_screen.dart';
import 'package:cake_aide_basic/services/data_service.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/screens/reminders/reminders_screen.dart';
import 'package:cake_aide_basic/screens/settings/settings_screen.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/supabase/auth_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final AuthStateManager _authManager = AuthStateManager();
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  int _selectedOrderTab = 0;
  List<CategoryItem> _filteredCategories = [];
  late List<CategoryItem> _categories;
  File? _profileImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _authManager.addListener(_onAuthStateChanged);
    _filteredCategories = _categories;
    _searchController.addListener(_onSearchChanged);
    _loadProfileImage();
    // Load user profile if not already loaded
    // Wrapped in try-catch to handle cases where Supabase isn't initialized
    if (_authManager.userProfile == null && _authManager.currentUser != null) {
      _authManager.loadUserProfile().catchError((e) {
        debugPrint('Failed to load user profile in HomeScreen: $e');
      });
    }
  }

  void _initializeCategories() {
    _categories = [
      CategoryItem(
        title: 'Ingredients',
        imageUrl: 'assets/images/ingredients.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const IngredientsScreen())),
      ),
      CategoryItem(
        title: 'Supplies',
        imageUrl: 'assets/images/supplies.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliesScreen())),
      ),
      CategoryItem(
        title: 'Recipes',
        imageUrl: 'assets/images/recipes.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen())),
      ),
      CategoryItem(
        title: 'Quote Calculator',
        imageUrl: 'assets/images/quotes.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotesScreen())),
      ),
      CategoryItem(
        title: 'Shopping List',
        imageUrl: 'assets/images/shopping_list.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingListScreen())),
      ),
      CategoryItem(
        title: 'Unit Converter',
        imageUrl: 'assets/images/unit_converter.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitConverterScreen())),
      ),
      CategoryItem(
        title: 'Order Management',
        imageUrl: 'assets/images/orders.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
      ),
      CategoryItem(
        title: 'Work Timer',
        imageUrl: 'assets/images/timer.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerScreen())),
      ),
      CategoryItem(
        title: 'Reminders',
        imageUrl: 'assets/images/reminders.jpg',
        isAsset: true,
        onTap: (context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
      ),
      CategoryItem(
        title: 'Settings',
        imageUrl: 'assets/images/settings.jpg', // Replace with your actual image filename
        isAsset: true,
        onTap: (context) => _navigateToSettings(context),
      ),
    ];
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (kIsWeb) {
      // For web, check for base64 image data
      final webImageData = prefs.getString('profile_image_web');
      if (webImageData != null && webImageData.isNotEmpty) {
        try {
          final bytes = base64Decode(webImageData);
          setState(() {
            _webImageBytes = bytes;
          });
        } catch (e) {
          debugPrint('Error loading web profile image: $e');
        }
      }
    } else {
      // For mobile, load from file path
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthStateChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories.where((category) =>
          category.title.toLowerCase().contains(query)).toList();
      }
      _currentIndex = 0; // Reset to first page when searching
    });
  }

  Widget _getProfileImageWidget(String? profileImageUrl) {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
      );
    } else if (!kIsWeb && _profileImage != null && _profileImage!.existsSync()) {
      return Image.file(
        _profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
      );
    } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Icon(
          Icons.person,
          color: Colors.grey[400],
          size: 24,
        ),
      );
    }
  }

  Future<void> _navigateToSettings(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    // Refresh profile image when returning from settings
    _loadProfileImage();
  }
  
  void _showAllFeaturesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.apps,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'All Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            category.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.apps,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          category.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          category.onTap(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  




  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final orders = dataService.orders;
    
    // Filter orders based on selected tab
    List<Order> filteredOrders;
    String emptyStateMessage;
    
    switch (_selectedOrderTab) {
      case 0: // Today
        final today = DateTime.now();
        filteredOrders = orders.where((order) {
          final deliveryDate = order.deliveryDate;
          if (deliveryDate == null) return false;
          return deliveryDate.year == today.year &&
                 deliveryDate.month == today.month &&
                 deliveryDate.day == today.day &&
                 order.status != OrderStatus.completed;
        }).toList();
        emptyStateMessage = 'No orders for today';
        break;
        
      case 1: // Upcoming
        final today = DateTime.now();
        filteredOrders = orders.where((order) {
          final deliveryDate = order.deliveryDate;
          if (deliveryDate == null) return false;
          return deliveryDate.isAfter(today) &&
                 order.status != OrderStatus.completed;
        }).toList();
        emptyStateMessage = 'No upcoming orders';
        break;
        
      case 2: // Completed
        filteredOrders = orders.where((order) {
          return order.status == OrderStatus.completed;
        }).toList();
        emptyStateMessage = 'No completed orders';
        break;
        
      default:
        filteredOrders = [];
        emptyStateMessage = 'No orders';
    }
    
    // Get user profile data
    final userProfile = _authManager.userProfile;
    // Fallback to Firebase Auth displayName if Supabase profile not loaded
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userName = userProfile?.name ?? 
                     firebaseUser?.displayName ?? 
                     firebaseUser?.email?.split('@').first ?? 
                     'User';
    final profileImageUrl = userProfile?.profileImageUrl;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: GradientDecorations.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: _getProfileImageWidget(profileImageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                        // Refresh profile image when returning from settings
                        _loadProfileImage();
                      },
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Search bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Categories section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Categories grid with navigation arrows
              SizedBox(
                height: 140,
                child: _filteredCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No categories found',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemCount: (_filteredCategories.length / 2).ceil(),
                            itemBuilder: (context, pageIndex) {
                              final startIndex = pageIndex * 2;
                              final endIndex = (startIndex + 2).clamp(0, _filteredCategories.length);
                              final pageCategories = _filteredCategories.sublist(startIndex, endIndex);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              if (pageCategories.isNotEmpty)
                                Expanded(
                                  child: SimpleCategoryCard(
                                    category: pageCategories[0],
                                  ),
                                ),
                              if (pageCategories.length > 1) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SimpleCategoryCard(
                                    category: pageCategories[1],
                                  ),
                                ),
                              ],
                              if (pageCategories.length == 1)
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Navigation arrows
                    if ((_filteredCategories.length / 2).ceil() > 1) ...[
                      // Left arrow
                      if (_currentIndex > 0)
                        Positioned(
                          left: 4,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Right arrow or More button
                      if (_currentIndex < (_filteredCategories.length / 2).ceil() - 1)
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        // More button when we're at the last page
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                // Show all features dialog
                                _showAllFeaturesDialog(context);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.more_horiz,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Upcoming Orders section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upcoming Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Order tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OrderTab(
                        title: 'Today',
                        isSelected: _selectedOrderTab == 0,
                        onTap: () => setState(() => _selectedOrderTab = 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OrderTab(
                        title: 'Upcoming',
                        isSelected: _selectedOrderTab == 1,
                        onTap: () => setState(() => _selectedOrderTab = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OrderTab(
                        title: 'Completed',
                        isSelected: _selectedOrderTab == 2,
                        onTap: () => setState(() => _selectedOrderTab = 2),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Orders list
              if (filteredOrders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        emptyStateMessage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrdersScreen()),
                        ),
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
                )
              else ...[
                ...filteredOrders.take(3).map((order) => OrderCard(order: order)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    ),
                    child: Text(
                      'View All Orders',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final String imageUrl;
  final Function(BuildContext) onTap;
  final bool isAsset; // New field to indicate if image is an asset
  
  CategoryItem({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.isAsset = false, // Default to network image
  });
}

class SimpleCategoryCard extends StatelessWidget {
  final CategoryItem category;
  
  const SimpleCategoryCard({
    super.key,
    required this.category,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => category.onTap(context),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image(
                image: category.isAsset 
                    ? AssetImage(category.imageUrl)
                    : NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  category.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final double height;
  
  const CategoryCard({
    super.key,
    required this.category,
    required this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => category.onTap(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                category.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  category.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  
  const OrderTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 24,
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  
  const OrderCard({super.key, required this.order});
  
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        break;
      case OrderStatus.completed:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.customerName.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (order.cakeDetails.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.cake, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.cakeDetails,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (order.deliveryDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (order.deliveryTime != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      order.deliveryTime!.format(context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
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
    );
  }
}

class BottomActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  
  const BottomActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}