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

  // Getters
  String get currency => _currency;
  double get pricePerHour => _pricePerHour;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get orderUpdates => _orderUpdates;
  bool get marketing => _marketing;

  // Setters
  void setCurrency(String currency) {
    _currency = currency;
  }

  void setPricePerHour(double price) {
    _pricePerHour = price;
  }

  void setPushNotifications(bool value) {
    _pushNotifications = value;
  }

  void setEmailNotifications(bool value) {
    _emailNotifications = value;
  }

  void setOrderUpdates(bool value) {
    _orderUpdates = value;
  }

  void setMarketing(bool value) {
    _marketing = value;
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