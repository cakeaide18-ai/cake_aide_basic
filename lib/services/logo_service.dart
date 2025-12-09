import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LogoService {
  static const String _logoPathKey = 'custom_logo_path';
  static String? _cachedLogoPath;

  /// Get the custom logo path from storage
  static Future<String?> getCustomLogoPath() async {
    if (_cachedLogoPath != null) return _cachedLogoPath;
    
    final prefs = await SharedPreferences.getInstance();
    _cachedLogoPath = prefs.getString(_logoPathKey);
    return _cachedLogoPath;
  }

  /// Save custom logo path to storage
  static Future<void> saveCustomLogoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logoPathKey, path);
    _cachedLogoPath = path;
  }

  /// Clear custom logo
  static Future<void> clearCustomLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logoPathKey);
    _cachedLogoPath = null;
  }

  /// Pick and save a custom logo from gallery
  static Future<String?> pickAndSaveLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Get app directory to save the logo
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String logoDir = '${appDir.path}/logos';
      final Directory logoDirectory = Directory(logoDir);
      
      // Create directory if it doesn't exist
      if (!await logoDirectory.exists()) {
        await logoDirectory.create(recursive: true);
      }

      // Copy file to app directory
      final String fileName = 'custom_logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final String newPath = '$logoDir/$fileName';
      final File newFile = File(newPath);
      await newFile.writeAsBytes(await File(image.path).readAsBytes());

      // Save path to preferences
      await saveCustomLogoPath(newPath);
      return newPath;
    } catch (e) {
      debugPrint('Error picking logo: $e');
      return null;
    }
  }

  /// Get logo widget with fallback
  static Widget getLogoWidget({
    double width = 120,
    double height = 120,
    bool isCircular = true,
  }) {
    return FutureBuilder<String?>(
      future: getCustomLogoPath(),
      builder: (context, snapshot) {
        Widget logoChild;
        
        if (snapshot.hasData && snapshot.data != null) {
          // Custom logo exists
          final File logoFile = File(snapshot.data!);
          if (logoFile.existsSync()) {
            logoChild = Image.file(
              logoFile,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _getDefaultLogo(context, width, height),
            );
          } else {
            logoChild = _getDefaultLogo(context, width, height);
          }
        } else {
          // Try default asset logo - try multiple possible paths
          logoChild = _tryLoadAssetLogo(context, width, height);
        }

        if (isCircular) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 2),
              child: logoChild,
            ),
          );
        } else {
          return SizedBox(
            width: width,
            height: height,
            child: logoChild,
          );
        }
      },
    );
  }

  /// Try to load asset logo with fallbacks
  static Widget _tryLoadAssetLogo(BuildContext context, double width, double height) {
    return Image.asset(
      'assets/images/app_logo.jpg',
      width: width,
      height: height,
      fit: BoxFit.contain, // Changed to contain to preserve aspect ratio
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Failed to load app_logo.jpg: $error');
        return _getDefaultLogo(context, width, height);
      },
    );
  }

  /// Default fallback logo
  static Widget _getDefaultLogo(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(width / 2),
      ),
      child: Icon(
        Icons.cake_outlined,
        size: width * 0.5,
        color: Colors.white,
      ),
    );
  }

  /// Show logo picker dialog
  static Future<void> showLogoPicker(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Logo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose how you want to update your app logo:'),
              const SizedBox(height: 16),
              getLogoWidget(width: 80, height: 80),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await clearCustomLogo();
                setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logo reset to default!')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Reset to Default'),
            ),
            ElevatedButton(
              onPressed: () async {
                final path = await pickAndSaveLogo();
                if (path != null) {
                  setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logo updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Pick from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}