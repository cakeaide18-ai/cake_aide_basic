import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/widgets/settings_icon.dart';
import 'package:cake_aide_basic/widgets/business_settings_icon.dart';
import 'package:cake_aide_basic/widgets/account_security_icon.dart';
import 'package:cake_aide_basic/widgets/help_support_icon.dart';
import 'package:cake_aide_basic/widgets/notifications_icon.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:cake_aide_basic/screens/profile/profile_creation_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cake_aide_basic/services/review_service.dart';
import 'package:cake_aide_basic/services/firebase_service.dart';
import 'package:cake_aide_basic/services/theme_controller.dart';
import 'package:cake_aide_basic/services/auth_service.dart';
import 'package:cake_aide_basic/supabase/supabase_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  late final TextEditingController _pricePerHourController;
  final TextEditingController _currencySearchController = TextEditingController();
  List<Map<String, String>> _filteredCurrencies = [];
  String _userName = 'User';
  String _userEmail = 'user@email.com';
  String _businessName = 'My Business';
  File? _profileImage;
  Uint8List? _webImageBytes;
  
  @override
  void initState() {
    super.initState();
    _pricePerHourController = TextEditingController(
      text: _settingsService.pricePerHour.toStringAsFixed(2)
    );
    _filteredCurrencies = List.from(_currencies);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('profile_name') ?? prefs.getString('owner_name') ?? 'User';
      _userEmail = prefs.getString('profile_email') ?? prefs.getString('email') ?? 'user@email.com';
      _businessName = prefs.getString('profile_business_name') ?? prefs.getString('business_name') ?? 'My Business';
      
      if (kIsWeb) {
        // For web, check for base64 image data
        final webImageData = prefs.getString('profile_image_web');
        if (webImageData != null && webImageData.isNotEmpty) {
          try {
            final bytes = base64Decode(webImageData);
            _webImageBytes = bytes;
          } catch (e) {
            debugPrint('Error loading web profile image in settings: $e');
          }
        }
      } else {
        // For mobile, load from file path
        final imagePath = prefs.getString('profile_image');
        if (imagePath != null && imagePath.isNotEmpty) {
          final imageFile = File(imagePath);
          if (imageFile.existsSync()) {
            _profileImage = imageFile;
          }
        }
      }
    });
  }

  Widget _getProfileImageWidget() {
    if (kIsWeb && _webImageBytes != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: MemoryImage(_webImageBytes!),
      );
    } else if (!kIsWeb && _profileImage != null && _profileImage!.existsSync()) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: FileImage(_profileImage!),
      );
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar (\$)'},
    {'code': 'EUR', 'name': 'Euro (€)'},
    {'code': 'GBP', 'name': 'British Pound (£)'},
    {'code': 'JPY', 'name': 'Japanese Yen (¥)'},
    {'code': 'CAD', 'name': 'Canadian Dollar (CA\$)'},
    {'code': 'AUD', 'name': 'Australian Dollar (AU\$)'},
    {'code': 'CHF', 'name': 'Swiss Franc (CHF)'},
    {'code': 'CNY', 'name': 'Chinese Yuan (¥)'},
    {'code': 'SEK', 'name': 'Swedish Krona (kr)'},
    {'code': 'NOK', 'name': 'Norwegian Krone (kr)'},
    {'code': 'MXN', 'name': 'Mexican Peso (\$)'},
    {'code': 'SGD', 'name': 'Singapore Dollar (S\$)'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar (HK\$)'},
    {'code': 'NZD', 'name': 'New Zealand Dollar (NZ\$)'},
    {'code': 'KRW', 'name': 'South Korean Won (₩)'},
    {'code': 'TRY', 'name': 'Turkish Lira (₺)'},
    {'code': 'RUB', 'name': 'Russian Ruble (₽)'},
    {'code': 'INR', 'name': 'Indian Rupee (₹)'},
    {'code': 'BRL', 'name': 'Brazilian Real (R\$)'},
    {'code': 'ZAR', 'name': 'South African Rand (R)'},
    {'code': 'AED', 'name': 'UAE Dirham (د.إ)'},
    {'code': 'SAR', 'name': 'Saudi Riyal (﷼)'},
    {'code': 'PLN', 'name': 'Polish Zloty (zł)'},
    {'code': 'DKK', 'name': 'Danish Krone (kr)'},
    {'code': 'CZK', 'name': 'Czech Koruna (Kč)'},
    {'code': 'HUF', 'name': 'Hungarian Forint (Ft)'},
    {'code': 'ILS', 'name': 'Israeli Shekel (₪)'},
    {'code': 'CLP', 'name': 'Chilean Peso (\$)'},
    {'code': 'PHP', 'name': 'Philippine Peso (₱)'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit (RM)'},
    {'code': 'THB', 'name': 'Thai Baht (฿)'},
    {'code': 'IDR', 'name': 'Indonesian Rupiah (Rp)'},
    {'code': 'VND', 'name': 'Vietnamese Dong (₫)'},
    {'code': 'EGP', 'name': 'Egyptian Pound (£)'},
    {'code': 'NGN', 'name': 'Nigerian Naira (₦)'},
    {'code': 'KES', 'name': 'Kenyan Shilling (KSh)'},
    {'code': 'GHS', 'name': 'Ghanaian Cedi (₵)'},
    {'code': 'MAD', 'name': 'Moroccan Dirham (د.م.)'},
    {'code': 'LKR', 'name': 'Sri Lankan Rupee (Rs)'},
    {'code': 'PKR', 'name': 'Pakistani Rupee (Rs)'},
    {'code': 'BDT', 'name': 'Bangladeshi Taka (৳)'},
    {'code': 'AFN', 'name': 'Afghan Afghani (؋)'},
    {'code': 'ALL', 'name': 'Albanian Lek (L)'},
    {'code': 'DZD', 'name': 'Algerian Dinar (د.ج)'},
    {'code': 'AOA', 'name': 'Angolan Kwanza (Kz)'},
    {'code': 'ARS', 'name': 'Argentine Peso (\$)'},
    {'code': 'AMD', 'name': 'Armenian Dram (֏)'},
    {'code': 'AWG', 'name': 'Aruban Florin (ƒ)'},
    {'code': 'AZN', 'name': 'Azerbaijani Manat (₼)'},
    {'code': 'BHD', 'name': 'Bahraini Dinar (.د.ب)'},
    {'code': 'BBD', 'name': 'Barbadian Dollar (\$)'},
    {'code': 'BYN', 'name': 'Belarusian Ruble (Br)'},
    {'code': 'BZD', 'name': 'Belize Dollar (BZ\$)'},
    {'code': 'BMD', 'name': 'Bermudan Dollar (\$)'},
    {'code': 'BTN', 'name': 'Bhutanese Ngultrum (Nu.)'},
    {'code': 'BOB', 'name': 'Bolivian Boliviano (\$b)'},
    {'code': 'BAM', 'name': 'Bosnia-Herzegovina Convertible Mark (KM)'},
    {'code': 'BWP', 'name': 'Botswanan Pula (P)'},
    {'code': 'BND', 'name': 'Brunei Dollar (\$)'},
    {'code': 'BGN', 'name': 'Bulgarian Lev (лв)'},
    {'code': 'BIF', 'name': 'Burundian Franc (Fr)'},
    {'code': 'KHR', 'name': 'Cambodian Riel (៛)'},
    {'code': 'CVE', 'name': 'Cape Verdean Escudo (\$)'},
    {'code': 'KYD', 'name': 'Cayman Islands Dollar (\$)'},
    {'code': 'XAF', 'name': 'CFA Franc BEAC (Fr)'},
    {'code': 'XOF', 'name': 'CFA Franc BCEAO (Fr)'},
    {'code': 'XPF', 'name': 'CFP Franc (Fr)'},
    {'code': 'COP', 'name': 'Colombian Peso (\$)'},
    {'code': 'KMF', 'name': 'Comorian Franc (Fr)'},
    {'code': 'CDF', 'name': 'Congolese Franc (Fr)'},
    {'code': 'CRC', 'name': 'Costa Rican Colón (₡)'},
    {'code': 'HRK', 'name': 'Croatian Kuna (kn)'},
    {'code': 'CUP', 'name': 'Cuban Peso (\$)'},
    {'code': 'CYP', 'name': 'Cypriot Pound (£)'},
    {'code': 'DJF', 'name': 'Djiboutian Franc (Fr)'},
    {'code': 'DOP', 'name': 'Dominican Peso (RD\$)'},
    {'code': 'XCD', 'name': 'East Caribbean Dollar (\$)'},
    {'code': 'ECS', 'name': 'Ecuadorian Sucre (S/.)'},
    {'code': 'ERN', 'name': 'Eritrean Nakfa (Nfk)'},
    {'code': 'EEK', 'name': 'Estonian Kroon (kr)'},
    {'code': 'ETB', 'name': 'Ethiopian Birr (Br)'},
    {'code': 'FKP', 'name': 'Falkland Islands Pound (£)'},
    {'code': 'FJD', 'name': 'Fijian Dollar (\$)'},
    {'code': 'GMD', 'name': 'Gambian Dalasi (D)'},
    {'code': 'GEL', 'name': 'Georgian Lari (₾)'},
    {'code': 'GIP', 'name': 'Gibraltar Pound (£)'},
    {'code': 'GTQ', 'name': 'Guatemalan Quetzal (Q)'},
    {'code': 'GNF', 'name': 'Guinean Franc (Fr)'},
    {'code': 'GYD', 'name': 'Guyanaese Dollar (\$)'},
    {'code': 'HTG', 'name': 'Haitian Gourde (G)'},
    {'code': 'HNL', 'name': 'Honduran Lempira (L)'},
    {'code': 'ISK', 'name': 'Icelandic Króna (kr)'},
    {'code': 'IRR', 'name': 'Iranian Rial (﷼)'},
    {'code': 'IQD', 'name': 'Iraqi Dinar (ع.د)'},
    {'code': 'JMD', 'name': 'Jamaican Dollar (\$)'},
    {'code': 'JOD', 'name': 'Jordanian Dinar (د.ا)'},
    {'code': 'KZT', 'name': 'Kazakhstani Tenge (₸)'},
    {'code': 'KWD', 'name': 'Kuwaiti Dinar (د.ك)'},
    {'code': 'KGS', 'name': 'Kyrgystani Som (с)'},
    {'code': 'LAK', 'name': 'Laotian Kip (₭)'},
    {'code': 'LVL', 'name': 'Latvian Lats (Ls)'},
    {'code': 'LBP', 'name': 'Lebanese Pound (ل.ل)'},
    {'code': 'LSL', 'name': 'Lesotho Loti (L)'},
    {'code': 'LRD', 'name': 'Liberian Dollar (\$)'},
    {'code': 'LYD', 'name': 'Libyan Dinar (ل.د)'},
    {'code': 'LTL', 'name': 'Lithuanian Litas (Lt)'},
    {'code': 'MOP', 'name': 'Macanese Pataca (P)'},
    {'code': 'MKD', 'name': 'Macedonian Denar (ден)'},
    {'code': 'MGA', 'name': 'Malagasy Ariary (Ar)'},
    {'code': 'MWK', 'name': 'Malawian Kwacha (MK)'},
    {'code': 'MVR', 'name': 'Maldivian Rufiyaa (.ރ)'},
    {'code': 'MTL', 'name': 'Maltese Lira (₤)'},
    {'code': 'MRO', 'name': 'Mauritanian Ouguiya (UM)'},
    {'code': 'MUR', 'name': 'Mauritian Rupee (₨)'},
    {'code': 'MDL', 'name': 'Moldovan Leu (L)'},
    {'code': 'MNT', 'name': 'Mongolian Tugrik (₮)'},
    {'code': 'MZN', 'name': 'Mozambican Metical (MT)'},
    {'code': 'MMK', 'name': 'Myanmar Kyat (Ks)'},
    {'code': 'NAD', 'name': 'Namibian Dollar (\$)'},
    {'code': 'NPR', 'name': 'Nepalese Rupee (₨)'},
    {'code': 'ANG', 'name': 'Netherlands Antillean Guilder (ƒ)'},
    {'code': 'NIO', 'name': 'Nicaraguan Córdoba (C\$)'},
    {'code': 'XOF', 'name': 'West African CFA Franc (Fr)'},
    {'code': 'KPW', 'name': 'North Korean Won (₩)'},
    {'code': 'OMR', 'name': 'Omani Rial (ر.ع.)'},
    {'code': 'PGK', 'name': 'Papua New Guinean Kina (K)'},
    {'code': 'PYG', 'name': 'Paraguayan Guarani (₲)'},
    {'code': 'PEN', 'name': 'Peruvian Sol (S/.)'},
    {'code': 'QAR', 'name': 'Qatari Rial (ر.ق)'},
    {'code': 'RON', 'name': 'Romanian Leu (lei)'},
    {'code': 'RWF', 'name': 'Rwandan Franc (Fr)'},
    {'code': 'SHP', 'name': 'Saint Helena Pound (£)'},
    {'code': 'WST', 'name': 'Samoan Tala (T)'},
    {'code': 'STD', 'name': 'São Tomé and Príncipe Dobra (Db)'},
    {'code': 'RSD', 'name': 'Serbian Dinar (дин.)'},
    {'code': 'SCR', 'name': 'Seychellois Rupee (₨)'},
    {'code': 'SLL', 'name': 'Sierra Leonean Leone (Le)'},
    {'code': 'SBD', 'name': 'Solomon Islands Dollar (\$)'},
    {'code': 'SOS', 'name': 'Somali Shilling (S)'},
    {'code': 'SSP', 'name': 'South Sudanese Pound (£)'},
    {'code': 'SRD', 'name': 'Surinamese Dollar (\$)'},
    {'code': 'SZL', 'name': 'Swazi Lilangeni (L)'},
    {'code': 'SYP', 'name': 'Syrian Pound (£)'},
    {'code': 'TWD', 'name': 'Taiwan New Dollar (NT\$)'},
    {'code': 'TJS', 'name': 'Tajikistani Somoni (ЅМ)'},
    {'code': 'TZS', 'name': 'Tanzanian Shilling (TSh)'},
    {'code': 'TOP', 'name': 'Tongan Pa\'anga (T\$)'},
    {'code': 'TTD', 'name': 'Trinidad and Tobago Dollar (TT\$)'},
    {'code': 'TND', 'name': 'Tunisian Dinar (د.ت)'},
    {'code': 'TMT', 'name': 'Turkmenistani Manat (T)'},
    {'code': 'UGX', 'name': 'Ugandan Shilling (USh)'},
    {'code': 'UAH', 'name': 'Ukrainian Hryvnia (₴)'},
    {'code': 'UYU', 'name': 'Uruguayan Peso (\$U)'},
    {'code': 'UZS', 'name': 'Uzbekistan Som (лв)'},
    {'code': 'VUV', 'name': 'Vanuatu Vatu (Vt)'},
    {'code': 'VEF', 'name': 'Venezuelan Bolívar (Bs)'},
    {'code': 'YER', 'name': 'Yemeni Rial (﷼)'},
    {'code': 'ZMW', 'name': 'Zambian Kwacha (ZK)'},
    {'code': 'ZWL', 'name': 'Zimbabwean Dollar (Z\$)'},
  ];
  
  @override
  void dispose() {
    _pricePerHourController.dispose();
    _currencySearchController.dispose();
    super.dispose();
  }
  

  void _submitIssue() {
    showDialog(
      context: context,
      builder: (context) => const IssueDialog(),
    );
  }



  void _showAboutUs() {
    showDialog(
      context: context,
      builder: (context) => const AboutUsDialog(),
    );
  }
  
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => const TutorialDialog(),
    );
  }
  
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              // Close dialog first
              nav.pop();
              // Sign out from Firebase (social sign-ins) and Supabase (email/password flows)
              try {
                await AuthService.signOut();
              } catch (e) {
                debugPrint('Error signing out from Firebase: $e');
              }
              try {
                await SupabaseConfig.auth.signOut();
              } catch (e) {
                debugPrint('Error signing out from Supabase: $e');
              }
              // Navigate using captured Navigator to avoid context across async gaps
              nav.pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested. Please contact support.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
  

  

  
  void _showCurrencySelector() {
    _currencySearchController.clear();
    _filteredCurrencies = List.from(_currencies);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Select Currency',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _currencySearchController,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value.isEmpty) {
                        _filteredCurrencies = List.from(_currencies);
                      } else {
                        _filteredCurrencies = _currencies.where((currency) {
                          final code = currency['code']!.toLowerCase();
                          final name = currency['name']!.toLowerCase();
                          final searchLower = value.toLowerCase();
                          return code.contains(searchLower) || name.contains(searchLower);
                        }).toList();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search currencies...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _currencySearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _currencySearchController.clear();
                              setDialogState(() {
                                _filteredCurrencies = List.from(_currencies);
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Currency List with scroll
                Expanded(
                  child: _filteredCurrencies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No currencies found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with a different term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredCurrencies.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final currency = _filteredCurrencies[index];
                            final isSelected = currency['code'] == _settingsService.currency;
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[200]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    currency['code']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                currency['name']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () {
                                _settingsService.setCurrency(currency['code']!);
                                setState(() {});
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPricePerHourDialog() {
    final tempController = TextEditingController(text: _pricePerHourController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Price per Hour'),
        content: TextField(
          controller: tempController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Price per Hour',
            prefixText: '${_settingsService.getCurrencySymbol()} ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tempController.text.isNotEmpty) {
                final price = double.tryParse(tempController.text) ?? 25.0;
                _settingsService.setPricePerHour(price);
                _pricePerHourController.text = tempController.text;
                setState(() {});
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => tempController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SettingsIcon(size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileCreationScreen(isEditing: true),
                  ),
                );
                if (result == true) {
                  _loadProfileData(); // Reload data after editing
                }
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _getProfileImageWidget(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _businessName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Member since Aug 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const SizedBox(height: 8),
            
            // Business Settings Section
            _buildModernSectionHeaderWithIcon(
              const BusinessSettingsIcon(size: 20),
              'Business Settings',
            ),
            _buildModernSettingsCard([
              _buildCurrencySettingsTile(),
              _buildPricePerHourSettingsTile(),
            ]),
            
            const SizedBox(height: 24),

            // Appearance Section
            _buildModernSectionHeaderWithIcon(
              Image.asset('assets/images/appearance_icon.png', width: 20, height: 20),
              'Appearance',
            ),
            _buildModernSettingsCard([
              _buildThemeQuickToggleTile(),
            ]),
            
            const SizedBox(height: 0),
            
            // Account Security Section
            _buildModernSectionHeaderWithIcon(
              const AccountSecurityIcon(size: 20),
              'Account Security',
            ),
            _buildModernSettingsCard([
              _buildModernSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(),
              ),
              _buildModernSettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: () => _showSignOutDialog(),
              ),
              _buildModernSettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Help & Support Section
            _buildModernSectionHeaderWithIcon(
              const HelpSupportIcon(size: 20),
              'Help & Support',
            ),
            _buildModernSettingsCard([
              _buildModernSettingsTile(
                icon: Icons.school_outlined,
                title: 'Tutorial',
                subtitle: 'Learn how to use the app',
                onTap: () => _showTutorialDialog(),
              ),
              _buildModernSettingsTile(
                icon: Icons.star_outline,
                title: 'Review App',
                subtitle: 'Rate and review CakeAide Pro',
                onTap: () => ReviewService.openStoreReviewPage(context),
              ),

              _buildModernSettingsTile(
                icon: Icons.info_outline,
                title: 'About Us',
                subtitle: 'Learn more about CakeAide Pro',
                onTap: () => _showAboutUs(),
              ),
              _buildModernSettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report Issue',
                subtitle: 'Let us know about problems',
                onTap: () => _submitIssue(),
              ),
              _buildModernSettingsTile(
                icon: Icons.error_outline,
                title: 'Send Test Sentry Event',
                subtitle: 'Verify Sentry integration',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await Sentry.captureMessage('This is a test event from the settings screen.');
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Sentry event sent!')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Failed to send Sentry event: $e')),
                    );
                  }
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Notifications Section
            _buildModernSectionHeaderWithIcon(
              const NotificationsIcon(size: 20),
              'Notifications',
            ),
            _buildModernSettingsCard([
              _buildNotificationTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                value: _settingsService.pushNotifications,
                onChanged: (value) => setState(() => _settingsService.setPushNotifications(value)),
              ),
              _buildNotificationTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _settingsService.emailNotifications,
                onChanged: (value) => setState(() => _settingsService.setEmailNotifications(value)),
              ),
              _buildNotificationTile(
                icon: Icons.event_available,
                title: 'Order Updates',
                subtitle: 'Notify you when an order is due',
                value: _settingsService.orderUpdates,
                onChanged: (value) => setState(() => _settingsService.setOrderUpdates(value)),
              ),
              _buildNotificationTile(
                icon: Icons.campaign,
                title: 'Marketing',
                subtitle: 'Promotional offers and news',
                value: _settingsService.marketing,
                onChanged: (value) => setState(() => _settingsService.setMarketing(value)),
              ),
            ]),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  

  Widget _buildModernSectionHeaderWithIcon(Widget icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 20, height: 20, child: Center(child: icon)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }


  Widget _buildModernSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrencySettingsTile() {
    final currentCurrency = _currencies.firstWhere(
      (currency) => currency['code'] == _settingsService.currency,
      orElse: () => {'code': 'USD', 'name': 'US Dollar (\$)'},
    );
    
    return InkWell(
      onTap: () => _showCurrencySelector(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on,
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentCurrency['name']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPricePerHourSettingsTile() {
    return InkWell(
      onTap: () => _showPricePerHourDialog(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price per Hour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_settingsService.getCurrencySymbol()}${_pricePerHourController.text}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildThemeQuickToggleTile() {
    final isDark = ThemeController.instance.themeMode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode,
            color: Colors.grey[700],
            size: 24,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Light/Dark mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Quickly toggle between light and dark',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (value) async {
              await ThemeController.instance.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
              if (mounted) setState(() {});
            },
            thumbColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  

}

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating > 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your review!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Leave a Review',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How would you rate CakeAide Pro?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tell us what you think... (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class IssueDialog extends StatefulWidget {
  const IssueDialog({super.key});

  @override
  State<IssueDialog> createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog> {
  final _issueController = TextEditingController();
  String _selectedCategory = 'Bug Report';
  final List<String> _categories = ['Bug Report', 'Feature Request', 'General Issue', 'Other'];
  bool _submitting = false;

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (_issueController.text.trim().isEmpty) return;
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await FirebaseService.addSupportIssue(
        category: _selectedCategory,
        message: _issueController.text.trim(),
        appVersion: '1.0.0',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Issue submitted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Submit an Issue',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Describe the issue'),
          const SizedBox(height: 8),
          TextField(
            controller: _issueController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Please provide details about the issue...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submitIssue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _submitting
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit'),
        ),
      ],
    );
  }
}



class AboutUsDialog extends StatelessWidget {
  const AboutUsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cake, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'About CakeAide Pro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Builder(
        builder: (context) {
          Future<void> openUri(Uri uri) async {
            final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Could not open link'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }

          Widget linkTile({required IconData icon, required String label, required VoidCallback onTap}) {
            return InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CakeAide Pro is your comprehensive cake business assistant. Track and manage your cake orders with confidence and peace of mind.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Ingredient & Supply Management\n• Recipe Creation & Storage\n• Quote Generation\n• Order Tracking\n• Shopping List Creation\n• Unit Conversion Tools',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                'Contact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              linkTile(
                icon: Icons.public,
                label: 'www.cakeaidepro.com',
                onTap: () => openUri(Uri.parse('https://www.cakeaidepro.com')),
              ),
              linkTile(
                icon: Icons.email_outlined,
                label: 'support@cakeaidepro.com',
                onTap: () => openUri(Uri(scheme: 'mailto', path: 'support@cakeaidepro.com')),
              ),
              linkTile(
                icon: Icons.email_outlined,
                label: 'hello@cakeaidepro.com',
                onTap: () => openUri(Uri(scheme: 'mailto', path: 'hello@cakeaidepro.com')),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  children: [
                    const TextSpan(text: 'Version 1.0.0\n© 2025 CakeAide Pro. '),
                    TextSpan(
                      text: 'Icons by Icons8',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final uri = Uri.parse('https://icons8.com/');
                          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Could not open link'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                    ),
                    const TextSpan(text: '. All rights reserved.'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentStep = 0;
  
  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      icon: Icons.home,
      title: 'Welcome to CakeAide Pro',
      description: 'Your comprehensive cake business management app. Navigate through different features using the bottom navigation bar.',
      color: Colors.blue,
    ),
    TutorialStep(
      icon: Icons.inventory,
      title: 'Ingredients & Supplies',
      description: 'Manage your baking ingredients and supplies. Track quantities, prices, and expiration dates to keep your inventory organized.',
      color: Colors.green,
    ),
    TutorialStep(
      icon: Icons.book,
      title: 'Recipe Management',
      description: 'Create, store, and organize your cake recipes. Add ingredients, instructions, and photos for easy reference.',
      color: Colors.orange,
    ),
    TutorialStep(
      icon: Icons.calculate,
      title: 'Quote Calculator',
      description: 'Generate professional quotes for your customers. Calculate costs including ingredients, time, and profit margins.',
      color: Colors.purple,
    ),
    TutorialStep(
      icon: Icons.shopping_cart,
      title: 'Order Management',
      description: 'Track your orders from start to finish. Monitor delivery dates, customer details, and order status.',
      color: Colors.red,
    ),
    TutorialStep(
      icon: Icons.timer,
      title: 'Work Timer',
      description: 'Track the time spent on each project to accurately calculate labor costs and improve efficiency.',
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = _tutorialSteps[_currentStep];
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tutorial',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tutorialSteps.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentStep 
                        ? currentStep.color 
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 30),
            
            // Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: currentStep.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      currentStep.icon,
                      size: 40,
                      color: currentStep.color,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    currentStep.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    currentStep.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                
                if (_currentStep > 0) const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < _tutorialSteps.length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStep.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_currentStep < _tutorialSteps.length - 1 ? 'Next' : 'Get Started'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  
  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}