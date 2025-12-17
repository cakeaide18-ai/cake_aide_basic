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
    // All data now comes from Firebase - no hardcoded sample data
    // Users start with empty lists and add their own data
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