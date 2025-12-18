import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Business settings
  String _currency = 'USD';
  double _pricePerHour = 25.0;

  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _orderUpdates = true;
  bool _marketing = false;

  // Track if settings have been loaded
  bool _initialized = false;

  // Getters
  String get currency => _currency;
  double get pricePerHour => _pricePerHour;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get orderUpdates => _orderUpdates;
  bool get marketing => _marketing;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    if (_initialized) return; // Only load once
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _currency = prefs.getString('settings_currency') ?? 'USD';
      _pricePerHour = prefs.getDouble('settings_price_per_hour') ?? 25.0;
      _pushNotifications = prefs.getBool('settings_push_notifications') ?? true;
      _emailNotifications = prefs.getBool('settings_email_notifications') ?? false;
      _orderUpdates = prefs.getBool('settings_order_updates') ?? true;
      _marketing = prefs.getBool('settings_marketing') ?? false;
      
      _initialized = true;
      debugPrint('SettingsService: Loaded settings - Currency: $_currency, Price/hr: $_pricePerHour');
    } catch (e) {
      debugPrint('SettingsService: Error loading settings: $e');
    }
  }

  // Setters with persistence
  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_currency', currency);
    debugPrint('SettingsService: Saved currency: $currency');
  }

  Future<void> setPricePerHour(double price) async {
    _pricePerHour = price;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('settings_price_per_hour', price);
    debugPrint('SettingsService: Saved price per hour: $price');
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_push_notifications', value);
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_email_notifications', value);
  }

  Future<void> setOrderUpdates(bool value) async {
    _orderUpdates = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_order_updates', value);
  }

  Future<void> setMarketing(bool value) async {
    _marketing = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_marketing', value);
  }

  // Currency symbol helper
  String getCurrencySymbol() {
    switch (_currency) {
      case 'USD':
      case 'CAD':
      case 'AUD':
      case 'NZD':
      case 'SGD':
      case 'HKD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'CHF':
        return 'CHF';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      default:
        return '\$';
    }
  }
}