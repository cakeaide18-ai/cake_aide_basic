import 'package:cake_aide_basic/models/order.dart' as order_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class OrderRepository extends FirebaseRepository<order_model.Order> {
  OrderRepository() : super(
    collectionName: FirestoreCollections.orders,
    fromMap: (map) => order_model.Order.fromJson(map),
    toMap: (order) => order.toJson(),
  );

  // Get orders by status
  Future<List<order_model.Order>> getOrdersByStatus(String status) async {
    final queryRef = query().where(FirestoreFields.status, isEqualTo: status);
    return await getWithQuery(queryRef);
  }

  // Get orders due today
  Future<List<order_model.Order>> getOrdersDueToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    final queryRef = query()
        .where(FirestoreFields.deliveryDate, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where(FirestoreFields.deliveryDate, isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where(FirestoreFields.status, isNotEqualTo: 'completed');
    
    return await getWithQuery(queryRef);
  }

  // Get all orders
  Future<List<order_model.Order>> getAllOrders() async {
    return await getAll();
  }

  // Get upcoming orders (pending/in-progress, not due today)
  Future<List<order_model.Order>> getUpcomingOrders() async {
    final today = DateTime.now();
    final startOfTomorrow = DateTime(today.year, today.month, today.day + 1);
    
    final queryRef = query()
        .where(FirestoreFields.status, whereIn: ['pending', 'in_progress'])
        .where(FirestoreFields.deliveryDate, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfTomorrow));
    
    return await getWithQuery(queryRef);
  }
  
  // Get completed orders
  Future<List<order_model.Order>> getCompletedOrders() async {
    final queryRef = query().where(FirestoreFields.status, isEqualTo: 'completed');
    return await getWithQuery(queryRef);
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    final order = await getById(orderId);
    if (order != null) {
      // Convert string status to OrderStatus enum
  order_model.OrderStatus orderStatus;
      switch (status.toLowerCase()) {
        case 'pending':
          orderStatus = order_model.OrderStatus.pending;
          break;
        case 'in_progress':
        case 'inprogress':
          orderStatus = order_model.OrderStatus.inProgress;
          break;
        case 'completed':
          orderStatus = order_model.OrderStatus.completed;
          break;
        case 'cancelled':
          orderStatus = order_model.OrderStatus.cancelled;
          break;
        default:
          orderStatus = order_model.OrderStatus.pending;
      }
      
      final updatedOrder = order.copyWith(
        status: orderStatus,
        updatedAt: DateTime.now(),
      );
      await update(orderId, updatedOrder);
    }
  }
  
  // Get orders stream
  Stream<List<order_model.Order>> getOrdersStream() {
    return getStream();
  }
}