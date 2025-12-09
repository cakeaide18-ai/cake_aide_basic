/// Firestore collection names and field constants
/// This file defines the schema structure for all Firestore collections
class FirestoreCollections {
  static const String userProfiles = 'user_profiles';
  static const String ingredients = 'ingredients';
  static const String supplies = 'supplies';
  static const String recipes = 'recipes';
  static const String shoppingLists = 'shopping_lists';
  static const String orders = 'orders';
  static const String quotes = 'quotes';
  static const String timerRecordings = 'timer_recordings';
  static const String supportIssues = 'support_issues';
  // Used by Firebase Trigger Email extension
  static const String mail = 'mail';
}

class FirestoreFields {
  // Common fields
  static const String id = 'id';
  static const String ownerId = 'owner_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String name = 'name';
  static const String description = 'description';
  
  // User Profile fields
  static const String email = 'email';
  static const String businessName = 'business_name';
  static const String phone = 'phone';
  static const String address = 'address';
  
  // Ingredient fields
  static const String category = 'category';
  static const String unit = 'unit';
  static const String costPerUnit = 'cost_per_unit';
  static const String currentStock = 'current_stock';
  static const String minimumStock = 'minimum_stock';
  
  // Supply fields
  static const String supplier = 'supplier';
  static const String lastPurchaseDate = 'last_purchase_date';
  static const String nextOrderDate = 'next_order_date';
  
  // Recipe fields
  static const String servingSize = 'serving_size';
  static const String prepTime = 'prep_time';
  static const String cookTime = 'cook_time';
  static const String totalTime = 'total_time';
  static const String difficulty = 'difficulty';
  static const String instructions = 'instructions';
  static const String ingredients = 'ingredients';
  static const String notes = 'notes';
  static const String tags = 'tags';
  static const String imageUrl = 'image_url';
  
  // Shopping List fields
  static const String items = 'items';
  static const String totalEstimatedCost = 'total_estimated_cost';
  static const String isCompleted = 'is_completed';
  static const String completedAt = 'completed_at';
  
  // Order fields
  static const String customerName = 'customerName';
  static const String customerPhone = 'customerPhone';
  static const String customerEmail = 'customerEmail';
  static const String deliveryDate = 'deliveryDate';
  static const String orderDate = 'orderDate';
  static const String deliveryTime = 'deliveryTime';
  static const String status = 'status';
  static const String cakeDetails = 'cakeDetails';
  static const String servings = 'servings';
  static const String price = 'price';
  static const String isCustomDesign = 'isCustomDesign';
  static const String customDesignNotes = 'customDesignNotes';
  
  // Legacy order fields (for backward compatibility)
  static const String totalAmount = 'totalAmount';
  static const String deposit = 'deposit';
  static const String balance = 'balance';
  static const String cakeType = 'cakeType';
  static const String cakeSize = 'cakeSize';
  static const String flavor = 'flavor';
  static const String specialInstructions = 'specialInstructions';
  
  // Quote fields
  static const String clientName = 'client_name';
  static const String clientPhone = 'client_phone';
  static const String clientEmail = 'client_email';
  static const String eventDate = 'event_date';
  static const String eventType = 'event_type';
  static const String guestCount = 'guest_count';
  static const String quotedAmount = 'quoted_amount';
  static const String validUntil = 'valid_until';
  static const String isAccepted = 'is_accepted';
  static const String acceptedAt = 'accepted_at';
  
  // Timer Recording fields
  static const String taskName = 'task_name';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String duration = 'duration';
  static const String date = 'date';

  // Support Issue fields (namespaced to avoid collisions with other collections)
  static const String issueCategory = 'issue_category';
  static const String issueMessage = 'issue_message';
  static const String issueUserEmail = 'issue_user_email';
  static const String issueAppVersion = 'issue_app_version';
  static const String issuePlatform = 'issue_platform';
  static const String issueStatus = 'issue_status';
}

class FirestoreQueries {
  /// Common query builders
  static String userOwnedQuery(String collection, String userId) {
    return '$collection where ${FirestoreFields.ownerId} == $userId';
  }
  
  static String orderByCreatedAt(String collection, {bool descending = true}) {
    return '$collection orderBy ${FirestoreFields.createdAt} ${descending ? 'desc' : 'asc'}';
  }
  
  static String orderByName(String collection, {bool descending = false}) {
    return '$collection orderBy ${FirestoreFields.name} ${descending ? 'desc' : 'asc'}';
  }
}