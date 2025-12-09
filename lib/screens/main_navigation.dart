import 'package:flutter/material.dart';
import 'package:cake_aide_basic/screens/home/home_screen.dart';
import 'package:cake_aide_basic/screens/ingredients/ingredients_screen.dart';
import 'package:cake_aide_basic/screens/supplies/supplies_screen.dart';
import 'package:cake_aide_basic/screens/recipes/recipes_screen.dart';
import 'package:cake_aide_basic/screens/quotes/quotes_screen.dart';
import 'package:cake_aide_basic/screens/orders/orders_screen.dart';
import 'package:cake_aide_basic/screens/timer/timer_screen.dart';
import 'package:cake_aide_basic/screens/unit_converter/unit_converter_screen.dart';
import 'package:cake_aide_basic/screens/reminders/reminders_screen.dart';
import 'package:cake_aide_basic/screens/shopping_list/shopping_list_screen.dart';
import 'package:cake_aide_basic/screens/settings/settings_screen.dart';
import 'package:cake_aide_basic/widgets/ingredient_icon.dart';
import 'package:cake_aide_basic/widgets/supply_icon.dart';
import 'package:cake_aide_basic/widgets/recipe_icon.dart';
import 'package:cake_aide_basic/widgets/quote_icon.dart';
import 'package:cake_aide_basic/widgets/order_icon.dart';
import 'package:cake_aide_basic/widgets/timer_icon.dart';
import 'package:cake_aide_basic/widgets/unit_converter_icon.dart';
import 'package:cake_aide_basic/widgets/reminder_icon.dart';
import 'package:cake_aide_basic/widgets/settings_icon.dart';
import 'package:cake_aide_basic/widgets/shopping_list_icon.dart';
import 'package:cake_aide_basic/widgets/home_icon.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const IngredientsScreen(),
    const SuppliesScreen(),
    const RecipesScreen(),
    const QuotesScreen(),
  ];

  void _showMoreFeaturesDialog() {
    final moreFeatures = [
      {
        'title': 'Order Management',
        'iconWidget': const OrderIcon(size: 24, fallbackColor: Colors.red),
        'description': 'Track and manage your cake orders',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OrdersScreen()),
        ),
      },
      {
        'title': 'Timer & Tracking',
        'iconWidget': const TimerIcon(size: 24),
        'description': 'Track baking times and set reminders',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TimerScreen()),
        ),
      },
      {
        'title': 'Unit Converter',
        'iconWidget': const UnitConverterIcon(size: 24),
        'description': 'Convert measurements and units',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
        ),
      },
      {
        'title': 'Reminders',
        'iconWidget': const ReminderIcon(size: 24),
        'description': 'Set reminders for important tasks',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        ),
      },
      {
        'title': 'Shopping Lists',
        'iconWidget': const ShoppingListIcon(size: 24),
        'description': 'Manage your shopping lists',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
        ),
      },
      {
        'title': 'Settings',
        'iconWidget': const SettingsIcon(size: 24),
        'description': 'App preferences and configuration',
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ),
      },
    ];

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
                    Icons.more_horiz,
                    color: Colors.pink,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'More Features',
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
                  itemCount: moreFeatures.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final feature = moreFeatures[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: feature['iconWidget'] != null
                                ? feature['iconWidget'] as Widget
                                : Icon(
                                    feature['icon'] as IconData,
                                    color: Colors.pink,
                                    size: 24,
                                  ),
                          ),
                        ),
                        title: Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          feature['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.pink,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          (feature['onTap'] as VoidCallback)();
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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  iconWidget: const HomeIcon(size: 24),
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.kitchen,
                  iconWidget: const IngredientIcon(size: 24),
                  label: 'Ingredients',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.inventory_2,
                  iconWidget: const SupplyIcon(size: 24),
                  label: 'Supplies',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.menu_book,
                  iconWidget: const RecipeIcon(size: 24),
                  label: 'Recipes',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.calculate,
                  iconWidget: const QuoteIcon(size: 24),
                  label: 'Quotes',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.more_horiz,
                  label: 'More',
                  index: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    Widget? iconWidget,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (index < _screens.length) {
          setState(() {
            _currentIndex = index;
          });
        } else if (index == 5) {
          // Handle "More" button
          _showMoreFeaturesDialog();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget == null
              ? Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                )
              : Opacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  child: iconWidget,
                ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}