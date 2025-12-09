import 'package:cake_aide_basic/supabase/supabase_config.dart';
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/order.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';

/// CakeAide-specific Supabase service
/// Provides typed methods for CakeAide models
class CakeAideService {
  // User Profile methods
  static Future<UserProfile?> getUserProfile(String userId) async {
    final data = await SupabaseService.selectSingle(
      'user_profiles',
      filters: {'id': userId},
    );
    return data != null ? UserProfile.fromJson(data) : null;
  }

  static Future<UserProfile> createUserProfile(UserProfile profile) async {
    final data = await SupabaseService.insert('user_profiles', profile.toJson());
    return UserProfile.fromJson(data.first);
  }

  static Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final data = await SupabaseService.update(
      'user_profiles',
      profile.toJson(),
      filters: {'id': profile.id},
    );
    return UserProfile.fromJson(data.first);
  }

  // Ingredient methods
  static Future<List<Ingredient>> getUserIngredients(String userId) async {
    final data = await SupabaseService.select(
      'ingredients',
      filters: {'user_id': userId},
      orderBy: 'name',
    );
    return data.map((json) => Ingredient.fromJson(json)).toList();
  }

  static Future<Ingredient> createIngredient(Ingredient ingredient) async {
    final data = await SupabaseService.insert('ingredients', ingredient.toJson());
    return Ingredient.fromJson(data.first);
  }

  static Future<Ingredient> updateIngredient(Ingredient ingredient) async {
    final data = await SupabaseService.update(
      'ingredients',
      ingredient.toJson(),
      filters: {'id': ingredient.id},
    );
    return Ingredient.fromJson(data.first);
  }

  static Future<void> deleteIngredient(String ingredientId) async {
    await SupabaseService.delete('ingredients', filters: {'id': ingredientId});
  }

  // Recipe methods
  static Future<List<Recipe>> getUserRecipes(String userId) async {
    final data = await SupabaseService.select(
      'recipes',
      filters: {'user_id': userId},
      orderBy: 'name',
    );
    return data.map((json) => Recipe.fromJson(json)).toList();
  }

  static Future<Recipe> createRecipe(Recipe recipe) async {
    final data = await SupabaseService.insert('recipes', recipe.toJson());
    return Recipe.fromJson(data.first);
  }

  static Future<Recipe> updateRecipe(Recipe recipe) async {
    final data = await SupabaseService.update(
      'recipes',
      recipe.toJson(),
      filters: {'id': recipe.id},
    );
    return Recipe.fromJson(data.first);
  }

  static Future<void> deleteRecipe(String recipeId) async {
    await SupabaseService.delete('recipes', filters: {'id': recipeId});
  }

  // Order methods
  static Future<List<Order>> getUserOrders(String userId) async {
    final data = await SupabaseService.select(
      'orders',
      filters: {'user_id': userId},
      orderBy: 'delivery_date',
    );
    return data.map((json) => Order.fromJson(json)).toList();
  }

  static Future<List<Order>> getUpcomingOrders(String userId) async {
    final data = await SupabaseService.select(
      'orders',
      filters: {'user_id': userId},
      orderBy: 'delivery_date',
    );
    
    // Filter for upcoming orders (delivery date >= today)
    final today = DateTime.now();
    return data
        .map((json) => Order.fromJson(json))
        .where((order) => order.deliveryDate != null && 
                         (order.deliveryDate!.isAfter(today) || 
                          order.deliveryDate!.isAtSameMomentAs(DateTime(today.year, today.month, today.day))))
        .toList();
  }

  static Future<Order> createOrder(Order order) async {
    final data = await SupabaseService.insert('orders', order.toJson());
    return Order.fromJson(data.first);
  }

  static Future<Order> updateOrder(Order order) async {
    final data = await SupabaseService.update(
      'orders',
      order.toJson(),
      filters: {'id': order.id},
    );
    return Order.fromJson(data.first);
  }

  static Future<void> deleteOrder(String orderId) async {
    await SupabaseService.delete('orders', filters: {'id': orderId});
  }

  // Supply methods
  static Future<List<Supply>> getUserSupplies(String userId) async {
    final data = await SupabaseService.select(
      'supplies',
      filters: {'user_id': userId},
      orderBy: 'name',
    );
    return data.map((json) => Supply.fromJson(json)).toList();
  }

  static Future<Supply> createSupply(Supply supply) async {
    final data = await SupabaseService.insert('supplies', supply.toJson());
    return Supply.fromJson(data.first);
  }

  static Future<Supply> updateSupply(Supply supply) async {
    final data = await SupabaseService.update(
      'supplies',
      supply.toJson(),
      filters: {'id': supply.id},
    );
    return Supply.fromJson(data.first);
  }

  static Future<void> deleteSupply(String supplyId) async {
    await SupabaseService.delete('supplies', filters: {'id': supplyId});
  }

  // Quote methods
  static Future<List<Quote>> getUserQuotes(String userId) async {
    final data = await SupabaseService.select(
      'quotes',
      filters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((json) => Quote.fromJson(json)).toList();
  }

  static Future<Quote> createQuote(Quote quote) async {
    final data = await SupabaseService.insert('quotes', quote.toJson());
    return Quote.fromJson(data.first);
  }

  static Future<Quote> updateQuote(Quote quote) async {
    final data = await SupabaseService.update(
      'quotes',
      quote.toJson(),
      filters: {'id': quote.id},
    );
    return Quote.fromJson(data.first);
  }

  static Future<void> deleteQuote(String quoteId) async {
    await SupabaseService.delete('quotes', filters: {'id': quoteId});
  }

  // Shopping List methods
  static Future<List<ShoppingList>> getUserShoppingLists(String userId) async {
    final data = await SupabaseService.select(
      'shopping_lists',
      filters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((json) => ShoppingList.fromJson(json)).toList();
  }

  static Future<ShoppingList> createShoppingList(ShoppingList shoppingList) async {
    final data = await SupabaseService.insert('shopping_lists', shoppingList.toJson());
    return ShoppingList.fromJson(data.first);
  }

  static Future<ShoppingList> updateShoppingList(ShoppingList shoppingList) async {
    final data = await SupabaseService.update(
      'shopping_lists',
      shoppingList.toJson(),
      filters: {'id': shoppingList.id},
    );
    return ShoppingList.fromJson(data.first);
  }

  static Future<void> deleteShoppingList(String shoppingListId) async {
    await SupabaseService.delete('shopping_lists', filters: {'id': shoppingListId});
  }
}