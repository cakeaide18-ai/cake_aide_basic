import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/supabase/auth_state_manager.dart';

class ProfileCreationScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileCreationScreen({super.key, this.isEditing = false});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();


  
  String _selectedExperienceLevel = 'Beginner';
  String _selectedBusinessType = 'Home Baker';
  bool _isLoading = false;
  File? _profileImage;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  final AuthStateManager _authManager = AuthStateManager();
  
  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate', 
    'Advanced',
    'Professional'
  ];
  
  final List<String> _businessTypes = [
    'Home Baker',
    'Small Bakery',
    'Cake Shop',
    'Catering Business',
    'Wedding Specialist',
    'Custom Cake Artist'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingProfile();
    }
  }

  Future<void> _loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('profile_name') ?? prefs.getString('owner_name') ?? '';
    _emailController.text = prefs.getString('profile_email') ?? prefs.getString('email') ?? '';
    _phoneController.text = prefs.getString('profile_phone') ?? prefs.getString('phone_number') ?? '';
    _businessNameController.text = prefs.getString('profile_business_name') ?? prefs.getString('business_name') ?? '';
    _locationController.text = prefs.getString('profile_location') ?? prefs.getString('address') ?? '';
    _bioController.text = prefs.getString('profile_bio') ?? '';
    _selectedExperienceLevel = prefs.getString('profile_experience') ?? 'Beginner';
    _selectedBusinessType = prefs.getString('profile_business_type') ?? 'Home Baker';
    
    if (kIsWeb) {
      // For web, check for base64 image data
      final webImageData = prefs.getString('profile_image_web');
      if (webImageData != null && webImageData.isNotEmpty) {
        try {
          final bytes = base64Decode(webImageData);
          // For web, we'll store the bytes separately and handle display differently
          _webImageBytes = bytes;
          setState(() {});
        } catch (e) {
          debugPrint('Error loading web image: $e');
        }
      }
    } else {
      // For mobile, load from file path
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty) {
        setState(() {
          _profileImage = File(imagePath);
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Profile Picture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageOption(
                            icon: Icons.camera_alt,
                            title: 'Camera',
                            onTap: () => _getImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImageOption(
                            icon: Icons.photo_library,
                            title: 'Gallery',
                            onTap: () => _getImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      // Skip permission handling on web
      if (!kIsWeb) {
        // Check and request permissions for mobile platforms
        Permission permission;
        if (source == ImageSource.camera) {
          permission = Permission.camera;
        } else {
          permission = Permission.photos;
        }
        
        var status = await permission.status;
        
        // Request permission if not granted
        if (!status.isGranted && !status.isLimited) {
          status = await permission.request();
        }
        
        // Allow limited access on iOS (user selected some photos) 
        // Also allow granted status, but deny denied/restricted/permanentlyDenied
        if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  source == ImageSource.camera
                      ? 'Camera permission is required to take photos'
                      : 'Photo library permission is required to select images',
                ),
                backgroundColor: Colors.red,
                action: status.isPermanentlyDenied
                    ? SnackBarAction(
                        label: 'Settings',
                        onPressed: () => openAppSettings(),
                      )
                    : null,
              ),
            );
          }
          return;
        }
      }
      
      // Pick image
      debugPrint('Attempting to pick image from ${source == ImageSource.camera ? "camera" : "gallery"}');
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      debugPrint('Image picked: ${image?.path}');
      
      if (image != null) {
        if (kIsWeb) {
          // Save image data as base64 for web and set bytes for display
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_web', base64Image);
          
          setState(() {
            _webImageBytes = bytes;
          });
          
        } else {
          // For mobile, save to permanent location
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File permanentImage = File('${appDir.path}/$fileName');
          
          // Copy the picked image to permanent location
          await permanentImage.writeAsBytes(await image.readAsBytes());
          
          setState(() {
            _profileImage = permanentImage;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save profile image path if exists
      String? profileImagePath;
      if (kIsWeb && _webImageBytes != null) {
        // For web, the image is already saved as base64 in _getImage
        profileImagePath = 'web_image';
      } else if (!kIsWeb && _profileImage != null) {
        profileImagePath = _profileImage!.path;
        await prefs.setString('profile_image', profileImagePath);
        debugPrint('Profile image saved to: $profileImagePath');
      }
      
      // Create UserProfile object
      final profile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        businessName: _businessNameController.text.trim(),
        location: _locationController.text.trim(),
        experienceLevel: _selectedExperienceLevel,
        businessType: _selectedBusinessType,
        bio: _bioController.text.trim(),
        profileImageUrl: profileImagePath ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to shared preferences for local storage
      await prefs.setString('business_name', profile.businessName);
      await prefs.setString('owner_name', profile.name);
      await prefs.setString('phone_number', profile.phone);
      await prefs.setString('email', profile.email);
      await prefs.setString('address', profile.location);
      await prefs.setBool('profile_complete', true);
      
      // Save to the keys used by settings screen for consistency
      await prefs.setString('profile_name', profile.name);
      await prefs.setString('profile_email', profile.email);
      await prefs.setString('profile_phone', profile.phone);
      await prefs.setString('profile_business_name', profile.businessName);
      await prefs.setString('profile_location', profile.location);
      await prefs.setString('profile_bio', profile.bio);
      await prefs.setString('profile_experience', profile.experienceLevel);
      await prefs.setString('profile_business_type', profile.businessType);
      
      // Force refresh the auth manager profile
      _authManager.setUserProfile(profile);
      
      // Save to auth state manager
      try {
        if (widget.isEditing) {
          await _authManager.updateUserProfile(profile);
        } else {
          await _authManager.createUserProfile(profile);
        }
      } catch (e) {
        debugPrint('Auth manager save failed: $e');
        // Continue with local save even if auth manager fails
      }
      
      if (mounted) {
        if (widget.isEditing) {
          Navigator.pop(context, true); // Return true to indicate profile was updated
        } else {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      debugPrint('Failed to save profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DecorationImage? _getImageProvider() {
    if (kIsWeb && _webImageBytes != null) {
      return DecorationImage(
        image: MemoryImage(_webImageBytes!),
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _profileImage != null) {
      return DecorationImage(
        image: FileImage(_profileImage!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isEditing ? AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              image: _getImageProvider(),
                              color: (_profileImage == null && _webImageBytes == null) ? Colors.grey[300] : null,
                            ),
                            child: (_profileImage == null && _webImageBytes == null)
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isEditing ? 'Edit Your Profile' : 'Create Your Profile',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isEditing 
                          ? 'Update your baking information'
                          : 'Tell us about your baking journey',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              
              // Form Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name (Optional)',
                        hint: 'Enter your full name',
                        icon: Icons.person,
                        validator: null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address (Optional)',
                        hint: 'Enter your email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number (Optional)',
                        hint: 'Enter your phone number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: null,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Business Information Section
                      _buildSectionTitle('Business Information'),
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Featured Field',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _businessNameController,
                              label: 'Business Name (Optional)',
                              hint: 'Enter your business name (e.g., Sweet Dreams Bakery)',
                              icon: Icons.business,
                              validator: null,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location (Optional)',
                        hint: 'City, State/Country',
                        icon: Icons.location_on,
                        validator: null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Experience Level Dropdown
                      _buildDropdownField(
                        label: 'Experience Level (Optional)',
                        value: _selectedExperienceLevel,
                        items: _experienceLevels,
                        icon: Icons.star,
                        onChanged: (value) {
                          setState(() {
                            _selectedExperienceLevel = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Business Type Dropdown
                      _buildDropdownField(
                        label: 'Business Type (Optional)',
                        value: _selectedBusinessType,
                        items: _businessTypes,
                        icon: Icons.cake,
                        onChanged: (value) {
                          setState(() {
                            _selectedBusinessType = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _bioController,
                        label: 'Bio (Optional)',
                        hint: 'Tell us about your baking passion and specialties',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: null,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Create Profile Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEditing ? 'Update Profile' : 'Create My Profile',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Skip Button (only show when creating new profile)
                      if (!widget.isEditing)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/main');
                            },
                            child: Text(
                              'Skip for now',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}