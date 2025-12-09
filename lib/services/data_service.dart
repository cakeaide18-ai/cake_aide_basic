import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/timer_recording.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    _initializeData();
  }

  final List<Ingredient> _ingredients = [];
  final List<Supply> _supplies = [];
  final List<Recipe> _recipes = [];
  final List<Quote> _quotes = [];
  final List<Order> _orders = [];
  final List<ShoppingList> _shoppingLists = [];
  final List<TimerRecording> _timerRecordings = [];

  // Getters
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  List<Supply> get supplies => List.unmodifiable(_supplies);
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<Quote> get quotes => List.unmodifiable(_quotes);
  List<Order> get orders => List.unmodifiable(_orders);
  List<ShoppingList> get shoppingLists => List.unmodifiable(_shoppingLists);
  List<TimerRecording> get timerRecordings => List.unmodifiable(_timerRecordings);

  void _initializeData() {
    // Sample ingredients
    _ingredients.addAll([
      Ingredient(
        id: '1',
        name: 'Plain Flour',
        brand: 'McDougalls',
        price: 1.20,
        quantity: 1.0,
        unit: 'kilograms',
      ),
      Ingredient(
        id: '2',
        name: 'Caster Sugar',
        brand: 'Tate & Lyle',
        price: 2.50,
        quantity: 1.0,
        unit: 'kilograms',
      ),
      Ingredient(
        id: '3',
        name: 'Free Range Eggs',
        brand: 'Happy Egg Co',
        price: 3.00,
        quantity: 12.0,
        unit: 'dozen',
      ),
      Ingredient(
        id: '4',
        name: 'Unsalted Butter',
        brand: 'Lurpak',
        price: 4.50,
        quantity: 1.0,
        unit: 'kilograms',
      ),
      Ingredient(
        id: '5',
        name: 'Vanilla Extract',
        brand: 'Nielsen-Massey',
        price: 12.99,
        quantity: 1.0,
        unit: 'bottles',
      ),
    ]);

    // Sample supplies
    _supplies.addAll([
      Supply(
        id: '1',
        name: 'Cake Boxes',
        brand: 'PackagingPro',
        price: 0.75,
        quantity: 10.0,
        unit: 'pieces',
      ),
      Supply(
        id: '2',
        name: 'Piping Bags',
        brand: 'Wilton',
        price: 8.99,
        quantity: 12.0,
        unit: 'packs',
      ),
      Supply(
        id: '3',
        name: 'Cake Boards',
        brand: 'CakeCraft',
        price: 1.25,
        quantity: 8.0,
        unit: 'pieces',
      ),
    ]);

    // Sample recipes
    final vanillaSponge = Recipe(
      id: '1',
      name: 'Classic Vanilla Cake',
      cakeSizePortions: '8 servings',
      ingredients: [
        RecipeIngredient(ingredient: _ingredients[0], quantity: 0.2, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[1], quantity: 0.2, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[2], quantity: 4.0, unit: 'pieces'),
        RecipeIngredient(ingredient: _ingredients[3], quantity: 0.2, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[4], quantity: 0.01, unit: 'bottles'),
      ],
      imagePath: 'https://pixabay.com/get/g651e0333286568b9c8dbec19fa66ee42660a68085db0c37fafde7ad66548580eda9323d3c1b35e9b02bf3e65267b786653a262da9dca515cfda0028a3dbf55a4_1280.jpg',
    );

    final chocolateFudge = Recipe(
      id: '2',
      name: 'Chocolate Fudge Cake',
      cakeSizePortions: '10 servings',
      ingredients: [
        RecipeIngredient(ingredient: _ingredients[0], quantity: 0.25, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[1], quantity: 0.3, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[2], quantity: 6.0, unit: 'pieces'),
        RecipeIngredient(ingredient: _ingredients[3], quantity: 0.25, unit: 'kilograms'),
        RecipeIngredient(ingredient: _ingredients[4], quantity: 0.015, unit: 'bottles'),
      ],
      imagePath: 'https://pixabay.com/get/g69d796cd816595a898bc7bd1393c15ed26e5d62a2e5ee73d9227118dd3c33806a16bfb8bcceafbd76bb1f63706bab4fb58c7e330d0e2c2e9d1b55da4f1204cf1_1280.jpg',
    );

    _recipes.addAll([vanillaSponge, chocolateFudge]);

    // Sample orders
    _orders.addAll([
      Order(
        id: '1',
        name: 'Birthday Cake - Sarah Johnson',
        customerName: 'Sarah Johnson',
        customerPhone: '+44 7123 456789',
        customerEmail: 'sarah.johnson@email.com',
        status: OrderStatus.inProgress,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        deliveryDate: DateTime.now().add(const Duration(days: 2)),
        deliveryTime: const TimeOfDay(hour: 15, minute: 0),
        notes: 'Chocolate cake with strawberry filling. Deliver by 3 PM.',
        cakeDetails: 'Chocolate Fudge Cake\n8 inch round (Serves 10-12)\nWith strawberry filling and buttercream frosting',
        servings: 12,
        price: 45.00,
        isCustomDesign: true,
        customDesignNotes: 'Pink and purple theme with unicorn decorations',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Order(
        id: '2',
        name: 'Wedding Cake - Smith Family',
        customerName: 'Emma Smith',
        customerPhone: '+44 7987 654321',
        customerEmail: 'emma.smith@email.com',
        status: OrderStatus.pending,
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
        deliveryDate: DateTime.now().add(const Duration(days: 7)),
        deliveryTime: const TimeOfDay(hour: 14, minute: 30),
        notes: '3-tier vanilla cake with cream cheese frosting.',
        cakeDetails: 'Vanilla Sponge Wedding Cake\n3-tier (6", 8", 10") serves 50\nWith cream cheese frosting and elegant decorations',
        servings: 50,
        price: 150.00,
        isCustomDesign: true,
        customDesignNotes: 'Elegant white and gold design with fresh flowers',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  // Ingredient methods
  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
  }

  void updateIngredient(String id, Ingredient updatedIngredient) {
    final index = _ingredients.indexWhere((i) => i.id == id);
    if (index != -1) {
      _ingredients[index] = updatedIngredient;
    }
  }

  void deleteIngredient(String id) {
    _ingredients.removeWhere((i) => i.id == id);
  }

  // Supply methods
  void addSupply(Supply supply) {
    _supplies.add(supply);
  }

  void updateSupply(String id, Supply updatedSupply) {
    final index = _supplies.indexWhere((s) => s.id == id);
    if (index != -1) {
      _supplies[index] = updatedSupply;
    }
  }

  void deleteSupply(String id) {
    _supplies.removeWhere((s) => s.id == id);
  }

  // Recipe methods
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
  }

  void updateRecipe(String id, Recipe updatedRecipe) {
    final index = _recipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
    }
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
  }

  // Quote methods
  void addQuote(Quote quote) {
    _quotes.add(quote);
  }

  void updateQuote(String id, Quote updatedQuote) {
    final index = _quotes.indexWhere((q) => q.id == id);
    if (index != -1) {
      _quotes[index] = updatedQuote;
    }
  }

  void deleteQuote(String id) {
    _quotes.removeWhere((q) => q.id == id);
  }

  // Order methods
  void addOrder(Order order) {
    _orders.add(order);
  }

  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }
  
  void updateOrderById(String id, Order updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }

  void deleteOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
  }

  // Shopping List methods
  void addShoppingList(ShoppingList shoppingList) {
    _shoppingLists.add(shoppingList);
  }

  void updateShoppingList(String id, ShoppingList updatedShoppingList) {
    final index = _shoppingLists.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shoppingLists[index] = updatedShoppingList;
    }
  }

  void deleteShoppingList(String id) {
    _shoppingLists.removeWhere((s) => s.id == id);
  }

  // Timer Recording methods
  void addTimerRecording(TimerRecording recording) {
    _timerRecordings.insert(0, recording); // Insert at beginning for most recent first
  }

  void updateTimerRecording(String id, TimerRecording updatedRecording) {
    final index = _timerRecordings.indexWhere((r) => r.id == id);
    if (index != -1) {
      _timerRecordings[index] = updatedRecording;
    }
  }

  void deleteTimerRecording(String id) {
    _timerRecordings.removeWhere((r) => r.id == id);
  }

  // Utility methods
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}